package rpcdram.core

import rpcdram.{PowerCtrl, RpcDramConfig, RpcDramTiming}
import rpcdram.utils.{DramCmd, Opcodes}
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

case class PowerManager(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val ctrl = slave(PowerCtrl(cfg))
    val timing = in(RpcDramTiming())
    val cmdOut = master Stream(DramCmd(cfg))
    val isIdle = in Bool()
    val inPowerDown = out Bool()
    val reInitRequired = out Bool()
  }

  val fsm = new StateMachine {
    val sIdle = new State with EntryPoint
    val sPdEntry = new State
    val sPowerDown = new State
    val sDpdEntry = new State
    val sDeepPowerDown = new State
    
    val ckeCounter = Counter(3) // Will be made dynamic with timing later
    val dpdCounter = Counter(400000) // Will be made dynamic with timing later

    io.cmdOut.valid := False
    io.cmdOut.payload.assignDontCare()
    io.inPowerDown := False
    io.reInitRequired := False

    sIdle.whenIsActive {
      when(io.ctrl.enterPd && io.isIdle) {
        ckeCounter.clear()
        goto(sPdEntry)
      }.elsewhen(io.ctrl.enterDpd && io.isIdle) {
        dpdCounter.clear()
        goto(sDpdEntry)
      }
    }

    sPdEntry.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_NOP // Placeholder for PD entry
      io.cmdOut.payload.odt := False
      when(io.cmdOut.ready) {
        ckeCounter.increment()
        when(ckeCounter.willOverflow) {
          goto(sPowerDown)
        }
      }
    }

    sPowerDown.whenIsActive {
      io.inPowerDown := True
      when(io.ctrl.exitPd) {
        goto(sIdle)
      }
    }

    sDpdEntry.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_NOP
      io.cmdOut.payload.odt := False
      when(io.cmdOut.ready) {
        dpdCounter.increment()
        when(dpdCounter.willOverflow) {
          goto(sDeepPowerDown)
        }
      }
    }

    sDeepPowerDown.whenIsActive {
      io.inPowerDown := True
      io.reInitRequired := True
      when(io.ctrl.exitPd) {
        goto(sIdle)
      }
    }
  }
  
  io.ctrl.reInitRequired := io.reInitRequired
}