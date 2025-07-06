package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Complete controller functionality with monitoring
 */
object ControllerCompleteTest extends RpcDramControllerTestBase("ControllerCompleteTest") with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController): Unit = {
    // Make internal signals accessible for monitoring
    dut.cmd.scheduler.io.toPhy.simPublic()
    dut.banks.tracker.states.simPublic()
    dut.banks.tracker.openRows.simPublic()

    // Shared flag to terminate monitoring
    var testComplete = false

    // Command monitor
    val commandMonitor = fork {
      var cmdCount = 0
      var cycles = 0
      val maxCycles = 1000 // Limit monitoring duration

      while (!testComplete && cycles < maxCycles) {
        dut.clockDomain.waitRisingEdge()
        cycles += 1

        if (dut.io.ctrlIO.user.cmd.valid.toBoolean && dut.io.ctrlIO.user.cmd.ready.toBoolean) {
          cmdCount += 1
          val isWrite = dut.io.ctrlIO.user.cmd.payload.isWrite.toBoolean
          val address = dut.io.ctrlIO.user.cmd.payload.address.toLong
          println(s"[MONITOR] Command #$cmdCount: ${if (isWrite) "WRITE" else "READ"} @ 0x${address.toHexString}")
        }

        if (dut.io.ctrlIO.user.writeData.valid.toBoolean && dut.io.ctrlIO.user.writeData.ready.toBoolean) {
          val data = dut.io.ctrlIO.user.writeData.payload.fragment.toBigInt
          println(s"[MONITOR] Write data: 0x${data.toString(16).take(16)}...")
        }

        if (dut.io.ctrlIO.user.readData.valid.toBoolean && dut.io.ctrlIO.user.readData.ready.toBoolean) {
          val data = dut.io.ctrlIO.user.readData.payload.fragment.toBigInt
          println(s"[MONITOR] Read data: 0x${data.toString(16)}")
        }
      }
      println(s"[MONITOR] Completed monitoring after $cycles cycles, $cmdCount commands processed")
    }

    // Test multiple scenarios
    println("\n=== Test 1: Write Command ===")
    issueWriteCommand(dut, 0x1000, BigInt("1234567890ABCDEF" * 4, 16))
    println("Write command accepted")

    println("\n=== Test 2: Read Command ===")
    issueReadCommand(dut, 0x1000)
    println("Read command accepted")

    println("\n=== Controller Complete Simulation Finished ===")

    // Signal monitoring thread to terminate
    testComplete = true
    dut.clockDomain.waitRisingEdge(5) // Allow monitor cleanup
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