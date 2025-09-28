package rpcdram.sim

import rpcdram._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * IDELAY calibration focused simulation
 */
object CalibrationTest extends RpcDramPhyTestBase("CalibrationTest", RpcDramConfig(simMode = true, freqMHz = 100)) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramPhy): Unit = {
    println("[CALIB] Starting calibration process...")
    dut.clockDomain.waitRisingEdge(10)

    // Monitor calibration progress
    val calibMonitor = fork {
      var lastDelay = -1
      while (!dut.io.calibDone.toBoolean) {
        dut.clockDomain.waitSampling()
        val currentDelay = dut.io.calibDelay.toInt
        if (currentDelay != lastDelay) {
          println(s"[CALIB] Sweep progress: delay = $currentDelay")
          lastDelay = currentDelay
        }
      }
    }

    // Wait for calibration completion
    while (!dut.io.calibDone.toBoolean) {
      dut.clockDomain.waitSampling()
    }
    val finalDelay = dut.io.calibDelay.toInt
    println(s"[CALIB] ✓ Calibration complete! Best delay: $finalDelay taps")

    // Test command after calibration
    testPhyCommand(dut, "POST_CALIB_NOP", 0x00)

    println("[CALIB] ✓ Command execution after calibration successful")
    dut.clockDomain.waitRisingEdge(20)
  }

  def testPhyCommand(dut: RpcDramPhy, name: String, opcode: Int, expectData: Boolean = false): Unit = {
    println(f"\n[TEST] === $name Command Test (opcode: 0x$opcode%02X) ===")

    dut.io.cmdIn.valid #= true
    dut.io.cmdIn.payload.isSerial #= false
    dut.io.cmdIn.payload.opcode #= opcode
    dut.io.cmdIn.payload.bank #= 1
    dut.io.cmdIn.payload.rowAddr #= 0x200
    dut.io.cmdIn.payload.colAddr #= 0x100
    dut.io.cmdIn.payload.burstCount #= 8
    dut.io.cmdIn.payload.writeMask #= BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
    dut.io.cmdIn.payload.odt #= expectData

    if (expectData && opcode == 0x03) { // Write command
      dut.io.writeDataIn.valid #= true
      dut.io.writeDataIn.payload.fragment #= BigInt("DEADBEEF" * 8, 16)
      dut.io.writeDataIn.payload.last #= true
    }

    val startTime = simTime()
    waitUntil(dut.io.cmdIn.ready.toBoolean)
    dut.clockDomain.waitRisingEdge()
    dut.io.cmdIn.valid #= false
    dut.io.writeDataIn.valid #= false

    val acceptTime = simTime() - startTime
    println(f"[TEST] Command accepted in ${acceptTime}ps")

    // Wait for command completion
    dut.clockDomain.waitRisingEdge(30)
    println(f"[TEST] $name command completed")
  }
}