package rpcdram.core

import rpcdram.{RpcDramConfig, RpcDramTiming}
import rpcdram.utils.{DramCmd, Opcodes}
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

/**
 * Initialization Sequencer Component
 *
 * Implements the DRAM initialization sequence per datasheet section 2.8.
 * Handles power-up initialization including 200µs wait, reset commands,
 * precharge, MRS configuration, and ZQ calibration.
 *
 * Initialization sequence:
 * 1. Wait 200µs after power-up
 * 2. Issue PAR_RESET command for 5µs
 * 3. Send serial NOP commands for reset stabilization
 * 4. Precharge all banks
 * 5. Configure MRS with timing and drive strength settings
 * 6. Perform ZQ initialization calibration
 *
 * @param cfg Configuration with frequency and simulation mode settings
 */
case class InitSequencer(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val start = in Bool()
    val timing = in(RpcDramTiming())
    val cmdOut = master Stream(DramCmd(cfg))
    val initDone = out Bool()
  }

  val fsm = new StateMachine {
    val sIdle = new State with EntryPoint
    val sWait200us = new State
    val sReset = new State
    val sSerialReset1 = new State
    val sSerialReset2 = new State
    val sPrecharge = new State
    val sMrs = new State
    val sZqInit = new State
    val sDone = new State
    
    val waitCounter = Counter(if (cfg.simMode) 20 else 200 * cfg.freqMHz) // 200 µs (reduced in sim)
    val resetCounter = Counter(if (cfg.simMode) 5 else 5 * cfg.freqMHz) // 5 µs
    val zqCounter = Counter(12 bits) // Dynamic counter for tZqInit

    io.cmdOut.valid := False
    io.cmdOut.payload.assignDontCare()
    io.initDone := False

    sIdle.whenIsActive {
      when(io.start) {
        waitCounter.clear()
        goto(sWait200us)
      }
    }

    sWait200us.whenIsActive {
      waitCounter.increment()
      when(waitCounter.willOverflow) {
        resetCounter.clear()
        goto(sReset)
      }
    }

    sReset.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_RESET
      io.cmdOut.payload.bank := 0
      io.cmdOut.payload.rowAddr := 0
      io.cmdOut.payload.colAddr := 0
      io.cmdOut.payload.burstCount := 0
      io.cmdOut.payload.writeMask := 0
      io.cmdOut.payload.odt := False
      when(io.cmdOut.ready && resetCounter.willOverflow) {
        resetCounter.clear()
        goto(sSerialReset1)
      }
      resetCounter.increment()
    }

    sSerialReset1.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := True
      io.cmdOut.payload.opcode := Opcodes.SER_NOP.resize(6) // Resize to 6 bits
      when(io.cmdOut.ready) {
        goto(sSerialReset2)
      }
    }

    sSerialReset2.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := True
      io.cmdOut.payload.opcode := Opcodes.SER_NOP.resize(6) // Resize to 6 bits
      when(io.cmdOut.ready) {
        goto(sPrecharge)
      }
    }

    sPrecharge.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_PRE
      when(io.cmdOut.ready) {
        goto(sMrs)
      }
    }

    sMrs.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_MRS

      // Configure MRS with proper defaults per datasheet
      io.cmdOut.payload.mrsConfig.odt := B"00"              // ODT: Open (default)
      io.cmdOut.payload.mrsConfig.odtpD := False            // ODTPD: Disabled
      io.cmdOut.payload.mrsConfig.stbOdt := False           // STBODT: Disabled
      io.cmdOut.payload.mrsConfig.zout := B"001"            // Zout: 120 ohm (non-zero for data output)
      io.cmdOut.payload.mrsConfig.nWr := B"011"             // nWR: 8
      io.cmdOut.payload.mrsConfig.casLatency := B"010"      // CL: 11 (matches timing params)
      io.cmdOut.payload.mrsConfig.refreshMode := B"00"      // CSRFX: One-shot
      io.cmdOut.payload.mrsConfig.additiveLatency := True   // AL: 1 (fixed)

      io.cmdOut.payload.odt := True
      when(io.cmdOut.ready) {
        zqCounter.clear()
        goto(sZqInit)
      }
    }

    sZqInit.whenIsActive {
      // Only issue ZQ command once at the beginning of the state
      val zqCmdIssued = Reg(Bool()) init(False)
      
      when(!zqCmdIssued) {
        io.cmdOut.valid := True
        io.cmdOut.payload.isSerial := False
        io.cmdOut.payload.opcode := Opcodes.PAR_ZQ
        when(io.cmdOut.ready) {
          zqCmdIssued := True
          zqCounter.clear()
        }
      } otherwise {
        io.cmdOut.valid := False
        zqCounter.increment()
        when(zqCounter.value === io.timing.tZqInit - 1) {
          zqCmdIssued := False // Reset for next time
          goto(sDone)
        }
      }
    }

    sDone.whenIsActive {
      io.initDone := True
      when(!io.start) {
        goto(sIdle)
      }
    }
  }
}