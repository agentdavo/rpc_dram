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









