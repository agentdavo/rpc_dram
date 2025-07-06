package rpcdram.core

import rpcdram.{RpcDramTiming, RpcDramTimingParams}
import spinal.core._
import spinal.lib._

case class TimingRegs(timingParams: RpcDramTimingParams) extends Component {
  val io = new Bundle {
    val update = slave Flow(RpcDramTiming())
    val current = out(RpcDramTiming())
  }

  val regs = Reg(RpcDramTiming())
  regs.init(timingParams)
  
  when(io.update.valid) { regs := io.update.payload }
  io.current := regs
}