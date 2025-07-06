package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Basic controller functionality test using the test framework
 */
object ControllerBasicTest extends RpcDramControllerTestBase("ControllerBasicTest") with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController): Unit = {
    // Wait additional time for controller to be ready
    dut.clockDomain.waitSampling(100)

    // Simple write-read test
    val testAddr = 0x00000000
    val testData = BigInt("DEADBEEF" * 8, 16) // 256-bit data

    // Write test
    println(s"[SIM] Writing to address 0x${testAddr.toHexString}")
    issueWriteCommand(dut, testAddr, testData)

    // Read test
    println(s"[SIM] Reading from address 0x${testAddr.toHexString}")
    val readData = issueReadCommand(dut, testAddr)

    // Verify result
    if (readData == testData) {
      println("[SIM] ✓ Read data matches written data!")
    } else {
      println(s"[SIM] ✗ Read data mismatch! Expected: 0x${testData.toString(16)}, Got: 0x${readData.toString(16)}")
    }

    println("[SIM] Basic controller simulation complete")
  }

  // Helper functions (moved from RpcDramSim.scala)
  def issueWriteCommand(dut: RpcDramController, address: Long, data: BigInt): Unit = {
    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= address
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)

    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= data
    dut.io.ctrlIO.user.writeData.payload.last #= true

    if (!waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)) {
      println("[ERROR] Write command not accepted - timeout!")
      return
    }
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false

    dut.clockDomain.waitRisingEdge(20)
  }

  def issueReadCommand(dut: RpcDramController, address: Long): BigInt = {
    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= false
    dut.io.ctrlIO.user.cmd.payload.address #= address
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1

    if (!waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)) {
      println("[ERROR] Read command not accepted - timeout!")
      return 0
    }
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false

    if (!waitUntilTimeout(dut.io.ctrlIO.user.readData.valid.toBoolean, 200)) {
      println("[ERROR] Read data not received - timeout!")
      return 0
    }
    val data = dut.io.ctrlIO.user.readData.payload.fragment.toBigInt

    dut.clockDomain.waitRisingEdge()
    data
  }


}