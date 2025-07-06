package rpcdram.sim

import rpcdram._
import rpcdram.core._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

object BmbDebugTest extends RpcDramBmbTestBase("BmbDebugTest",
  RpcDramConfig(
    simMode = true,
    freqMHz = 100,  // Lower frequency for easier debugging
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 400,  // Reduced for simulation
      tRcd = 2,
      tRp = 2,
      tWr = 2,
      tRas = 4,
      tRrd = 2,
      tPpd = 2,
      tZqInit = 50,  // Much reduced for simulation
      tFaw = 4,
      tRfc = 8
    )
  )
) with App {
  // Override compiled to add more debug signals
  override def compiled = SimConfig
    .withWave
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(100 MHz)))
    .compile {
      val dut = new RpcDramController(cfg, Some(bmbP))

      // Make many signals public for debugging
      dut.init.sequencer.io.start.simPublic()
      dut.init.sequencer.io.initDone.simPublic()
      dut.init.sequencer.io.cmdOut.valid.simPublic()
      dut.init.sequencer.io.cmdOut.ready.simPublic()
      dut.cmd.scheduler.io.initCmd.valid.simPublic()
      dut.cmd.scheduler.io.initCmd.ready.simPublic()
      dut.cmd.scheduler.io.toPhy.valid.simPublic()
      dut.cmd.scheduler.io.toPhy.ready.simPublic()
      dut.phy.interface.io.cmdIn.valid.simPublic()
      dut.phy.interface.io.cmdIn.ready.simPublic()

      dut
    }

  runTest()

  override protected def runSpecificTest(dut: RpcDramController, driver: EnhancedBmbDriver, monitor: LoggingBmbMonitor): Unit = {
    // Monitor initialization with detailed logging
    val initMonitor = fork {
      var lastValid = false
      var cycles = 0
      while (cycles < 1000) {
        dut.clockDomain.waitSampling()
        cycles += 1

        val initStart = dut.init.sequencer.io.start.toBoolean
        val initDone = dut.init.sequencer.io.initDone.toBoolean
        val cmdValid = dut.init.sequencer.io.cmdOut.valid.toBoolean
        val cmdReady = dut.init.sequencer.io.cmdOut.ready.toBoolean
        val schedValid = dut.cmd.scheduler.io.initCmd.valid.toBoolean
        val schedReady = dut.cmd.scheduler.io.initCmd.ready.toBoolean
        val phyValid = dut.cmd.scheduler.io.toPhy.valid.toBoolean
        val phyReady = dut.cmd.scheduler.io.toPhy.ready.toBoolean
        val phyCmdValid = dut.phy.interface.io.cmdIn.valid.toBoolean
        val phyCmdReady = dut.phy.interface.io.cmdIn.ready.toBoolean

        if (cycles % 100 == 0 || cmdValid != lastValid) {
          println(f"[MON $cycles%4d] start=$initStart done=$initDone " +
                 f"init.cmd=$cmdValid/$cmdReady sched=$schedValid/$schedReady " +
                 f"toPhy=$phyValid/$phyReady phy.cmd=$phyCmdValid/$phyCmdReady")
          lastValid = cmdValid
        }

        if (initDone) {
          println(s"[MON] Initialization done at cycle $cycles!")
        }
      }
      println("[MON] Monitoring timeout")
    }

    // Wait for monitoring to complete
    initMonitor.join()

    println("[SIM] Debug test complete")
  }
}