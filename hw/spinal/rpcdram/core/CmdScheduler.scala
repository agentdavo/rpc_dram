package rpcdram.core

import rpcdram.{RpcDramConfig, RpcDramTiming, UserBus}
import rpcdram.utils.{CommandDefaults, CommandUtils, DramCmd, Opcodes}
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

// Bank tracker interfaces
case class BankActivateCmd(cfg: RpcDramConfig) extends Bundle {
  val bank = UInt(cfg.bankAddrWidth bits)
  val rowAddr = UInt(cfg.rowAddrWidth bits)
}

case class BankTrackerCmd(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val activate = Stream(BankActivateCmd(cfg))
  val precharge = Stream(UInt(cfg.bankAddrWidth bits))
  
  override def asMaster(): Unit = {
    master(activate, precharge)
  }
}

case class BankTrackerStatus(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val bankStates = Vec(BankState(), cfg.bankCount)
  val openRow = Vec(UInt(cfg.rowAddrWidth bits), cfg.bankCount)
  
  override def asMaster(): Unit = {
    out(bankStates, openRow)
  }
}

/**
 * Command Scheduler with Chapter 8 Command Sequencing Rules
 * 
 * Implements Tables 8-1 through 8-8 from the Etron datasheet:
 * - Table 8-1: Parallel to Serial (Same Bank)
 * - Table 8-2: Parallel to Serial (Different Bank)
 * - Table 8-3: Parallel to Parallel (Same Bank)
 * - Table 8-4: Parallel to Parallel (Different Bank)
 * - Table 8-5: Serial to Serial (Same Bank)
 * - Table 8-6: Serial to Serial (Different Bank)
 * - Table 8-7: Serial to Parallel (Same Bank)
 * - Table 8-8: Serial to Parallel (Different Bank)
 * 
 * Critical timing enforcement:
 * - tRCD: Row to Column Delay
 * - tRP: Precharge Time
 * - tRAS: Row Active Time
 * - tRRD: Row to Row Delay
 * - tPPD: Parallel Packet Delay (8 cycles in Active state)
 * - tRFC: Refresh Cycle Time (missing from datasheet, assumed 88 cycles)
 * - tFAW: Four Activate Window
 * - tWR: Write Recovery Time
 * 
 * State requirements:
 * - ACTIVATE requires bank precharged (Note 5)
 * - PRECHARGE requires bank active (Note 11)
 * - MRS requires all banks precharged (Note 7)
 * - REFRESH can be issued anytime but blocks all other commands
 */
case class CmdScheduler(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val user = slave(UserBus(cfg))
    val initCmd = slave Stream(DramCmd(cfg))
    val refreshCmd = slave Stream(DramCmd(cfg))
    val powerCmd = slave Stream(DramCmd(cfg))
    val toPhy = master Stream(DramCmd(cfg))
    val toBankTracker = master(BankTrackerCmd(cfg))
    val fromBankTracker = slave(BankTrackerStatus(cfg))
    val fromPhy = slave Stream(Bool())
    val initDone = in Bool()
    val currentTiming = in(RpcDramTiming())
     val debugInfo = out(new Bundle {
       val currentState = Bits(4 bits)
       val timingViolation = Bool()
       val illegalTransition = Bool()
       val burstCountExceeded = Bool()
       val cmdSource = UInt(3 bits)
       val pendingOpcode = Bits(6 bits)
       val validationLegal = Bool()
       val validationDone = Bool()
       val bubbleNopActive = Bool()
       val serialCmdLimitViolated = Bool()
       // Performance monitoring
       val totalCommands = UInt(32 bits)
       val timingViolations = UInt(16 bits)
       val illegalTransitions = UInt(16 bits)
       val burstLimitViolations = UInt(16 bits)
     })
     val utrStatus = out(new Bundle {
       val enabled = Bool()
       val op = Bits(2 bits)
     })
  }

  // =============================================================================
  // Address Decode Pipeline - Break Critical Path
  // =============================================================================
  
  // Pre-decode addresses to break timing critical path
  val addrDecodeArea = new Area {
    val rank = Reg(UInt(cfg.rankAddrWidth bits)) init(0)
    val bank = Reg(UInt(cfg.bankAddrWidth bits)) init(0)
    val rowAddr = Reg(UInt(cfg.rowAddrWidth bits)) init(0)
    val colAddr = Reg(UInt(cfg.colAddrWidth bits)) init(0)
    val needsActivate = Reg(Bool()) init(False)
    val addrValid = Reg(Bool()) init(False)
    val userCmdBuffered = Reg(Bool()) init(False)
    
    // Two-stage pipeline to break critical path:
    // Stage 1: Buffer user command and decode address
    when(io.user.cmd.valid && !userCmdBuffered) {
      // Maintain backward compatibility with existing address layout: [row][bank][col][byte]
      // For multi-rank, insert rank bits at MSB
      val rankMsb = 29  // Rank starts at bit 29 (MSB of 30-bit space, since address is 32-bit but we use 29)
      val rankLsb = 30 - cfg.rankAddrWidth

      if (cfg.rankAddrWidth > 0) {
        rank := io.user.cmd.address(rankMsb downto rankLsb)
      } else {
        rank := 0
      }

      // Original bit positions for backward compatibility
      bank := io.user.cmd.address(13 downto 12)
      rowAddr := io.user.cmd.address(25 downto 14)
      colAddr := io.user.cmd.address(11 downto 2)
      userCmdBuffered := True
    }
    
    // Stage 2: Check bank state and set valid (one cycle later)
    when(userCmdBuffered && !addrValid) {
      val currentBank = bank
      val currentRow = rowAddr
      needsActivate := io.fromBankTracker.bankStates(currentBank) =/= BankState.ACTIVE ||
                      io.fromBankTracker.openRow(currentBank) =/= currentRow
      addrValid := True
    }
    
    // Reset when command is actually accepted (handshake completes)
    when(addrValid && io.user.cmd.valid && io.user.cmd.ready) {
      addrValid := False
      userCmdBuffered := False
    }
  }

  // =============================================================================
  // Command Validation Pipeline - Break Critical Path
  // =============================================================================
  
  // Pipeline command validation to break timing critical path
  val cmdValidationArea = new Area {
    val isLegal = Reg(Bool()) init(True)
    val validationDone = Reg(Bool()) init(False)
    val burstCountValid = Reg(Bool()) init(True)
    val lastValidatedCmd = Reg(DramCmd(cfg)) init(CommandUtils.createDefaultCmd(cfg))
  }

  // Command tracking
  case class CmdTracker() extends Bundle {
    val lastCmd = Reg(Bits(6 bits)) init(Opcodes.PAR_NOP)
    val lastBank = Reg(UInt(cfg.bankAddrWidth bits)) init(0)
    val isSerial = Reg(Bool()) init(False)
    val burstCount = Reg(UInt(6 bits)) init(0)
    val serialCmdCount = Reg(UInt(6 bits)) init(0)
    val inBurst = Reg(Bool()) init(False)
    val afterBurstStop = Reg(Bool()) init(False)
    val afterToggle = Reg(Bool()) init(False)
    val bubbleNopCounter = Reg(UInt(7 bits)) init(0) // Max 80 cycles (Note 9.1)
    val inBubbleNop = Reg(Bool()) init(False)
    val utrEnabled = Reg(Bool()) init(False) // UTR mode enabled
    val utrOp = Reg(Bits(2 bits)) init(0)     // UTR operation mode
  }

  val cmdTracker = CmdTracker()

  // Performance monitoring counters
  val perfCounters = new Area {
    val totalCommands = Reg(UInt(32 bits)) init(0)
    val timingViolations = Reg(UInt(16 bits)) init(0)
    val illegalTransitions = Reg(UInt(16 bits)) init(0)
    val burstLimitViolations = Reg(UInt(16 bits)) init(0)
    val refreshCycles = Reg(UInt(16 bits)) init(0)
  }

  // Timing counters based on datasheet + assumed tRFC
   // Use register duplication for better timing distribution
   val timingCounters = new Area {
     // Reduce counter sizes to minimum required (save LUTs)
     val tRcdCounter = Counter(32)  // tRcd max 12, use 32 for safety
     val tRpCounter = Counter(32)   // tRp max 12
     val tRasCounter = Counter(64)  // tRas max 30
     val tRrdCounter = Counter(16)  // tRrd max 6
     val tPpdCounter = Counter(16)  // tPpd max 8
     val tRfcCounter = Counter(128) // tRfc max 88
     val tFawCounter = Counter(64)  // tFaw max 24
     val tWrCounter = Counter(32)   // tWr max 12

     // Reduce duplication from 4 to 2 to save registers
     val currentTRcd_dup = Vec.fill(2)(RegNext(io.currentTiming.tRcd))
     val currentTRp_dup = Vec.fill(2)(RegNext(io.currentTiming.tRp))
     val currentTRas_dup = Vec.fill(2)(RegNext(io.currentTiming.tRas))

     // Current timing values from config (use duplicated registers)
     val currentTRcd = currentTRcd_dup(0)
     val currentTRp = currentTRp_dup(0)
     val currentTRas = currentTRas_dup(0)
     val currentTRrd = RegNext(io.currentTiming.tRrd)
     val currentTPpd = RegNext(io.currentTiming.tPpd)
     val currentTRfc = RegNext(io.currentTiming.tRfc)
     val currentTFaw = RegNext(io.currentTiming.tFaw)
     val currentTWr = RegNext(io.currentTiming.tWr)

    // Track activate window for tFAW
    val activateHistory = Vec(Reg(Bool()) init(False), 4)
    val activateCount = activateHistory.map(_.asUInt).reduce(_ +^ _)

    def allTimersSatisfied: Bool = {
      (tRcdCounter.value >= currentTRcd) &&
      (tRpCounter.value >= currentTRp) &&
      (tRasCounter.value >= currentTRas) &&
      (tRrdCounter.value >= currentTRrd) &&
      (tPpdCounter.value >= currentTPpd) &&
      (tRfcCounter.value >= currentTRfc) &&
      (tWrCounter.value >= currentTWr)
    }

    def tRcdSatisfied: Bool = tRcdCounter.value >= currentTRcd
    def tRpSatisfied: Bool = tRpCounter.value >= currentTRp
    def tRasSatisfied: Bool = tRasCounter.value >= currentTRas
    def tRrdSatisfied: Bool = tRrdCounter.value >= currentTRrd
    def tPpdSatisfied: Bool = tPpdCounter.value >= currentTPpd
    def tRfcSatisfied: Bool = tRfcCounter.value >= currentTRfc
    def tFawSatisfied: Bool = (activateCount < 4) || (tFawCounter.value >= currentTFaw)
  }

  // Command validation logic per Tables 8-1 through 8-8
  // =============================================================================
  // Command Transition Validation - Refactored for Clarity
  // =============================================================================

  // Table 8-1: Parallel to Serial (Same Bank)
  def validateParallelToSerialSameBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.PAR_RD, Opcodes.PAR_WR) {
        switch(nextOpcode) {
          is(Opcodes.SER_TG2R.resize(6), Opcodes.SER_TG2W.resize(6)) { legal := True } // Toggle allowed
          is(Opcodes.SER_BST.resize(6)) { legal := True } // BST allowed
          is(Opcodes.SER_REF.resize(6)) { legal := True } // REF allowed
          default { legal := False } // Others illegal during burst
        }
      }
      is(Opcodes.PAR_ACT, Opcodes.PAR_PRE, Opcodes.PAR_REF, Opcodes.PAR_MRS) {
        legal := False // Must wait for timing completion
      }
      default { legal := True }
    }

    legal
  }

  // Table 8-2: Parallel to Serial (Different Bank)
  def validateParallelToSerialDifferentBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.PAR_RD, Opcodes.PAR_WR) {
        switch(nextOpcode) {
          is(Opcodes.SER_RD.resize(6), Opcodes.SER_WR.resize(6)) {
            legal := cmdTracker.serialCmdCount < cmdTracker.burstCount // Within burst count (Notes 3,4)
          }
          is(Opcodes.SER_ACT.resize(6), Opcodes.SER_PRE.resize(6)) { legal := True } // Pipelined allowed
          is(Opcodes.SER_TG2R.resize(6), Opcodes.SER_TG2W.resize(6), Opcodes.SER_BST.resize(6), Opcodes.SER_REF.resize(6)) { legal := True }
          default { legal := False }
        }
      }
      default { legal := False } // Timing constraints apply
    }

    legal
  }

  // Table 8-3: Parallel to Parallel (Same Bank)
  def validateParallelToParallelSameBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.PAR_RD, Opcodes.PAR_WR) {
        switch(nextOpcode) {
          is(Opcodes.PAR_PRE) { legal := !cmdTracker.inBurst } // After burst
          is(Opcodes.PAR_REF) { legal := !cmdTracker.inBurst }
          default { legal := False }
        }
      }
      is(Opcodes.PAR_ACT) {
        switch(nextOpcode) {
          is(Opcodes.PAR_RD, Opcodes.PAR_WR) { legal := timingCounters.tRcdSatisfied }
          is(Opcodes.PAR_PRE) { legal := timingCounters.tRasSatisfied }
          default { legal := False }
        }
      }
      is(Opcodes.PAR_PRE) {
        switch(nextOpcode) {
          is(Opcodes.PAR_ACT) { legal := timingCounters.tRpSatisfied }
          is(Opcodes.PAR_MRS) { legal := allBanksPrecharged() }
          is(Opcodes.PAR_REF) { legal := True }
          default { legal := False }
        }
      }
      default { legal := False }
    }

    legal
  }

  // Table 8-4: Parallel to Parallel (Different Bank)
  def validateParallelToParallelDifferentBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.PAR_RD, Opcodes.PAR_WR) {
        legal := !cmdTracker.inBurst && timingCounters.tPpdSatisfied
      }
      is(Opcodes.PAR_ACT) {
        switch(nextOpcode) {
          is(Opcodes.PAR_ACT) {
            legal := timingCounters.tRrdSatisfied && timingCounters.tFawSatisfied
          }
          default { legal := True }
        }
      }
      default { legal := True }
    }

    legal
  }

  // Table 8-5: Serial to Serial (Same Bank)
  def validateSerialToSerialSameBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.SER_RD.resize(6), Opcodes.SER_WR.resize(6)) {
        switch(nextOpcode) {
          is(Opcodes.SER_TG2R.resize(6), Opcodes.SER_TG2W.resize(6)) { legal := True }
          is(Opcodes.SER_BST.resize(6), Opcodes.SER_REF.resize(6)) { legal := True }
          default { legal := False }
        }
      }
      is(Opcodes.SER_TG2R.resize(6), Opcodes.SER_TG2W.resize(6)) {
        switch(nextOpcode) {
          is(Opcodes.SER_RD.resize(6), Opcodes.SER_WR.resize(6)) { legal := cmdTracker.afterToggle }
          is(Opcodes.SER_BST.resize(6)) { legal := True }
          default { legal := False }
        }
      }
      default { legal := False }
    }

    legal
  }

  // Table 8-6: Serial to Serial (Different Bank)
  def validateSerialToSerialDifferentBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    True // Generally allowed to different banks
  }

  // Table 8-7: Serial to Parallel (Same Bank)
  def validateSerialToParallelSameBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.SER_BST.resize(6)) {
        legal := timingCounters.tPpdSatisfied // Note 6
      }
      default { legal := False } // Must terminate with BST/REF
    }

    legal
  }

  // Table 8-8: Serial to Parallel (Different Bank)
  def validateSerialToParallelDifferentBank(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val legal = Bool()

    switch(currentOpcode) {
      is(Opcodes.SER_BST.resize(6)) {
        legal := timingCounters.tPpdSatisfied // Note 6
      }
      default { legal := False } // Must terminate with BST/REF
    }

    legal
  }

  // Main validation function using pattern matching for clarity
  def validateCommandTransition(currentCmd: DramCmd, nextCmd: DramCmd): Bool = {
    val currentOpcode = currentCmd.opcode
    val nextOpcode = nextCmd.opcode
    val sameBank = currentCmd.bank === nextCmd.bank
    val currentIsSerial = currentCmd.isSerial
    val nextIsSerial = nextCmd.isSerial

    // Special cases for NOP and RESET commands (fast path)
    val isSpecial = (currentOpcode === Opcodes.PAR_NOP) ||
                    (nextOpcode === Opcodes.PAR_NOP) ||
                    (nextOpcode === Opcodes.PAR_RESET) ||
                    (nextOpcode === Opcodes.PAR_ZQ) ||
                    (nextOpcode === Opcodes.PAR_REF)

    // Use conditional logic for table selection (SpinalHDL doesn't support pattern matching with Bool)
    val legal = Bool()

    when(isSpecial) {
      legal := True
    }.elsewhen(!currentIsSerial && nextIsSerial && sameBank) {
      legal := validateParallelToSerialSameBank(currentCmd, nextCmd)
    }.elsewhen(!currentIsSerial && nextIsSerial && !sameBank) {
      legal := validateParallelToSerialDifferentBank(currentCmd, nextCmd)
    }.elsewhen(!currentIsSerial && !nextIsSerial && sameBank) {
      legal := validateParallelToParallelSameBank(currentCmd, nextCmd)
    }.elsewhen(!currentIsSerial && !nextIsSerial && !sameBank) {
      legal := validateParallelToParallelDifferentBank(currentCmd, nextCmd)
    }.elsewhen(currentIsSerial && nextIsSerial && sameBank) {
      legal := validateSerialToSerialSameBank(currentCmd, nextCmd)
    }.elsewhen(currentIsSerial && nextIsSerial && !sameBank) {
      legal := validateSerialToSerialDifferentBank(currentCmd, nextCmd)
    }.elsewhen(currentIsSerial && !nextIsSerial && sameBank) {
      legal := validateSerialToParallelSameBank(currentCmd, nextCmd)
    }.elsewhen(currentIsSerial && !nextIsSerial && !sameBank) {
      legal := validateSerialToParallelDifferentBank(currentCmd, nextCmd)
    }.otherwise {
      legal := False
    }

    legal
  }
  
  def allBanksPrecharged(): Bool = {
    io.fromBankTracker.bankStates.map(_ === BankState.IDLE).reduce(_ && _)
  }

  // Main FSM for command scheduling - Consolidated into 3 phases
  val fsm = new StateMachine {
    // Phase 1: Idle - Waiting for work
    val idlePhase = new State

    // Phase 2: Command Processing - Validate, check timing, issue commands
    val commandPhase = new State

    // Phase 3: Wait - Wait for burst completion, timing, or bubble NOPs
    val waitPhase = new State

    // Sub-state tracking within phases
    val phaseSubState = RegInit(U(0, 2 bits)) // 0=idle, 1=validate, 2=check, 3=issue
    
    // Command arbitration with priority
    val pendingCmd = Reg(DramCmd(cfg)) init(CommandUtils.createDefaultCmd(cfg))
    pendingCmd.odt init(False)
    
    val cmdSource = Reg(UInt(3 bits)) init(0) // 0=init, 1=refresh, 2=power, 3=user
    
    // Simplified state encoding for debugging
    io.debugInfo.currentState := phaseSubState ## B"00"

    val timingViolation = !timingCounters.allTimersSatisfied && cmdTracker.lastCmd =/= Opcodes.PAR_NOP
    io.debugInfo.timingViolation := timingViolation

    // Increment timing violation counter on detection
    when(timingViolation && !RegNext(timingViolation)) {
      perfCounters.timingViolations := perfCounters.timingViolations + 1
    }
    io.debugInfo.illegalTransition := False
    io.debugInfo.burstCountExceeded := False
    io.debugInfo.cmdSource := cmdSource
    io.debugInfo.pendingOpcode := pendingCmd.opcode
    io.debugInfo.validationLegal := cmdValidationArea.isLegal
    io.debugInfo.validationDone := cmdValidationArea.validationDone
    io.debugInfo.bubbleNopActive := cmdTracker.inBubbleNop
    io.debugInfo.serialCmdLimitViolated := cmdTracker.serialCmdCount > cmdTracker.burstCount
    // Performance monitoring outputs
     io.debugInfo.totalCommands := perfCounters.totalCommands
     io.debugInfo.timingViolations := perfCounters.timingViolations
     io.debugInfo.illegalTransitions := perfCounters.illegalTransitions
     io.debugInfo.burstLimitViolations := perfCounters.burstLimitViolations

     // UTR status
     io.utrStatus.enabled := cmdTracker.utrEnabled
     io.utrStatus.op := cmdTracker.utrOp
    
    // Default outputs
    io.toPhy.valid := False
    io.toPhy.payload := pendingCmd
    io.user.cmd.ready := False
    io.initCmd.ready := False
    io.refreshCmd.ready := False
    io.powerCmd.ready := False
    io.fromPhy.ready := True
    io.toBankTracker.activate.valid := False
    io.toBankTracker.activate.payload.bank := 0
    io.toBankTracker.activate.payload.rowAddr := 0
    io.toBankTracker.precharge.valid := False
    io.toBankTracker.precharge.payload := 0
    
    idlePhase.whenIsActive {
      phaseSubState := 0 // idle substate

      // Block new commands during bubble NOPs (Note 9)
      val canAcceptCommands = !cmdTracker.inBubbleNop

       // Priority arbitration - transition to command phase
       when(io.initCmd.valid) {
         pendingCmd := io.initCmd.payload
         io.initCmd.ready := True
         cmdSource := 0
         phaseSubState := 1 // validate substate
         goto(commandPhase)
      } elsewhen(io.refreshCmd.valid && canAcceptCommands) {
        pendingCmd := io.refreshCmd.payload
        io.refreshCmd.ready := True
        cmdSource := 1
        phaseSubState := 1 // validate substate
        goto(commandPhase)
      } elsewhen(io.powerCmd.valid && canAcceptCommands) {
        pendingCmd := io.powerCmd.payload
        io.powerCmd.ready := True
        cmdSource := 2
        phaseSubState := 1 // validate substate
        goto(commandPhase)
      } elsewhen(io.user.cmd.valid && io.initDone && addrDecodeArea.addrValid && canAcceptCommands) {
        // Use pipelined address decode to break critical path
        when(addrDecodeArea.needsActivate) {
          pendingCmd.isSerial := False
          pendingCmd.opcode := Opcodes.PAR_ACT
          pendingCmd.rank := addrDecodeArea.rank
          pendingCmd.bank := addrDecodeArea.bank
          pendingCmd.rowAddr := addrDecodeArea.rowAddr
          pendingCmd.colAddr := 0
          pendingCmd.burstCount := 0
          pendingCmd.writeMask := 0
          pendingCmd.odt := False
        } otherwise {
          pendingCmd.isSerial := False
          pendingCmd.opcode := io.user.cmd.isWrite ? Opcodes.PAR_WR | Opcodes.PAR_RD
          pendingCmd.rank := addrDecodeArea.rank
          pendingCmd.bank := addrDecodeArea.bank
          pendingCmd.rowAddr := 0
          pendingCmd.colAddr := addrDecodeArea.colAddr
          pendingCmd.burstCount := io.user.cmd.burstLen
          pendingCmd.writeMask := io.user.cmd.writeMask
          pendingCmd.odt := io.user.cmd.isWrite
        }

        cmdSource := 3
        phaseSubState := 1 // validate substate
        goto(commandPhase)
      }
    }
    
    commandPhase.whenIsActive {
      // Handle sub-states within command phase
      switch(phaseSubState) {
        is(1) { // Validate substate
          // Create a pseudo-command for the last issued command
          val lastIssuedCmd = DramCmd(cfg)
          lastIssuedCmd.isSerial := cmdTracker.isSerial
          lastIssuedCmd.opcode := cmdTracker.lastCmd
          lastIssuedCmd.rank := 0
          lastIssuedCmd.bank := cmdTracker.lastBank
          lastIssuedCmd.rowAddr := 0
          lastIssuedCmd.colAddr := 0
          lastIssuedCmd.burstCount := 0
          lastIssuedCmd.writeMask := 0
          lastIssuedCmd.odt := False
          // Initialize MRS/UTR configs with defaults
          lastIssuedCmd.mrsConfig := CommandDefaults.defaultMrsConfig
          lastIssuedCmd.utrConfig := CommandDefaults.defaultUtrConfig

           // Compute validation results (one cycle latency to break critical path)
           val cmdLegal = validateCommandTransition(lastIssuedCmd, pendingCmd)
           val exceedsBurstCount = cmdTracker.inBurst &&
                                  pendingCmd.isSerial &&
                                  (pendingCmd.opcode === Opcodes.SER_RD.resize(6) ||
                                   pendingCmd.opcode === Opcodes.SER_WR.resize(6)) &&
                                  cmdTracker.serialCmdCount >= cmdTracker.burstCount

           // UTR mode restrictions: only RD commands allowed when UTR is enabled
           val utrLegal = !cmdTracker.utrEnabled ||
                         (pendingCmd.opcode === Opcodes.PAR_RD || pendingCmd.opcode === Opcodes.SER_RD.resize(6)) ||
                         (pendingCmd.opcode === Opcodes.PAR_UTR && !pendingCmd.utrConfig.utrEn) // Allow UTR disable

           // Store validation results for next substate
           cmdValidationArea.isLegal := cmdLegal && utrLegal
           cmdValidationArea.burstCountValid := !exceedsBurstCount
           cmdValidationArea.lastValidatedCmd := pendingCmd
           cmdValidationArea.validationDone := True

          // Advance to check substate
          phaseSubState := 2
        }

        is(2) { // Check timing substate
          // Use pipelined validation results to avoid combinational paths
          when(!cmdValidationArea.validationDone) {
            // Wait for validation to complete - stay in validate substate
            phaseSubState := 1
          } elsewhen(!cmdValidationArea.isLegal) {
            io.debugInfo.illegalTransition := True
            perfCounters.illegalTransitions := perfCounters.illegalTransitions + 1
            cmdValidationArea.validationDone := False // Reset for next command
            phaseSubState := 0
            goto(idlePhase) // Reject illegal command
          } elsewhen(cmdTracker.serialCmdCount > cmdTracker.burstCount) {
            io.debugInfo.serialCmdLimitViolated := True
            perfCounters.burstLimitViolations := perfCounters.burstLimitViolations + 1
            cmdValidationArea.validationDone := False // Reset for next command
            phaseSubState := 0
            goto(idlePhase) // Reject command exceeding burst limit
          } elsewhen(!cmdValidationArea.burstCountValid) {
            io.debugInfo.burstCountExceeded := True
            cmdValidationArea.validationDone := False // Reset for next command
            phaseSubState := 0
            goto(idlePhase) // Reject command
          } otherwise {
            cmdValidationArea.validationDone := False // Reset for next command
            phaseSubState := 3 // Advance to issue substate
          }
        }

        is(3) { // Issue command substate
          // Issue command to PHY
          io.toPhy.valid := True

          when(io.toPhy.ready) {
            // Update performance counters
            perfCounters.totalCommands := perfCounters.totalCommands + 1

            // Update command tracker
            cmdTracker.lastCmd := pendingCmd.opcode
            cmdTracker.lastBank := pendingCmd.bank
            cmdTracker.isSerial := pendingCmd.isSerial

            // Update burst tracking
            when(pendingCmd.opcode === Opcodes.PAR_RD || pendingCmd.opcode === Opcodes.PAR_WR) {
              cmdTracker.inBurst := True
              cmdTracker.burstCount := pendingCmd.burstCount
              cmdTracker.serialCmdCount := 0
            }

            when(pendingCmd.isSerial &&
                (pendingCmd.opcode === Opcodes.SER_RD.resize(6) || pendingCmd.opcode === Opcodes.SER_WR.resize(6))) {
              cmdTracker.serialCmdCount := cmdTracker.serialCmdCount + 1
            }

            when(pendingCmd.opcode === Opcodes.SER_BST.resize(6)) {
              cmdTracker.inBurst := False
              cmdTracker.afterBurstStop := True
              timingCounters.tPpdCounter.clear()
            }

            when(pendingCmd.opcode === Opcodes.SER_TG2R.resize(6) || pendingCmd.opcode === Opcodes.SER_TG2W.resize(6)) {
              cmdTracker.afterToggle := True
              cmdTracker.inBubbleNop := True
              cmdTracker.bubbleNopCounter := 0
            }

             // Update bank tracker
             when(pendingCmd.opcode === Opcodes.PAR_ACT) {
               io.toBankTracker.activate.valid := True
               io.toBankTracker.activate.payload.bank := pendingCmd.bank
               io.toBankTracker.activate.payload.rowAddr := pendingCmd.rowAddr
             }

             when(pendingCmd.opcode === Opcodes.PAR_PRE) {
               io.toBankTracker.precharge.valid := True
               io.toBankTracker.precharge.payload := pendingCmd.bank
             }

             // Handle UTR commands
             when(pendingCmd.opcode === Opcodes.PAR_UTR) {
               cmdTracker.utrEnabled := pendingCmd.utrConfig.utrEn
               cmdTracker.utrOp := pendingCmd.utrConfig.utrOp
             }

            // Start timing counters
            when(pendingCmd.opcode === Opcodes.PAR_ACT) {
              timingCounters.tRcdCounter.clear()
              timingCounters.tRasCounter.clear()
              // Shift activate history and add new activation
              for(i <- 3 downto 1) {
                timingCounters.activateHistory(i) := timingCounters.activateHistory(i-1)
              }
              timingCounters.activateHistory(0) := True
            }
            when(pendingCmd.opcode === Opcodes.PAR_PRE) {
              timingCounters.tRpCounter.clear()
            }
            when(pendingCmd.opcode === Opcodes.PAR_REF) {
              timingCounters.tRfcCounter.clear()
            }
            when(pendingCmd.opcode === Opcodes.PAR_WR) {
              timingCounters.tWrCounter.clear()
            }

            // Accept command from source
            switch(cmdSource) {
              is(0) { io.initCmd.ready := True }
              is(1) { io.refreshCmd.ready := True }
              is(2) { io.powerCmd.ready := True }
              is(3) { io.user.cmd.ready := True }
            }

            // Determine next phase
            when(cmdTracker.inBubbleNop) {
              goto(waitPhase)
            } elsewhen(cmdTracker.inBurst) {
              goto(waitPhase)
            } elsewhen(cmdSource === 0) { // Init commands can be back-to-back
              goto(idlePhase)
            } otherwise {
              goto(waitPhase)
        }
     }

     setEntry(idlePhase)
   }
      }
    }
    
    waitPhase.whenIsActive {
      // Handle different wait conditions
      when(cmdTracker.inBurst) {
        // Wait for burst completion
        when(io.fromPhy.valid) {
          cmdTracker.inBurst := False
          goto(idlePhase)
        }
      } elsewhen(cmdTracker.inBubbleNop) {
        // Handle bubble NOPs after toggle
        cmdTracker.bubbleNopCounter := cmdTracker.bubbleNopCounter + 1

        // Assert if exceeding 80 cycles (Note 9.1)
        assert(cmdTracker.bubbleNopCounter <= 80, "Bubble NOP count exceeds 80 cycles (Note 9.1)")

        // Exit bubble NOP when counter reaches required NOPs
        val requiredBubbleNops = U(8, 7 bits) // Default 8 NOPs, should be based on CL from Table 3-1

        when(cmdTracker.bubbleNopCounter >= requiredBubbleNops) {
          cmdTracker.inBubbleNop := False
          cmdTracker.bubbleNopCounter := 0
          goto(idlePhase)
        }
       } otherwise {
         // Wait for timing constraints
         timingCounters.tRcdCounter.increment()
         timingCounters.tRpCounter.increment()
         timingCounters.tRasCounter.increment()
         timingCounters.tRrdCounter.increment()
         timingCounters.tPpdCounter.increment()
         timingCounters.tRfcCounter.increment()
         timingCounters.tFawCounter.increment()
         timingCounters.tWrCounter.increment()

         // Clear afterBurstStop when tPPD satisfied
         when(cmdTracker.afterBurstStop && timingCounters.tPpdSatisfied) {
           cmdTracker.afterBurstStop := False
         }

         // Allow init commands to be accepted during timing waits if tPPD satisfied
         when(io.initCmd.valid && timingCounters.tPpdSatisfied) {
           pendingCmd := io.initCmd.payload
           io.initCmd.ready := True
           cmdSource := 0
           phaseSubState := 1 // validate substate
           goto(commandPhase)
         }

         // Check if all timing satisfied
         when(timingCounters.allTimersSatisfied) {
           goto(idlePhase)
         }
       }
    }
  }
}