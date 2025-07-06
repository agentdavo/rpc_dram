package rpcdram.core

import rpcdram.{RpcDramConfig, RpcDramTiming}
import rpcdram.utils.{DramCmd, Opcodes}
import spinal.core._
import spinal.lib._

case class RefreshReq() extends Bundle {
  val mode = Bool() // True = Loop, False = One-Shot
  val bank = UInt(2 bits)
}

case class RefreshManager(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val timing = in(RpcDramTiming())
    val toScheduler = master Stream(DramCmd(cfg))
    val autoRefresh = in Bool() default(True) // Enable/disable auto refresh
  }

  // Refresh timing calculation inspired by DFI Refresher
  val refreshInterval = cfg.freqMHz * (if (cfg.timingParams.tCke > 85) 32 else 64) * 1000 // 64ms or 32ms
  val refreshCounterWidth = log2Up(refreshInterval + 1)
  val refreshCounter = Reg(UInt(refreshCounterWidth bits)) init(0)
  val refreshHit = refreshCounter === 0
  
  // Countdown timer like DFI Refresher pattern
  refreshCounter := refreshCounter - 1
  when(refreshHit || !io.autoRefresh) {
    refreshCounter := refreshInterval
  }

  // Pending refresh request with Event-like interface
  val refreshPending = RegInit(False) 
    .clearWhen(io.toScheduler.ready) 
    .setWhen(refreshHit) 
    .clearWhen(!io.autoRefresh)

  // Command generation area
  val cmdGen = new Area {
    val cmd = DramCmd(cfg)
    
    cmd.isSerial := False
    cmd.opcode := Opcodes.PAR_REF
    cmd.bank := 0
    cmd.rowAddr := 0
    cmd.colAddr := 0
    cmd.burstCount := 0
    cmd.writeMask := 0
    cmd.odt := Bool(cfg.signalConfig.useOdtControl)
    
    io.toScheduler.valid := refreshPending
    io.toScheduler.payload := cmd
  }
}