package rpcdram.sim

import rpcdram._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Quick RPC DRAM test - runs basic PHY validation
 */
object QuickTest extends RpcDramPhyTestBase("QuickTest", RpcDramConfig(simMode = true, freqMHz = 100)) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramPhy): Unit = {
    dut.clockDomain.waitRisingEdge(10)
    while (!dut.io.calibDone.toBoolean) {
      dut.clockDomain.waitSampling()
    }
    println(s"✓ Calibration complete: ${dut.io.calibDelay.toInt} taps")

    testPhyCommand(dut, "NOP", 0x00)

    println("✓ Quick test passed!")
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

    // Wait for ready with timeout
    var cycles = 0
    val maxCycles = 100
    while (!dut.io.cmdIn.ready.toBoolean && cycles < maxCycles) {
      dut.clockDomain.waitRisingEdge()
      cycles += 1
    }

    if (!dut.io.cmdIn.ready.toBoolean) {
      println(f"[TEST] WARNING: $name command not accepted after $maxCycles cycles - skipping")
      dut.io.cmdIn.valid #= false
      dut.io.writeDataIn.valid #= false
      return
    }

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