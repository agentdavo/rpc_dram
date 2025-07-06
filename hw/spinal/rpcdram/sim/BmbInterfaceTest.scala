package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
  * Comprehensive BMB Interface Test using the test framework
  */
object BmbInterfaceTest extends RpcDramBmbTestBase("BmbInterfaceTest") with App {

  // Override compiled to add more SimPublic signals
  override def compiled = defaultSimConfig.compile {
    val dut = new RpcDramController(cfg, Some(bmbP))

    // Make critical signals accessible in simulation
    dut.init.sequencer.io.initDone.simPublic()
    dut.cmd.scheduler.io.toPhy.simPublic()
    dut.cmd.scheduler.io.user.cmd.ready.simPublic()
    dut.phy.interface.io.cmdIn.simPublic()
    dut.io.ctrlIO.bmb.cmd.ready.simPublic()
    dut.io.ctrlIO.bmb.rsp.valid.simPublic()

    dut
  }

  runTest()

  override protected def runSpecificTest(dut: RpcDramController, driver: EnhancedBmbDriver, monitor: LoggingBmbMonitor): Unit = {
    println("[SIM] BMB Interface Test starting...")

    // Monitor BMB signals
    val bmbMonitor = fork {
      var cycles = 0
      while (cycles < 1000) {
        dut.clockDomain.waitRisingEdge()
        cycles += 1

        if (cycles % 100 == 0) {
          val cmdReady = dut.io.ctrlIO.bmb.cmd.ready.toBoolean
          val cmdValid = dut.io.ctrlIO.bmb.cmd.valid.toBoolean
          val rspReady = dut.io.ctrlIO.bmb.rsp.ready.toBoolean
          val rspValid = dut.io.ctrlIO.bmb.rsp.valid.toBoolean
          println(f"[BMB_MON $cycles] cmd(valid=$cmdValid ready=$cmdReady) rsp(valid=$rspValid ready=$rspReady)")
        }
      }
    }

    // Test BMB write
    println("[SIM] Testing BMB write...")
    val testData = BigInt("DEADBEEFCAFEBABE", 16)  // 64-bit test data
    val testAddress = BigInt(0x1000)

    try {
      driver.writeWithLength(testData, testAddress, cfg.wordBytes - 1)
      println("[SIM] BMB write completed successfully")
    } catch {
      case e: Exception =>
        println(s"[SIM] ERROR: BMB write failed - ${e.getMessage}")
        e.printStackTrace()
    }

    // Test BMB read
    println("[SIM] Testing BMB read...")
    try {
      val readData = driver.readWithLength(testAddress, cfg.wordBytes - 1)
      println(f"[SIM] BMB read completed: 0x$readData%X")
      if (readData == testData) {
        println("[SIM] ✓ Read data matches written data")
      } else {
        println("[SIM] ✗ Read data mismatch!")
      }
    } catch {
      case e: Exception =>
        println(s"[SIM] ERROR: BMB read failed - ${e.getMessage}")
        e.printStackTrace()
    }

    dut.clockDomain.waitRisingEdge(10)
    println("[SIM] BMB interface validation complete")
  }
}