package rpcdram

import rpcdram.core._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.bmb.BmbParameter

/**
 * RPC DRAM Controller - High-performance SpinalHDL controller for Etron EM6GA16LGDBXCAEA RPC DRAM
 *
 * Features:
 * - 800 MHz DDR operation (1600 MT/s effective data rate)
 * - 16-bit x16 DB interface with SSTL135 signaling
 * - Configurable multi-rank support
 * - BMB (Bus Memory Bus) interface for easy integration
 * - Conditional feature generation for area optimization
 * - Comprehensive formal verification support
 * - ECP5 FPGA synthesis optimized
 *
 * Architecture follows DFI-inspired organization with separate areas for:
 * - Timing management
 * - Bank tracking
 * - Initialization sequencing
 * - Command scheduling
 * - Refresh management
 * - Power management
 * - PHY interface
 * - External connections
 *
 * @param cfg Configuration parameters including timing, signal config, and features
 * @param bmbP Optional BMB parameter for bus interface (None = direct user bus interface)
 */
case class RpcDramController(cfg: RpcDramConfig, bmbP: Option[BmbParameter] = None) extends Component {
  // Controller I/O bundle
  val io = new Bundle {
    // Control interface (user bus, power control, BMB if enabled)
    val ctrlIO = RpcDramCtrlIO(cfg, bmbP)

    // Bidirectional DRAM data bus (DB) - 16-bit x16 interface per datasheet section 2.3
    val dramDb = inout(Analog(Bits(cfg.dataWidth bits)))

    // Bidirectional DRAM strobe signals (DQS/DQS1) - conditionally generated
    // DQS: Data strobe for read/write synchronization per section 2.2
    val dramDqs = cfg.signalConfig.useDqs generate inout(Analog(Bits(cfg.dqsWidth bits)))
    val dramDqs1 = cfg.signalConfig.useDqs1 generate inout(Analog(Bits(cfg.dqsWidth bits)))
  }

  /**
   * Timing Management Area
   *
   * Manages all DRAM timing parameters per datasheet section 11.3:
   * - tRCD: Row to Column Delay
   * - tRP: Precharge Time
   * - tRAS: Row Active Time
   * - tRRD: Row to Row Delay
   * - tPPD: Parallel Packet Delay
   * - tRFC: Refresh Cycle Time
   * - tFAW: Four Activate Window
   * - tWR: Write Recovery Time
   *
   * Uses TimingRegs component for dynamic timing updates (future enhancement)
   */
  val timing = new Area {
    val regs = TimingRegs(cfg.timingParams)

    // Default: no timing updates (static timing from config)
    // Future: connect to bus interface for dynamic timing adjustment
    regs.io.update.valid := False
    regs.io.update.payload.assignDontCare()
  }

  /**
   * Bank Tracking Area
   *
   * Tracks state of all DRAM banks (IDLE/ACTIVE) and open row addresses.
   * Conditionally generated based on cfg.signalConfig.features.useBankTracker.
   *
   * Essential for:
   * - ACTIVATE command validation (bank must be IDLE)
   * - PRECHARGE command validation (bank must be ACTIVE)
   * - Row address conflict detection
   * - tRRD and tFAW timing enforcement
   */
  val banks = cfg.signalConfig.features.useBankTracker generate new Area {
    val tracker = BankTracker(cfg)
  }

  /**
   * Initialization Area
   *
   * Handles power-on initialization sequence per datasheet section 2.8:
   * 1. Wait 200µs after power stable
   * 2. Issue RESET command (5µs pulse)
   * 3. Send serial NOPs for reset recovery
   * 4. Precharge all banks
   * 5. Mode Register Set (MRS) with timing parameters
   * 6. ZQ calibration (ZQINIT)
   *
   * Uses InitSequencer FSM to generate proper command sequence with timing.
   */
  val init = new Area {
    val sequencer = InitSequencer(cfg)

    // Always start initialization immediately (controller assumes power is stable)
    sequencer.io.start := True
    sequencer.io.timing := timing.regs.io.current

    // Simulation debug signals
    if (cfg.simMode) {
      sequencer.io.initDone.simPublic()
      sequencer.io.cmdOut.simPublic()
    }
  }

  /**
   * Command Scheduling Area
   *
   * Core command arbitration and scheduling logic implementing:
   * - Chapter 8 Command Sequencing Rules (Tables 8-1 through 8-8)
   * - Priority-based command arbitration (Init > Refresh > Power > User)
   * - Timing constraint enforcement (tRCD, tRP, tRAS, tRRD, tPPD, tRFC, tFAW, tWR)
   * - Burst management and serial command sequencing
   * - Address decoding pipeline for critical path optimization
   *
   * Uses CmdScheduler FSM with three phases:
   * 1. Idle: Command arbitration and acceptance
   * 2. Command: Validation and timing checks
   * 3. Wait: Timing delays and burst completion
   */
  val cmd = new Area {
    val scheduler = CmdScheduler(cfg)

    // Connect initialization sequencer to scheduler
    scheduler.io.initDone := init.sequencer.io.initDone
    scheduler.io.initCmd.valid := init.sequencer.io.cmdOut.valid
    scheduler.io.initCmd.payload := init.sequencer.io.cmdOut.payload
    init.sequencer.io.cmdOut.ready := scheduler.io.initCmd.ready
    scheduler.io.currentTiming := timing.regs.io.current

    // Bank tracker integration (conditionally connected)
    if (cfg.signalConfig.features.useBankTracker) {
      scheduler.io.toBankTracker <> banks.tracker.io.cmd
      scheduler.io.fromBankTracker <> banks.tracker.io.status
    } else {
      // Default: all banks IDLE, no open rows (simplified mode)
      scheduler.io.fromBankTracker.bankStates.foreach(_ := BankState.IDLE)
      scheduler.io.fromBankTracker.openRow.foreach(_ := 0)
    }

    // Simulation debug signals for waveform analysis
    if (cfg.simMode) {
      scheduler.io.debugInfo.simPublic()
      scheduler.io.initCmd.simPublic()
      scheduler.io.toPhy.simPublic()
    }
  }

  /**
   * Refresh Management Area
   *
   * Handles DRAM refresh requirements per datasheet section 5:
   * - Automatic refresh command generation
   * - tRFC timing enforcement
   * - One Shot and Loop refresh modes
   * - Refresh blocking during critical operations
   *
   * Conditionally generated based on cfg.signalConfig.useRefresh.
   * When disabled, no refresh commands are issued (for testing only).
   */
  val refresh = cfg.signalConfig.useRefresh generate new Area {
    val manager = RefreshManager(cfg)
    manager.io.timing := timing.regs.io.current
    cmd.scheduler.io.refreshCmd << manager.io.toScheduler
  }

  /**
   * Power Management Area
   *
   * Implements power saving features per datasheet sections 2.10-2.12:
   * - Power Down (PD): Fast exit, maintains bank states
   * - Deep Power Down (DPD): Slow exit, requires re-initialization
   * - Self-refresh modes
   * - Automatic idle detection and power state transitions
   *
   * Conditionally generated based on cfg.signalConfig.usePower.
   * Connects to external power control interface.
   */
  val power = cfg.signalConfig.usePower generate new Area {
    val manager = PowerManager(cfg)
    manager.io.ctrl <> io.ctrlIO.powerCtrl
    manager.io.timing := timing.regs.io.current
    manager.io.isIdle := cmd.scheduler.io.initDone && !io.ctrlIO.user.cmd.valid
    cmd.scheduler.io.powerCmd << manager.io.cmdOut
  }

  /**
   * PHY Interface Area
   *
   * Interfaces with RpcDramPhy for low-level DRAM signaling:
   * - Command packet transmission to DRAM
   * - Write data streaming with proper DDR timing
   * - Read data reception with calibration
   * - DQS strobe alignment and IDELAY calibration
   * - Bidirectional DB/DQS bus management
   *
   * Key features:
   * - 800 MHz DDR operation with phase-shifted clocks
   * - SSTL135 I/O standard compliance
   * - Hardware primitives (IDDRX1F/ODDRX1F) for ECP5
   * - Behavioral simulation models for Verilator
   */
  val phy = new Area {
    val interface = RpcDramPhy(cfg)

    // Command stream from scheduler to PHY
    interface.io.cmdIn << cmd.scheduler.io.toPhy

    // Response stream: signal burst completion to scheduler
    // Valid when read data last fragment is received
    val responseStream = Stream(Bool())
    responseStream.valid := interface.io.readDataOut.valid && interface.io.readDataOut.payload.last
    responseStream.payload := True
    cmd.scheduler.io.fromPhy << responseStream

    // Expose calibration status (used by external logic if needed)
    val calibDone = interface.io.calibDone

    // Simulation debug signals
    if (cfg.simMode) {
      interface.io.cmdIn.simPublic()
    }
  }

  /**
   * External Connections Area
   *
   * Handles all external I/O connections and conditional feature management:
   * - DRAM bus connections (DB, DQS, DQS1) with proper Analog() handling
   * - BMB adapter for bus interface compatibility
   * - Default signal drivers for disabled features
   * - Data path routing between user interface, scheduler, and PHY
   */
  val connections = new Area {
    // DRAM bus connections - bidirectional analog signals
    io.ctrlIO.dram <> phy.interface.io.dram
    io.dramDb <> phy.interface.io.db
    if (cfg.signalConfig.useDqs) {
      io.dramDqs <> phy.interface.io.dqs
    }
    if (cfg.signalConfig.useDqs1) {
      io.dramDqs1 <> phy.interface.io.dqs1
    }

    // Default drivers for conditionally disabled features
    if (!cfg.signalConfig.useRefresh) {
      cmd.scheduler.io.refreshCmd.valid := False
      cmd.scheduler.io.refreshCmd.payload.assignDontCare()
    }

    if (!cfg.signalConfig.usePower) {
      cmd.scheduler.io.powerCmd.valid := False
      cmd.scheduler.io.powerCmd.payload.assignDontCare()
      // Safe default for power control interface
      if (io.ctrlIO.powerCtrl != null) {
        io.ctrlIO.powerCtrl.reInitRequired := False
      }
    }

    /**
     * BMB Adapter Logic
     *
     * When BMB parameter is provided, creates adapter for Bus Memory Bus compatibility.
     * BMB provides standardized memory interface for easy SoC integration.
     * When not used, connects directly to user bus interface.
     */
    val userBus = if (bmbP.isDefined) {
      val adapter = BmbToUserBus(bmbP.get, cfg)
      adapter.io.bmb <> io.ctrlIO.bmb

      // Disable external user bus when using BMB (mutually exclusive)
      io.ctrlIO.user.cmd.ready := False
      io.ctrlIO.user.writeData.ready := False
      io.ctrlIO.user.readData.valid := False
      io.ctrlIO.user.readData.payload.fragment := 0
      io.ctrlIO.user.readData.payload.last := False

      adapter.io.user
    } else {
      io.ctrlIO.user
    }

    // UTR data generation
    val utrDataGen = new Area {
      // Generate UTR patterns using bit concatenation
      val pattern0101 = Bits(4 bits)
      val pattern1100 = Bits(4 bits)
      val pattern0011 = Bits(4 bits)
      val pattern1010 = Bits(4 bits)

      pattern0101 := B"0101"
      pattern1100 := B"1100"
      pattern0011 := B"0011"
      pattern1010 := B"1010"

      // Create 256-bit patterns by repeating 4-bit patterns 64 times
      val utrPatterns = Vec(Bits(256 bits), 4)
      for (i <- 0 until 64) {
        utrPatterns(0)((i*4+3) downto (i*4)) := pattern0101
        utrPatterns(1)((i*4+3) downto (i*4)) := pattern1100
        utrPatterns(2)((i*4+3) downto (i*4)) := pattern0011
        utrPatterns(3)((i*4+3) downto (i*4)) := pattern1010
      }

      // Mux read data between normal and UTR
      val readDataMux = Stream(Fragment(Bits(256 bits)))
      readDataMux << phy.interface.io.readDataOut

      // Replace data with UTR pattern when UTR is enabled
      when(cmd.scheduler.io.utrStatus.enabled) {
        readDataMux.payload.fragment := utrPatterns(cmd.scheduler.io.utrStatus.op.asUInt)
      }
    }

    // Data path connections
    cmd.scheduler.io.user.cmd <> userBus.cmd
    phy.interface.io.writeDataIn <> userBus.writeData
    userBus.readData <> utrDataGen.readDataMux
  }
}