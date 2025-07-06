package rpcdram

import spinal.core._
import spinal.lib._
import spinal.lib.bus.bmb.{Bmb, BmbParameter}
import spinal.lib.bus.bmb.BmbParameter.BurstAlignement

/**
 * BMB to User Bus Adapter
 *
 * Converts BMB (Bus Memory Bus) protocol to the internal UserBus interface.
 * Handles address translation, burst length conversion, and context preservation.
 *
 * @param bmbP BMB parameter configuration
 * @param cfg RPC DRAM configuration
 */
case class BmbToUserBus(bmbP: BmbParameter, cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val bmb = slave(Bmb(bmbP))    // BMB bus interface
    val user = master(UserBus(cfg)) // Internal user bus interface
  }

  val cmdContext = new Bundle {
    val source = UInt(bmbP.access.sourceWidth bits)
    val context = Bits(bmbP.access.contextWidth bits)
  }

  io.user.cmd.valid := io.bmb.cmd.valid
  io.user.cmd.payload.isWrite := io.bmb.cmd.isWrite
  io.user.cmd.payload.address := io.bmb.cmd.address
  io.user.cmd.payload.burstLen := (io.bmb.cmd.length >> log2Up(cfg.wordBytes)).resize(6)
  io.user.cmd.payload.writeMask := io.bmb.cmd.mask.resized
  io.bmb.cmd.ready := io.user.cmd.ready

  io.user.writeData.valid := io.bmb.cmd.valid && io.bmb.cmd.isWrite
  io.user.writeData.payload.fragment := io.bmb.cmd.data
  io.user.writeData.payload.last := io.bmb.cmd.last
  io.bmb.cmd.ready clearWhen(io.bmb.cmd.isWrite && !io.user.writeData.ready)

  io.bmb.rsp.valid := io.user.readData.valid
  io.bmb.rsp.data := io.user.readData.payload.fragment
  io.bmb.rsp.last := io.user.readData.payload.last
  io.bmb.rsp.setSuccess()
  io.user.readData.ready := io.bmb.rsp.ready

  val contextReg = Reg(cmdContext)
  when(io.bmb.cmd.fire) {
    contextReg.source := io.bmb.cmd.source
    contextReg.context := io.bmb.cmd.context
  }
  io.bmb.rsp.source := contextReg.source
  io.bmb.rsp.context := contextReg.context
}