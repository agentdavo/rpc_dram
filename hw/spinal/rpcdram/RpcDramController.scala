package rpcdram

import rpcdram.core._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.io._
import spinal.lib.bus.bmb.BmbParameter

case class RpcDramController(cfg: RpcDramConfig, bmbP: Option[BmbParameter] = None) extends Component {
  val io = new Bundle {
    val ctrlIO = RpcDramCtrlIO(cfg, bmbP)
    // Bidirectional DRAM signals using inout(Analog()) - inspired by DFI
    val dramDb = inout(Analog(Bits(cfg.dataWidth bits)))
    val dramDqs = cfg.signalConfig.useDqs generate inout(Analog(Bits(cfg.dqsWidth bits)))
    val dramDqs1 = cfg.signalConfig.useDqs1 generate inout(Analog(Bits(cfg.dqsWidth bits)))
  }

  // Timing management area - inspired by DFI Control organization
  val timing = new Area {
    val regs = TimingRegs(cfg.timingParams)
    
    // Default timing register update (can be enhanced with bus interface later)
    regs.io.update.valid := False
    regs.io.update.payload.assignDontCare()
  }

  // Bank tracking area - conditionally generated
  val banks = cfg.signalConfig.features.useBankTracker generate new Area {
    val tracker = BankTracker(cfg)
  }

  // Initialization area
  val init = new Area {
    val sequencer = InitSequencer(cfg)
    
    // Start initialization when not in reset
    sequencer.io.start := !ClockDomain.current.isResetActive
    sequencer.io.timing := timing.regs.io.current
    
    // Make signals accessible for simulation
    if (cfg.simMode) {
      sequencer.io.initDone.simPublic()
      sequencer.io.cmdOut.simPublic()
    }
  }

  // Command scheduling area
  val cmd = new Area {
    val scheduler = CmdScheduler(cfg)
    
    // Connect to initialization
    scheduler.io.initDone := init.sequencer.io.initDone
     scheduler.io.initCmd.valid := init.sequencer.io.cmdOut.valid
     scheduler.io.initCmd.payload := init.sequencer.io.cmdOut.payload
     init.sequencer.io.cmdOut.ready := scheduler.io.initCmd.ready
    scheduler.io.currentTiming := timing.regs.io.current
    
    // Connect to bank tracker if enabled
    if (cfg.signalConfig.features.useBankTracker) {
      scheduler.io.toBankTracker <> banks.tracker.io.cmd
      scheduler.io.fromBankTracker <> banks.tracker.io.status
    } else {
      // Provide default values when bank tracker is disabled
      scheduler.io.fromBankTracker.bankStates.foreach(_ := BankState.IDLE)
      scheduler.io.fromBankTracker.openRow.foreach(_ := 0)
    }
    
    // Make debug signals accessible for simulation
    if (cfg.simMode) {
      scheduler.io.debugInfo.simPublic()
      scheduler.io.initCmd.simPublic()
      scheduler.io.toPhy.simPublic()
      scheduler.addrDecodeArea.addrValid.simPublic()
      scheduler.addrDecodeArea.userCmdBuffered.simPublic()
    }
  }

  // Refresh management area - conditionally generated
  val refresh = cfg.signalConfig.useRefresh generate new Area {
    val manager = RefreshManager(cfg)
    manager.io.timing := timing.regs.io.current
    cmd.scheduler.io.refreshCmd << manager.io.toScheduler
  }

  // Power management area - conditionally generated  
  val power = cfg.signalConfig.usePower generate new Area {
    val manager = PowerManager(cfg)
    manager.io.ctrl <> io.ctrlIO.powerCtrl
    manager.io.timing := timing.regs.io.current
    manager.io.isIdle := cmd.scheduler.io.initDone && !io.ctrlIO.user.cmd.valid
    cmd.scheduler.io.powerCmd << manager.io.cmdOut
  }

  // PHY interface area
  val phy = new Area {
    val interface = RpcDramPhy(cfg)
    
    // Connect to command scheduler
    interface.io.cmdIn << cmd.scheduler.io.toPhy
    
    // Create stream for PHY responses
    val responseStream = Stream(Bool())
    responseStream.valid := interface.io.readDataOut.valid && interface.io.readDataOut.payload.last
    responseStream.payload := True
    cmd.scheduler.io.fromPhy << responseStream
    
    // Expose calibration status
    val calibDone = interface.io.calibDone
    val calibDelay = interface.io.calibDelay
    
    // Make PHY signals accessible for simulation
    if (cfg.simMode) {
      interface.io.cmdIn.simPublic()
    }
  }

  // External connections area
  val connections = new Area {
    // Connect PHY to external DRAM bus
    io.ctrlIO.dram <> phy.interface.io.dram
    io.dramDb <> phy.interface.io.db
    if (cfg.signalConfig.useDqs) {
      io.dramDqs <> phy.interface.io.dqs
    }
    if (cfg.signalConfig.useDqs1) {
      io.dramDqs1 <> phy.interface.io.dqs1
    }

    // Handle conditional features with proper defaults
    if (!cfg.signalConfig.useRefresh) {
      cmd.scheduler.io.refreshCmd.valid := False
      cmd.scheduler.io.refreshCmd.payload.assignDontCare()
    }

    if (!cfg.signalConfig.usePower) {
      cmd.scheduler.io.powerCmd.valid := False
      cmd.scheduler.io.powerCmd.payload.assignDontCare()
      if (io.ctrlIO.powerCtrl != null) {
        io.ctrlIO.powerCtrl.reInitRequired := False
      }
    }

    // BMB adapter area - creates internal user bus
    val userBus = if (bmbP.isDefined) {
      val adapter = BmbToUserBus(bmbP.get, cfg)
      adapter.io.bmb <> io.ctrlIO.bmb
      
      // Default drivers for external user bus when BMB is used
      io.ctrlIO.user.cmd.ready := False
      io.ctrlIO.user.writeData.ready := False
      io.ctrlIO.user.readData.valid := False
      io.ctrlIO.user.readData.payload.fragment := 0
      io.ctrlIO.user.readData.payload.last := False
      
      adapter.io.user
    } else {
      io.ctrlIO.user
    }
    
    // Connect data paths
    cmd.scheduler.io.user.cmd <> userBus.cmd
    phy.interface.io.writeDataIn <> userBus.writeData  
    userBus.readData <> phy.interface.io.readDataOut
  }
}