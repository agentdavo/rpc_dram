package rpcdram.core

import rpcdram.RpcDramConfig
import spinal.core._
import spinal.lib._

object BankState extends SpinalEnum {
  val IDLE, ACTIVATING, ACTIVE, PRECHARGING = newElement()
}

case class BankTracker(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val cmd = slave(BankTrackerCmd(cfg))
    val status = master(BankTrackerStatus(cfg))
  }

  val states = Vec(Reg(BankState()) init(BankState.IDLE), cfg.bankCount)
  val openRows = Vec(Reg(UInt(cfg.rowAddrWidth bits)) init(0), cfg.bankCount)

  io.cmd.activate.ready := True
  io.cmd.precharge.ready := True

  when(io.cmd.activate.fire) {
    states(io.cmd.activate.payload.bank) := BankState.ACTIVE
    openRows(io.cmd.activate.payload.bank) := io.cmd.activate.payload.rowAddr
  }

  when(io.cmd.precharge.fire) {
    states(io.cmd.precharge.payload) := BankState.IDLE
    openRows(io.cmd.precharge.payload) := U(0, cfg.rowAddrWidth bits)
  }

  io.status.bankStates := states
  io.status.openRow := openRows
}