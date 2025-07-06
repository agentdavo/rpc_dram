package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._

object DetailedDebugTest extends App {
  val cfg = RpcDramConfig(
    simMode = true,
    freqMHz = 100,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 100,
      tRcd = 3,
      tRp = 3,
      tWr = 3,
      tRas = 6,
      tRrd = 2,
      tPpd = 2,
      tZqInit = 20, // Reduced for faster simulation
      tFaw = 6,
      tRfc = 10
    )
  )

  Config.sim.compile {
    val dut = new RpcDramController(cfg, None)
    dut
  }.doSim("DetailedDebug") { dut =>
    dut.clockDomain.forkStimulus(period = 10)
    
    var cycle = 0
    dut.clockDomain.onSamplings {
      if (cycle % 10 == 0) {
        val state = dut.cmd.scheduler.io.debugInfo.currentState.toInt
        val source = dut.cmd.scheduler.io.debugInfo.cmdSource.toInt  
        val opcode = dut.cmd.scheduler.io.debugInfo.pendingOpcode.toInt
        val legal = dut.cmd.scheduler.io.debugInfo.validationLegal.toBoolean
        val done = dut.cmd.scheduler.io.debugInfo.validationDone.toBoolean
        val initValid = dut.init.sequencer.io.cmdOut.valid.toBoolean
        val initReady = dut.cmd.scheduler.io.initCmd.ready.toBoolean
        val phyReady = dut.phy.interface.io.cmdIn.ready.toBoolean
        val phyValid = dut.cmd.scheduler.io.toPhy.valid.toBoolean
        val initDone = dut.init.sequencer.io.initDone.toBoolean
        
        println(f"[Cycle $cycle%4d] State=$state%d Src=$source%d Op=0x$opcode%02x Legal=$legal%5s Done=$done%5s | InitV=$initValid%5s InitR=$initReady%5s | PhyR=$phyReady%5s PhyV=$phyValid%5s | InitDone=$initDone%5s")
      }
      cycle += 1
    }
    
    println("[TEST] Starting detailed debug")
    
    // Run for a reasonable time to see state transitions
    dut.clockDomain.waitSampling(200)
    
    if (!dut.init.sequencer.io.initDone.toBoolean) {
      println("[ERROR] Initialization failed to complete")
      simFailure("Init timeout")
    } else {
      println("[SUCCESS] Initialization completed")
    }
  }
}