package rpcdram

import spinal.core._
import spinal.lib.bus.bmb.BmbParameter
import spinal.lib.bus.bmb.BmbParameter.BurstAlignement

object RpcDramVerilog extends App {

  val cfg = RpcDramConfig()

  Config.spinal.generateVerilog {
    // Set up clock domain with PLL input frequency (100MHz) for PLL configuration
    val clockDomain = ClockDomain.external("clk", frequency = FixedFrequency(100 MHz))
    clockDomain {
      new RpcDramController(cfg, None)
    }
  }

}

// Minimal DRAM interface version for FPGA synthesis testing
object RpcDramDramOnlyVerilog extends App {

  val cfg = RpcDramConfig()

  Config.spinal.generateVerilog {
    // Set up clock domain with PLL input frequency (100MHz) for PLL configuration
    val clockDomain = ClockDomain.external("clk", frequency = FixedFrequency(100 MHz))
    clockDomain {
      new RpcDramDramOnly(cfg)
    }
  }

}

// Minimal DRAM interface version for FPGA synthesis testing
case class RpcDramDramOnly(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    // Only DRAM interface pins (should be ~22 pins total)
    val dram = out(DramBus(cfg))
    // Bidirectional DRAM signals
    val dramDb = inout(Analog(Bits(cfg.dataWidth bits)))
    val dramDqs = cfg.signalConfig.useDqs generate inout(Analog(Bits(cfg.dqsWidth bits)))
    val dramDqs1 = cfg.signalConfig.useDqs1 generate inout(Analog(Bits(cfg.dqsWidth bits)))
  }

  // Instantiate the full controller
  val controller = new RpcDramController(cfg, None)

  // Connect DRAM interface
  io.dram <> controller.io.ctrlIO.dram
  io.dramDb <> controller.io.dramDb
  if (cfg.signalConfig.useDqs) {
    io.dramDqs <> controller.io.dramDqs
  }
  if (cfg.signalConfig.useDqs1) {
    io.dramDqs1 <> controller.io.dramDqs1
  }

  // Tie off user interface to keep controller in idle state
  controller.io.ctrlIO.user.cmd.valid := False
  controller.io.ctrlIO.user.cmd.payload.assignDontCare()
  controller.io.ctrlIO.user.writeData.valid := False
  controller.io.ctrlIO.user.writeData.payload.assignDontCare()
  controller.io.ctrlIO.user.readData.ready := True

  // Tie off power control
  if (cfg.signalConfig.usePower) {
    controller.io.ctrlIO.powerCtrl.enterPd := False
    controller.io.ctrlIO.powerCtrl.exitPd := False
    controller.io.ctrlIO.powerCtrl.enterDpd := False
  }
}

object RpcDramWithBmbVerilog extends App {

  val cfg = RpcDramConfig()
  
  val bmbP = BmbParameter(
    addressWidth = 32,
    dataWidth = cfg.wordBytes * 8,
    lengthWidth = 6,
    sourceWidth = 4,
    contextWidth = 8,
    canRead = true,
    canWrite = true,
    alignment = BurstAlignement.BYTE
  )

  Config.spinal.generateVerilog(new RpcDramController(cfg, Some(bmbP)))

}