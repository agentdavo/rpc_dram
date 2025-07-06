package rpcdram

import spinal.core._
import spinal.lib._
import spinal.lib.bus.bmb.{Bmb, BmbParameter}
import spinal.lib.bus.bmb.BmbParameter.BurstAlignement

// Command interface inspired by DfiControlInterface
case class RpcCommandInterface(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val isWrite = Bool()
  val address = UInt(cfg.totalAddressWidth bits)
  val burstLen = UInt(log2Up(cfg.burstLength + 1) bits)
  val writeMask = cfg.signalConfig.useMaskedWrite generate Bits(cfg.wordBits bits)
  
  override def asMaster(): Unit = {
    out(isWrite, address, burstLen, writeMask)
  }
}

// Write data interface inspired by DfiWriteInterface
case class RpcWriteInterface(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val writeData = Stream(Fragment(Bits(cfg.wordBits bits)))
  
  override def asMaster(): Unit = {
    master(writeData)
  }
}

// Read data interface inspired by DfiReadInterface
case class RpcReadInterface(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val readData = Stream(Fragment(Bits(cfg.wordBits bits)))
  
  override def asMaster(): Unit = {
    slave(readData)
  }
}

// Combined user bus for backward compatibility
case class UserBus(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val cmd = Stream(new Bundle {
    val isWrite = Bool()
    val address = UInt(32 bits) // Keep 32-bit for compatibility
    val burstLen = UInt(6 bits)
    val writeMask = Bits(cfg.wordBits bits)
  })
  val writeData = Stream(Fragment(Bits(cfg.wordBits bits)))
  val readData = Stream(Fragment(Bits(cfg.wordBits bits)))

  override def asMaster(): Unit = {
    master(cmd, writeData)
    slave(readData)
  }
}

// Power control interface inspired by DfiLowPowerControlInterface
case class PowerCtrl(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val enterPd = cfg.signalConfig.usePower generate Bool()
  val exitPd = cfg.signalConfig.usePower generate Bool()
  val enterDpd = cfg.signalConfig.usePower generate Bool()
  val reInitRequired = cfg.signalConfig.usePower generate Bool() // Added for DPD exit

  override def asMaster(): Unit = {
    out(enterPd, exitPd, enterDpd)
    in(reInitRequired)
  }
}

// DRAM bus interface inspired by DfiControlInterface
case class DramBus(cfg: RpcDramConfig) extends Bundle with IMasterSlave {
  val clkP = Bool()
  val clkN = Bool()
  val csN = Vec(Bool(), cfg.rankCount)
  val stb = Bool()
  val resetN = cfg.signalConfig.features.useResetN generate Bool()
  val odt = cfg.signalConfig.useOdtControl generate Bool()

  // Note: db, dqsP/N, dqs1P/N are bidirectional and should be handled
  // as inout(Analog()) signals at the top level, not in the bundle

  override def asMaster(): Unit = {
    out(clkP, clkN, csN, stb, resetN, odt)
  }
}

// Top-level controller IO inspired by DFI modular design
case class RpcDramCtrlIO(cfg: RpcDramConfig, bmbP: Option[BmbParameter]) extends Bundle with IMasterSlave {
  val user = slave(UserBus(cfg))
  val bmb = bmbP match {
    case Some(p) => slave(Bmb(p))
    case None => null
  }
  val dram = master(DramBus(cfg))
  val powerCtrl = cfg.signalConfig.usePower generate slave(PowerCtrl(cfg))

  override def asMaster(): Unit = {
    master(user)
    slave(dram)
    master(powerCtrl)
    if (bmbP.isDefined) master(bmb)
  }
}