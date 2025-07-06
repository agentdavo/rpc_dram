package rpcdram.core

import rpcdram.{PowerCtrl, RpcDramConfig, RpcDramTiming}
import rpcdram.utils.{DramCmd, Opcodes}
import spinal.core._
import spinal.lib._
import spinal.lib.fsm._

/**
 * Power Manager Component
 *
 * Implements power saving features per datasheet sections 2.10-2.12:
 * - Power Down (PD): Fast entry/exit, maintains bank states
 * - Deep Power Down (DPD): Slow entry/exit, requires full re-initialization
 *
 * Current implementation is a placeholder with basic state machine.
 * TODO: Implement proper CKE timing sequences and command sequences.
 *
 * Key features:
 * - Idle detection for automatic power state entry
 * - External control interface for manual PD/DPD control
 * - Re-initialization requirement signaling for DPD exit
 * - Proper timing enforcement (currently hardcoded, needs timing integration)
 *
 * @param cfg Configuration parameters
 */
case class PowerManager(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val ctrl = slave(PowerCtrl(cfg))              // External power control interface
    val timing = in(RpcDramTiming())              // Timing parameters (for future use)
    val cmdOut = master Stream(DramCmd(cfg))      // Commands to scheduler
    val isIdle = in Bool()                        // System idle status
    val inPowerDown = out Bool()                  // Currently in PD/DPD state
    val reInitRequired = out Bool()               // Re-initialization needed after DPD
  }

  val fsm = new StateMachine {
    val sIdle = new State with EntryPoint        // Normal operation
    val sPdEntry = new State                      // Entering Power Down
    val sPowerDown = new State                    // In Power Down state
    val sDpdEntry = new State                     // Entering Deep Power Down
    val sDeepPowerDown = new State                // In Deep Power Down state

    // TODO: Make counters dynamic based on timing parameters
    // Current values are placeholders for simulation
    val ckeCounter = Counter(3)                   // CKE timing for PD entry (tCKE)
    val dpdCounter = Counter(400000)              // DPD entry delay (tDPD)

    // Default outputs
    io.cmdOut.valid := False
    io.cmdOut.payload.assignDontCare()
    io.inPowerDown := False
    io.reInitRequired := False

    /**
     * Idle State: Normal operation
     * Transitions to PD/DPD entry when idle and requested
     */
    sIdle.whenIsActive {
      when(io.ctrl.enterPd && io.isIdle) {
        ckeCounter.clear()
        goto(sPdEntry)
      }.elsewhen(io.ctrl.enterDpd && io.isIdle) {
        dpdCounter.clear()
        goto(sDpdEntry)
      }
    }

    /**
     * Power Down Entry State
     * TODO: Implement proper CKE deassertion sequence per datasheet
     * Currently sends NOP placeholders
     */
    sPdEntry.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_NOP // TODO: Replace with proper PD entry sequence
      io.cmdOut.payload.odt := False
      when(io.cmdOut.ready) {
        ckeCounter.increment()
        when(ckeCounter.willOverflow) {
          goto(sPowerDown)
        }
      }
    }

    /**
     * Power Down State
     * Maintains low power until exit requested
     */
    sPowerDown.whenIsActive {
      io.inPowerDown := True
      when(io.ctrl.exitPd) {
        goto(sIdle)
      }
    }

    /**
     * Deep Power Down Entry State
     * TODO: Implement proper DPD entry sequence per datasheet
     * Currently sends NOP placeholders
     */
    sDpdEntry.whenIsActive {
      io.cmdOut.valid := True
      io.cmdOut.payload.isSerial := False
      io.cmdOut.payload.opcode := Opcodes.PAR_NOP // TODO: Replace with proper DPD entry sequence
      io.cmdOut.payload.odt := False
      when(io.cmdOut.ready) {
        dpdCounter.increment()
        when(dpdCounter.willOverflow) {
          goto(sDeepPowerDown)
        }
      }
    }

    /**
     * Deep Power Down State
     * Lowest power state, requires full re-initialization on exit
     */
    sDeepPowerDown.whenIsActive {
      io.inPowerDown := True
      io.reInitRequired := True
      when(io.ctrl.exitPd) {  // Note: uses same exit signal as PD
        goto(sIdle)
      }
    }
  }

  // Forward re-init requirement to control interface
  io.ctrl.reInitRequired := io.reInitRequired
}