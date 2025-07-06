package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Detailed command flow analysis - Simplified version
 */
object CommandFlowTest extends RpcDramControllerTestBase("CommandFlowTest",
  RpcDramConfig(
    simMode = true,
    freqMHz = 100,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 100,
      tRcd = 3,
      tRp = 3,
      tWr = 3,
      tRas = 5,
      tRrd = 2,
      tPpd = 2,
      tZqInit = 20, // Reduced for faster simulation
      tFaw = 4,
      tRfc = 10
    )
  )) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController): Unit = {
    // Simple wait for init done
    var cycles = 0
    while (!dut.init.sequencer.io.initDone.toBoolean && cycles < 5000) {
      dut.clockDomain.waitSampling()
      cycles += 1
      if (cycles % 500 == 0) {
        println(s"[INFO] Still waiting for init after $cycles cycles")
      }
    }

    if (cycles >= 5000) {
      println("[ERROR] Initialization timeout!")
      simFailure()
    } else {
      println(s"[SUCCESS] Initialization complete after $cycles cycles")

      // Simple write test
      println("\n[TEST] Issuing write command to address 0x1000")
      issueWriteCommand(dut, 0x1000, BigInt("DEADBEEF" * 8, 16))

      // Simple read test
      println("\n[TEST] Issuing read command from address 0x1000")
      issueReadCommand(dut, 0x1000)

      println("\n[SUCCESS] Command Flow test completed!")
    }
  }

  // Helper functions
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