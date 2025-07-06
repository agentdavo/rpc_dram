package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
  * Comprehensive BMB Interface Test using the test framework
  */
object BmbInterfaceTest extends RpcDramBmbTestBase("BmbInterfaceTest") with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController, driver: EnhancedBmbDriver, monitor: LoggingBmbMonitor): Unit = {
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
    }

    println("[SIM] BMB interface validation complete")
  }
}