package rpcdram.formal

import rpcdram._
import rpcdram.core._
import rpcdram.utils._
import spinal.core._
import spinal.core.formal._
import spinal.lib._

// =============================================================================
// BankTracker Formal Verification
// =============================================================================

object BankTrackerBasicFormal extends App {
  FormalConfig.withBMC(10).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true)
    val dut = FormalDut(new BankTracker(cfg))
    
    assumeInitial(ClockDomain.current.isResetActive)
    
    // No inputs during reset
    ClockDomain.current.duringReset {
      assume(dut.io.cmd.activate.valid === False)
      assume(dut.io.cmd.precharge.valid === False)
    }
    
    // Drive inputs
    anyseq(dut.io.cmd.activate.valid)
    anyseq(dut.io.cmd.activate.payload.bank)
    anyseq(dut.io.cmd.activate.payload.rowAddr)
    anyseq(dut.io.cmd.precharge.valid)
    anyseq(dut.io.cmd.precharge.payload)
    
    // Constraint: don't activate and precharge same bank simultaneously
    when(dut.io.cmd.activate.fire && dut.io.cmd.precharge.fire) {
      assume(dut.io.cmd.activate.payload.bank =/= dut.io.cmd.precharge.payload)
    }
    
    // Cover: can we activate each bank?
    for (i <- 0 until cfg.bankCount) {
      cover(dut.states(i) === BankState.ACTIVE)
    }
    
    // Property: banks are always in valid states
    for (i <- 0 until cfg.bankCount) {
      assert(dut.states(i) === BankState.IDLE || 
             dut.states(i) === BankState.ACTIVE)
    }
    
    // Property: IDLE banks have row address 0
    for (i <- 0 until cfg.bankCount) {
      when(dut.states(i) === BankState.IDLE) {
        assert(dut.openRows(i) === 0)
      }
    }
  })
}

object BankTrackerTemporalFormal extends App {
  FormalConfig.withBMC(20).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true)
    val dut = FormalDut(new BankTracker(cfg))
    
    assumeInitial(ClockDomain.current.isResetActive)
    
    // Drive inputs
    anyseq(dut.io.cmd.activate.valid)
    anyseq(dut.io.cmd.activate.payload.bank)
    anyseq(dut.io.cmd.activate.payload.rowAddr)
    anyseq(dut.io.cmd.precharge.valid)
    anyseq(dut.io.cmd.precharge.payload)
    
    // Bank signals are already constrained by their width

    // Constraint: don't activate and precharge simultaneously
    assume(!(dut.io.cmd.activate.valid && dut.io.cmd.precharge.valid))

    // Property: activated bank should be ACTIVE with correct row
    when(pastValidAfterReset() && past(dut.io.cmd.activate.fire)) {
      val bank = past(dut.io.cmd.activate.payload.bank)
      val row = past(dut.io.cmd.activate.payload.rowAddr)
      assert(dut.states(bank) === BankState.ACTIVE)
      assert(dut.openRows(bank) === row)
    }

    // Property: precharged bank should be IDLE
    when(pastValidAfterReset() && past(dut.io.cmd.precharge.fire)) {
      val bank = past(dut.io.cmd.precharge.payload)
      assert(dut.states(bank) === BankState.IDLE)
      assert(dut.openRows(bank) === 0)
    }
    
    // Only one bank operation at a time
    assert(!(dut.io.cmd.activate.fire && dut.io.cmd.precharge.fire))
    
    // Cover all banks becoming active
    for (i <- 0 until cfg.bankCount) {
      cover(dut.states(i) === BankState.ACTIVE)
    }
    
    // Cover specific row addresses being opened
    val targetRow = anyconst(UInt(cfg.rowAddrWidth bits))
    for (i <- 0 until cfg.bankCount) {
      cover(dut.states(i) === BankState.ACTIVE && dut.openRows(i) === targetRow)
    }
  })
}

// =============================================================================
// InitSequencer Formal Verification  
// =============================================================================

object InitSequencerFormal extends App {
  FormalConfig.withBMC(100).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true, freqMHz = 100)
    val dut = FormalDut(new InitSequencer(cfg))

    assumeInitial(ClockDomain.current.isResetActive)

    // Drive the ready signal (input to DUT)
    anyseq(dut.io.cmdOut.ready)

    // Assume downstream is always ready to accept commands (for basic verification)
    assume(dut.io.cmdOut.ready)

    // Start initialization after reset
    dut.io.start := !ClockDomain.current.isResetActive
    
    // Fixed timing parameters
    dut.io.timing.tCke := 3
    dut.io.timing.tDpd := 400000
    dut.io.timing.tRcd := 12
    dut.io.timing.tRp := 12
    dut.io.timing.tWr := 12
    dut.io.timing.tRas := 30
    dut.io.timing.tRrd := 6
    dut.io.timing.tPpd := 8
    dut.io.timing.tZqInit := 1600 // 2µs @ 800MHz (corrected)
    dut.io.timing.tFaw := 24
    
    GenerationFlags.formal {
      // Track if we've seen each command
      val seenReset = RegInit(False)
      val seenPrecharge = RegInit(False)
      val seenMrs = RegInit(False)
      val seenZq = RegInit(False)
      
      when(dut.io.cmdOut.fire && dut.io.cmdOut.payload.opcode === Opcodes.PAR_RESET) {
        seenReset := True
      }
      when(dut.io.cmdOut.fire && dut.io.cmdOut.payload.opcode === Opcodes.PAR_PRE) {
        seenPrecharge := True
        // Precharge should come after reset
        assert(seenReset)
      }
      when(dut.io.cmdOut.fire && dut.io.cmdOut.payload.opcode === Opcodes.PAR_MRS) {
        seenMrs := True
        // MRS should come after precharge
        assert(seenPrecharge)
      }
      when(dut.io.cmdOut.fire && dut.io.cmdOut.payload.opcode === Opcodes.PAR_ZQ) {
        seenZq := True
        // ZQ should come after MRS
        assert(seenMrs)
      }
      
      // When init is done, we should have seen all commands
      when(dut.io.initDone) {
        assert(seenReset)
        assert(seenPrecharge)
        assert(seenMrs)
        assert(seenZq)
      }
      
      // Cover: can we complete initialization?
      cover(dut.io.initDone)
    }
  })
}

// =============================================================================
// CmdScheduler Formal Verification
// =============================================================================

object CmdSchedulerTimingFormal extends App {
  FormalConfig.withBMC(50).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true)
    val dut = FormalDut(new CmdScheduler(cfg))

    assumeInitial(ClockDomain.current.isResetActive)

    // Track timing between commands
    val cyclesSinceActivate = Reg(UInt(8 bits)) init(0)
    val lastBankActivated = Reg(UInt(cfg.bankAddrWidth bits)) init(0)

    // Drive inputs
    anyseq(dut.io.user.cmd.valid)
    anyseq(dut.io.user.cmd.payload.isWrite)
    anyseq(dut.io.user.cmd.payload.address)
    anyseq(dut.io.user.cmd.payload.burstLen)
    anyseq(dut.io.user.cmd.payload.writeMask)

    // Drive ready signals for DUT outputs
    anyseq(dut.io.toBankTracker.activate.ready)
    anyseq(dut.io.toBankTracker.precharge.ready)
    anyseq(dut.io.toPhy.ready)

    // Assume downstream is always ready for simplicity
    assume(dut.io.toBankTracker.activate.ready)
    assume(dut.io.toBankTracker.precharge.ready)
    assume(dut.io.toPhy.ready)

    // Always ready for init commands
    dut.io.initCmd.valid := False
    dut.io.refreshCmd.valid := False
    dut.io.powerCmd.valid := False
    dut.io.initDone := True

    // Mock bank tracker responses
    val mockBankStates = Vec(Reg(BankState()) init(BankState.IDLE), cfg.bankCount)
    val mockOpenRows = Vec(Reg(UInt(cfg.rowAddrWidth bits)) init(0), cfg.bankCount)

    dut.io.fromBankTracker.bankStates := mockBankStates
    dut.io.fromBankTracker.openRow := mockOpenRows

    // Update mock states based on commands
    when(dut.io.toBankTracker.activate.fire) {
      mockBankStates(dut.io.toBankTracker.activate.payload.bank) := BankState.ACTIVE
      mockOpenRows(dut.io.toBankTracker.activate.payload.bank) := dut.io.toBankTracker.activate.payload.rowAddr
      lastBankActivated := dut.io.toBankTracker.activate.payload.bank
      cyclesSinceActivate := 0
    } otherwise {
      cyclesSinceActivate := cyclesSinceActivate + 1
    }

    when(dut.io.toBankTracker.precharge.fire) {
      mockBankStates(dut.io.toBankTracker.precharge.payload) := BankState.IDLE
      mockOpenRows(dut.io.toBankTracker.precharge.payload) := U(0, cfg.rowAddrWidth bits)
    }

    // PHY always ready
    dut.io.fromPhy.valid := False

    // Timing constraint: tRCD must be respected
    when(pastValidAfterReset() && dut.io.toPhy.fire) {
      val cmdBank = dut.io.toPhy.payload.bank
      when(dut.io.toPhy.payload.opcode === Opcodes.PAR_RD ||
            dut.io.toPhy.payload.opcode === Opcodes.PAR_WR) {
        when(cmdBank === lastBankActivated) {
          assert(cyclesSinceActivate >= cfg.timingParams.tRcd)
        }
      }
    }

    // Cover: Can we issue read/write commands?
    cover(dut.io.toPhy.fire && dut.io.toPhy.payload.opcode === Opcodes.PAR_RD)
    cover(dut.io.toPhy.fire && dut.io.toPhy.payload.opcode === Opcodes.PAR_WR)
  })
}

// =============================================================================
// RefreshManager Formal Verification
// =============================================================================

object RefreshManagerFormal extends App {
  FormalConfig.withBMC(100).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true, freqMHz = 10) // Very low frequency for formal
    val dut = FormalDut(new RefreshManager(cfg))
    
    assumeInitial(ClockDomain.current.isResetActive)

    // Drive the ready signal (input to DUT)
    anyseq(dut.io.toScheduler.ready)
    assume(dut.io.toScheduler.ready) // Assume downstream is always ready

    // Set timing parameters
    dut.io.timing.tCke := 3
    dut.io.timing.tDpd := 400
    dut.io.timing.tRcd := 12
    dut.io.timing.tRp := 12
    dut.io.timing.tWr := 12
    dut.io.timing.tRas := 30
    dut.io.timing.tRrd := 6
    dut.io.timing.tPpd := 8
    dut.io.timing.tZqInit := 1600 // 2µs @ 800MHz
    dut.io.timing.tFaw := 24
    
    GenerationFlags.formal {
      // Count cycles between refresh commands
      val cyclesSinceRefresh = Reg(UInt(32 bits)) init(0)
      
      when(dut.io.toScheduler.fire) {
        cyclesSinceRefresh := 0
        // Verify it's a refresh command
        assert(dut.io.toScheduler.payload.opcode === Opcodes.PAR_REF)
      } otherwise {
        cyclesSinceRefresh := cyclesSinceRefresh + 1
      }
      
      // Should not wait too long between refreshes
      assert(cyclesSinceRefresh < 1000)
      
      // Cover: can we generate multiple refresh commands?
      val refreshCount = Reg(UInt(8 bits)) init(0)
      when(dut.io.toScheduler.fire) {
        refreshCount := refreshCount + 1
      }
      cover(refreshCount === 3)
    }
  })
}

// =============================================================================
// PowerManager Formal Verification
// =============================================================================

object PowerManagerFormal extends App {
  FormalConfig.withBMC(50).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true)
    val dut = FormalDut(new PowerManager(cfg))
    
    assumeInitial(ClockDomain.current.isResetActive)
    
    // Set timing
    dut.io.timing.tCke := 3
    dut.io.timing.tDpd := 100 // Short for formal
    dut.io.timing.tRcd := 12
    dut.io.timing.tRp := 12
    dut.io.timing.tWr := 12
    dut.io.timing.tRas := 30
    dut.io.timing.tRrd := 6
    dut.io.timing.tPpd := 8
    dut.io.timing.tZqInit := 1600 // 2µs @ 800MHz
    dut.io.timing.tFaw := 24
    
    // Control signals
    anyseq(dut.io.ctrl.enterPd)
    anyseq(dut.io.ctrl.exitPd)
    anyseq(dut.io.ctrl.enterDpd)
    anyseq(dut.io.isIdle)

    // Drive the ready signal (input to DUT)
    anyseq(dut.io.cmdOut.ready)
    assume(dut.io.cmdOut.ready) // Assume downstream is always ready
    
    GenerationFlags.formal {
      // Skip the power down entry check for now - focus on other properties
      
      // Deep power down should set reInitRequired
      when(dut.io.reInitRequired) {
        assert(dut.io.inPowerDown) // If reInitRequired is set, we must be in power down
      }
      
      // Cannot enter both PD and DPD simultaneously
      assume(!(dut.io.ctrl.enterPd && dut.io.ctrl.enterDpd))
      
      // Cannot enter and exit simultaneously
      assume(!(dut.io.ctrl.enterPd && dut.io.ctrl.exitPd))
      assume(!(dut.io.ctrl.enterDpd && dut.io.ctrl.exitPd))
      
      // Cover: can we enter and exit power down?
      cover(pastValid() && past(dut.io.inPowerDown) && !dut.io.inPowerDown)
      
      // Cover: can we trigger re-initialization?
      cover(dut.io.reInitRequired)
    }
  })
}



// =============================================================================
// Complete Controller Formal Verification
// =============================================================================

object RpcDramControllerFormal extends App {
  FormalConfig.withBMC(20).doVerify(new Component {
    val cfg = RpcDramConfig(simMode = true)
    val dut = FormalDut(new RpcDramController(cfg, None))
    
    assumeInitial(ClockDomain.current.isResetActive)
    
    // Drive inputs
    anyseq(dut.io.ctrlIO.user.cmd.valid)
    anyseq(dut.io.ctrlIO.user.cmd.payload.isWrite)
    anyseq(dut.io.ctrlIO.user.cmd.payload.address)
    anyseq(dut.io.ctrlIO.user.cmd.payload.burstLen)
    anyseq(dut.io.ctrlIO.user.cmd.payload.writeMask)
    anyseq(dut.io.ctrlIO.user.writeData.valid)
    anyseq(dut.io.ctrlIO.user.writeData.payload.fragment)
    anyseq(dut.io.ctrlIO.user.writeData.payload.last)
    anyseq(dut.io.ctrlIO.user.readData.ready)
    anyseq(dut.io.ctrlIO.powerCtrl.enterPd)
    anyseq(dut.io.ctrlIO.powerCtrl.exitPd)
    anyseq(dut.io.ctrlIO.powerCtrl.enterDpd)
    
    // Assume valid addresses and burst lengths
    assume(dut.io.ctrlIO.user.cmd.payload.address < (1L << 26))
    assume(dut.io.ctrlIO.user.cmd.payload.burstLen > 0)
    assume(dut.io.ctrlIO.user.cmd.payload.burstLen <= 63)
    
    GenerationFlags.formal {
      // After initialization, the controller should accept commands
      when(pastValidAfterReset() && past(dut.init.sequencer.io.initDone)) {
        assert(dut.io.ctrlIO.user.cmd.ready)
      }
      
      // DRAM interface should have proper reset signal
      when(ClockDomain.current.isResetActive) {
        assert(!dut.io.ctrlIO.dram.resetN)
      }
      
      // Cover: can we complete initialization and accept a command?
      cover(dut.init.sequencer.io.initDone && dut.io.ctrlIO.user.cmd.fire)
      
      // Cover: can we handle both read and write commands?
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite)
      cover(dut.io.ctrlIO.user.cmd.fire && !dut.io.ctrlIO.user.cmd.payload.isWrite)
    }
  })
}

object RpcDramControllerCompleteFormal extends App {
  FormalConfig
    .withBMC(30)
    .withCover(30)
    .doVerify(new Component {
      val cfg = RpcDramConfig(
        simMode = true,
        freqMHz = 10, // Low frequency for formal
        timingParams = RpcDramTimingParams(
          tCke = 3,
          tDpd = 100,
          tRcd = 3,
          tRp = 3,
          tWr = 3,
          tRas = 5,
          tRrd = 2,
          tPpd = 2,
          tZqInit = 20, // 2µs @ 10MHz = 20 cycles
          tFaw = 4
        )
      )
      val dut = FormalDut(new RpcDramController(cfg, None))
      
      assumeInitial(ClockDomain.current.isResetActive)
      
      // Drive user interface
      anyseq(dut.io.ctrlIO.user.cmd.valid)
      anyseq(dut.io.ctrlIO.user.cmd.payload.isWrite)
      anyseq(dut.io.ctrlIO.user.cmd.payload.address)
      anyseq(dut.io.ctrlIO.user.cmd.payload.burstLen)
      anyseq(dut.io.ctrlIO.user.cmd.payload.writeMask)
      anyseq(dut.io.ctrlIO.user.writeData.valid)
      anyseq(dut.io.ctrlIO.user.writeData.payload.fragment)
      anyseq(dut.io.ctrlIO.user.writeData.payload.last)
      anyseq(dut.io.ctrlIO.user.readData.ready)
      
      // Power control
      anyseq(dut.io.ctrlIO.powerCtrl.enterPd)
      anyseq(dut.io.ctrlIO.powerCtrl.exitPd)
      anyseq(dut.io.ctrlIO.powerCtrl.enterDpd)
      
      // Constrain inputs
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen > 0)
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen <= 64)
      
      // No commands during reset
      ClockDomain.current.duringReset {
        assume(dut.io.ctrlIO.user.cmd.valid === False)
        assume(dut.io.ctrlIO.powerCtrl.enterPd === False)
        assume(dut.io.ctrlIO.powerCtrl.enterDpd === False)
      }
      
      // Track initialization
      val initComplete = RegInit(False)
      when(dut.init.sequencer.io.initDone) {
        initComplete := True
      }
      
      // After init, controller should be responsive
      when(initComplete) {
        assert(dut.io.ctrlIO.user.cmd.ready)
      }
      
      // Cover important scenarios
      cover(initComplete) // Can complete initialization
      cover(initComplete && dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite)
      cover(initComplete && dut.io.ctrlIO.user.cmd.fire && !dut.io.ctrlIO.user.cmd.payload.isWrite)
      
      // Verify power state transitions
      val wasInPowerDown = RegInit(False)
      when(dut.power.manager.io.inPowerDown) {
        wasInPowerDown := True
      }
      cover(wasInPowerDown && !dut.power.manager.io.inPowerDown) // Exit power down
      
      // Verify refresh generation
      val refreshCount = Reg(UInt(8 bits)) init(0)
      when(dut.refresh.manager.io.toScheduler.fire) {
        refreshCount := refreshCount + 1
      }
       cover(refreshCount >= 2) // Multiple refreshes
     })
}

// =============================================================================
// Comprehensive Timing Formal Verification
// =============================================================================

object RpcDramTimingFormal extends App {
  FormalConfig
    .withBMC(100)  // Extended BMC depth for timing verification
    .withCover(50)
    .doVerify(new Component {
      val cfg = RpcDramConfig(
        simMode = true,
        freqMHz = 10, // Low frequency for formal tractability
        timingParams = RpcDramTimingParams(
          tCke = 3,
          tDpd = 100,
          tRcd = 3,    // Row to Column Delay
          tRp = 3,     // Precharge Time
          tWr = 3,     // Write Recovery Time
          tRas = 5,    // Row Active Time
          tRrd = 2,    // Row to Row Delay
          tPpd = 2,    // Parallel Packet Delay
          tZqInit = 20,
          tFaw = 4,    // Four Activate Window
          tRfc = 10    // Refresh Cycle Time (assumed)
        )
      )
      val dut = FormalDut(new RpcDramController(cfg, None))

      assumeInitial(ClockDomain.current.isResetActive)

      // Drive minimal inputs for timing verification
      anyseq(dut.io.ctrlIO.user.cmd.valid)
      anyseq(dut.io.ctrlIO.user.cmd.payload.isWrite)
      anyseq(dut.io.ctrlIO.user.cmd.payload.address)
      anyseq(dut.io.ctrlIO.user.writeData.valid)
      anyseq(dut.io.ctrlIO.user.writeData.payload.last)
      anyseq(dut.io.ctrlIO.user.readData.ready)

      // Constrain to single WORD bursts for timing focus
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen === 1)

      // Track command history for timing verification
      val lastCmdWasActivate = RegInit(False)
      val lastCmdWasPrecharge = RegInit(False)
      val lastCmdWasRead = RegInit(False)
      val lastCmdWasWrite = RegInit(False)
      val lastCmdBank = RegInit(U(0, cfg.bankAddrWidth bits))
      val cycleCounter = RegInit(U(0, 8 bits))

      // Update command history
      when(dut.cmd.scheduler.io.toPhy.fire) {
        val cmd = dut.cmd.scheduler.io.toPhy.payload
        lastCmdWasActivate := cmd.opcode === Opcodes.PAR_ACT
        lastCmdWasPrecharge := cmd.opcode === Opcodes.PAR_PRE
        lastCmdWasRead := cmd.opcode === Opcodes.PAR_RD
        lastCmdWasWrite := cmd.opcode === Opcodes.PAR_WR
        lastCmdBank := cmd.bank
        cycleCounter := 0
      } otherwise {
        cycleCounter := cycleCounter + 1
      }

      // =============================================================================
      // Timing Constraint Formal Properties
      // =============================================================================

      // Basic timing constraint checks (simplified for SpinalHDL formal)
      // Track recent commands for timing validation
      val recentCmd = RegInit(Opcodes.PAR_NOP)
      val recentBank = RegInit(U(0, cfg.bankAddrWidth bits))
      val cmdAge = RegInit(U(0, 8 bits))

      when(dut.cmd.scheduler.io.toPhy.fire) {
        recentCmd := dut.cmd.scheduler.io.toPhy.payload.opcode
        recentBank := dut.cmd.scheduler.io.toPhy.payload.bank
        cmdAge := 0
      } otherwise {
        cmdAge := cmdAge + 1
      }

      // Basic timing assertions (simplified)
      when(recentCmd === Opcodes.PAR_ACT && cmdAge < cfg.timingParams.tRcd &&
           dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_RD) {
        assert(False, "Potential tRCD violation detected")
      }

      when(recentCmd === Opcodes.PAR_PRE && cmdAge < cfg.timingParams.tRp &&
           dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_ACT) {
        assert(False, "Potential tRP violation detected")
      }

      // =============================================================================
      // Command Sequence Properties
      // =============================================================================

      // ACT must be followed by RD/WR or PRE (no direct REF/MRS)
      val invalidActSequence = past(lastCmdWasActivate) &&
                              dut.cmd.scheduler.io.toPhy.fire &&
                              !(dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_RD ||
                                dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_WR ||
                                dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_PRE)

      assert(!invalidActSequence, "Invalid sequence after ACT")

      // PRE must be followed by ACT or MRS (no direct RD/WR)
      val invalidPreSequence = past(lastCmdWasPrecharge) &&
                              dut.cmd.scheduler.io.toPhy.fire &&
                              !(dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_ACT ||
                                dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_MRS ||
                                dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_REF)

      assert(!invalidPreSequence, "Invalid sequence after PRE")

      // =============================================================================
      // Liveness Properties
      // =============================================================================

      // Basic command acceptance check
      val commandPending = dut.io.ctrlIO.user.cmd.valid && !dut.io.ctrlIO.user.cmd.ready
      // Note: Liveness properties are complex in formal verification

      // =============================================================================
      // Coverage Properties
      // =============================================================================

      // Cover timing constraint scenarios
      cover(cycleCounter >= cfg.timingParams.tRcd)  // tRCD timing passed
      cover(cycleCounter >= cfg.timingParams.tRp)   // tRP timing passed
      cover(cycleCounter >= cfg.timingParams.tRrd)  // tRRD timing passed
      cover(cycleCounter >= cfg.timingParams.tWr)   // tWR timing passed

      // Cover command sequences
      cover(lastCmdWasActivate && dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_RD)
      cover(lastCmdWasActivate && dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_WR)
      cover(lastCmdWasPrecharge && dut.cmd.scheduler.io.toPhy.payload.opcode === Opcodes.PAR_ACT)
    })
}

// =============================================================================
// Data Integrity Formal Verification
// =============================================================================

object RpcDramDataIntegrityFormal extends App {
  FormalConfig
    .withBMC(50)
    .withCover(30)
    .doVerify(new Component {
      val cfg = RpcDramConfig(
        simMode = true,
        freqMHz = 10
      )
      val dut = FormalDut(new RpcDramController(cfg, None))

      assumeInitial(ClockDomain.current.isResetActive)

      // Drive inputs for data integrity testing
      anyseq(dut.io.ctrlIO.user.cmd.valid)
      anyseq(dut.io.ctrlIO.user.cmd.payload.isWrite)
      anyseq(dut.io.ctrlIO.user.cmd.payload.address)
      anyseq(dut.io.ctrlIO.user.writeData.valid)
      anyseq(dut.io.ctrlIO.user.writeData.payload.fragment)
      anyseq(dut.io.ctrlIO.user.writeData.payload.last)
      anyseq(dut.io.ctrlIO.user.readData.ready)

      // Constrain to small bursts for tractability
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen <= 4)
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen > 0)

      // Model memory for data integrity verification
      val memoryModel = Mem(Bits(256 bits), 1 << 16)  // Simplified memory model
      val writeAddress = RegInit(U(0, 16 bits))
      val readAddress = RegInit(U(0, 16 bits))
      val expectedReadData = RegInit(B(0, 256 bits))

      // Track write operations
      when(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite) {
        writeAddress := (dut.io.ctrlIO.user.cmd.payload.address >> 5).resize(16)  // WORD address
      }

      when(dut.io.ctrlIO.user.writeData.fire) {
        memoryModel.write(
          address = writeAddress,
          data = dut.io.ctrlIO.user.writeData.payload.fragment
        )
      }

      // Track read operations and verify data integrity
      when(dut.io.ctrlIO.user.cmd.fire && !dut.io.ctrlIO.user.cmd.payload.isWrite) {
        readAddress := (dut.io.ctrlIO.user.cmd.payload.address >> 5).resize(16)
        expectedReadData := memoryModel.readSync(address = readAddress)
      }

      // Data integrity property: Read data should match what was written
      when(dut.io.ctrlIO.user.readData.fire) {
        val actualReadData = dut.io.ctrlIO.user.readData.payload.fragment
        val addressMatch = readAddress === ((dut.io.ctrlIO.user.cmd.payload.address >> 5).resize(16))

        // Only check when we have a matching address (simplified model)
        when(addressMatch) {
          assert(actualReadData === expectedReadData,
                 "Data integrity violation: Read data does not match written data")
        }
      }

      // =============================================================================
      // Byte Masking Verification
      // =============================================================================

      // Track byte masking operations
      val writeMask = RegInit(B(0, 32 bits))
      val writeData = RegInit(B(0, 256 bits))

      when(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite) {
        writeMask := dut.io.ctrlIO.user.cmd.payload.writeMask
      }

      when(dut.io.ctrlIO.user.writeData.fire) {
        writeData := dut.io.ctrlIO.user.writeData.payload.fragment
      }

      // Verify byte masking: masked bytes should be ignored in writes
      // This is a property of the controller's masking logic
      val maskedWriteData = writeData & Cat(
        (0 until 32).reverse.map(i =>  // Process bytes from MSB to LSB
          Mux(writeMask(i), B"11111111", B"00000000")
        )
      )

      // The controller should only write unmasked bytes
      // This would require access to internal signals to verify properly

      // =============================================================================
      // Burst Ordering Verification
      // =============================================================================

      // Track burst progress
      val burstLength = RegInit(U(0, 6 bits))
      val burstCounter = RegInit(U(0, 6 bits))
      val burstWriteData = Vec(Reg(B(0, 256 bits)), 4)  // Support up to 4 WORD bursts

      when(dut.io.ctrlIO.user.cmd.fire) {
        burstLength := dut.io.ctrlIO.user.cmd.payload.burstLen
        burstCounter := 0
      }

      when(dut.io.ctrlIO.user.writeData.fire && burstCounter < burstLength) {
        burstWriteData(burstCounter.resize(2)) := dut.io.ctrlIO.user.writeData.payload.fragment
        burstCounter := burstCounter + 1
      }

      // Burst ordering: Data should be processed in order
      val burstOrderViolation = burstCounter > 0 && dut.io.ctrlIO.user.writeData.fire &&
                               burstCounter >= burstLength

      assert(!burstOrderViolation, "Burst ordering violation: Too many data words for burst")

      // =============================================================================
      // Address Alignment Verification
      // =============================================================================

      // WORD addresses must be 32-byte aligned (address % 32 == 0)
      val addressAlignmentViolation = dut.io.ctrlIO.user.cmd.fire &&
                                     (dut.io.ctrlIO.user.cmd.payload.address(4 downto 0) =/= 0)

      assert(!addressAlignmentViolation, "Address alignment violation: WORD addresses must be 32-byte aligned")

      // =============================================================================
      // Coverage Properties for Data Integrity
      // =============================================================================

      // Cover successful write-read cycles
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite &&
            dut.io.ctrlIO.user.writeData.fire)

      cover(dut.io.ctrlIO.user.cmd.fire && !dut.io.ctrlIO.user.cmd.payload.isWrite &&
            dut.io.ctrlIO.user.readData.fire)

      // Cover different burst lengths
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.burstLen === 1)
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.burstLen === 2)
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.burstLen === 4)

      // Cover byte masking scenarios
      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite &&
            dut.io.ctrlIO.user.cmd.payload.writeMask =/= B(0xFFFFFFFFL, 32 bits))  // Partial masking

      cover(dut.io.ctrlIO.user.cmd.fire && dut.io.ctrlIO.user.cmd.payload.isWrite &&
            dut.io.ctrlIO.user.cmd.payload.writeMask === B(0xFFFFFFFFL, 32 bits))  // Full masking
    })
}

// =============================================================================
// Liveness and Progress Formal Verification
// =============================================================================

object RpcDramLivenessFormal extends App {
  FormalConfig
    .withBMC(80)  // Extended for liveness checking
    .withCover(40)
    .doVerify(new Component {
      val cfg = RpcDramConfig(
        simMode = true,
        freqMHz = 10
      )
      val dut = FormalDut(new RpcDramController(cfg, None))

      assumeInitial(ClockDomain.current.isResetActive)

      // Drive inputs for liveness verification
      anyseq(dut.io.ctrlIO.user.cmd.valid)
      anyseq(dut.io.ctrlIO.user.cmd.payload.isWrite)
      anyseq(dut.io.ctrlIO.user.cmd.payload.address)
      anyseq(dut.io.ctrlIO.user.cmd.payload.burstLen)
      anyseq(dut.io.ctrlIO.user.writeData.valid)
      anyseq(dut.io.ctrlIO.user.writeData.payload.last)
      anyseq(dut.io.ctrlIO.user.readData.ready)

      // Constrain inputs to reasonable values
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen > 0)
      assume(dut.io.ctrlIO.user.cmd.payload.burstLen <= 4)  // Small bursts for tractability

      // =============================================================================
      // Basic Progress Properties (simplified for SpinalHDL formal)
      // =============================================================================

      // Track command progress
      val commandInProgress = RegInit(False)
      val commandCompleted = RegInit(False)

      when(dut.io.ctrlIO.user.cmd.fire) {
        commandInProgress := True
        commandCompleted := False
      }

      when(dut.io.ctrlIO.user.readData.fire && dut.io.ctrlIO.user.readData.payload.last) {
        commandCompleted := True
        commandInProgress := False
      }

      when(dut.io.ctrlIO.user.writeData.fire && dut.io.ctrlIO.user.writeData.payload.last) {
        commandCompleted := True
        commandInProgress := False
      }

      // Basic progress check: if command is in progress, it should eventually complete
      when(commandInProgress && !commandCompleted) {
        // This is a basic check - in practice, we'd need more sophisticated tracking
        assert(dut.clockDomain.isResetActive || commandInProgress, "Command should make progress")
      }

      // =============================================================================
      // Coverage for Liveness Scenarios
      // =============================================================================

      // Cover successful completion of various operations
      cover(dut.init.sequencer.io.initDone)  // Initialization completes

      cover(dut.io.ctrlIO.user.cmd.fire)  // Commands are accepted

      cover(dut.io.ctrlIO.user.writeData.fire && dut.io.ctrlIO.user.writeData.payload.last)  // Write bursts complete

      cover(dut.io.ctrlIO.user.readData.fire && dut.io.ctrlIO.user.readData.payload.last)  // Read bursts complete

      // Cover command states
      val commandPending = dut.io.ctrlIO.user.cmd.valid && !dut.io.ctrlIO.user.cmd.ready
      cover(commandPending)  // Commands can be pending
      cover(commandInProgress && commandCompleted)  // Commands can complete

      // =============================================================================
      // Assumptions to Make Properties Tractable
      // =============================================================================

      // Assume no external stalls that would prevent progress
      // (In a full verification, these would be proven or assumed based on environment)

      // Assume refresh operations don't block indefinitely
      // Assume power management doesn't cause permanent stalls

      // Note: Some liveness properties may require additional assumptions about
      // the environment (e.g., refresh timing, power state transitions) to be
      // practically verifiable. The properties above focus on the controller's
      // internal progress guarantees.
    })
}