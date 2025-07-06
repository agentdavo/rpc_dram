package rpcdram.core

import rpcdram.RpcDramConfig
import spinal.core._
import spinal.lib._

/**
 * Bank State Enumeration
 *
 * Defines the possible states for each DRAM bank per datasheet section 2.9:
 * - IDLE: Bank precharged, ready for ACTIVATE
 * - ACTIVE: Bank open with specific row active, ready for RD/WR
 */
object BankState extends SpinalEnum {
  val IDLE, ACTIVE = newElement()
}

/**
 * Bank Tracker Component
 *
 * Tracks the state and open row address for each DRAM bank.
 * Essential for command validation and timing enforcement.
 *
 * Key responsibilities:
 * - Maintain bank states (IDLE/ACTIVE)
 * - Track open row addresses
 * - Provide status to command scheduler
 * - Accept ACTIVATE/PRECHARGE commands from scheduler
 *
 * @param cfg Configuration with bank count and address widths
 */
case class BankTracker(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val cmd = slave(BankTrackerCmd(cfg))      // Commands from scheduler
    val status = master(BankTrackerStatus(cfg)) // Status to scheduler
  }

  // Bank state registers - initialized to IDLE (all banks precharged)
  val states = Vec(Reg(BankState()) init(BankState.IDLE), cfg.bankCount)

  // Open row address registers - initialized to 0
  val openRows = Vec(Reg(UInt(cfg.rowAddrWidth bits)) init(0), cfg.bankCount)

  // Always ready to accept commands (no backpressure needed)
  io.cmd.activate.ready := True
  io.cmd.precharge.ready := True

  // ACTIVATE command processing: set bank ACTIVE and record row address
  when(io.cmd.activate.fire) {
    states(io.cmd.activate.payload.bank) := BankState.ACTIVE
    openRows(io.cmd.activate.payload.bank) := io.cmd.activate.payload.rowAddr
  }

  // PRECHARGE command processing: set bank IDLE and clear row address
  when(io.cmd.precharge.fire) {
    states(io.cmd.precharge.payload) := BankState.IDLE
    openRows(io.cmd.precharge.payload) := U(0, cfg.rowAddrWidth bits)
  }

  // Output current status to scheduler
  io.status.bankStates := states
  io.status.openRow := openRows
}