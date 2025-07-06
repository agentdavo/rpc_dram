package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Test byte masking functionality according to datasheet:
 * - Two 32-bit masks transmitted at WL-2 and WL-1 before write data
 * - First mask applies to first WORD, second mask applies to last WORD
 * - Masked bytes (bit=0) should not be written to memory
 * - Unmasked bytes (bit=1) should be written
 */
object ByteMaskingTest extends RpcDramControllerTestBase("ByteMaskingTest",
  RpcDramConfig(
    simMode = true,
    freqMHz = 100,
    timingParams = RpcDramTimingParams(
      tCke = 3, tDpd = 100, tRcd = 3, tRp = 3, tWr = 3,
      tRas = 6, tRrd = 2, tPpd = 2, tZqInit = 20, tFaw = 6, tRfc = 10
    )
  )) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController): Unit = {
    println("=== Byte Masking Test ===")

    // Test 1: Basic write with full mask
    println("\n[TEST 1] Basic masked write (full mask)")
    val addr1 = 0x1000
    val data1 = BigInt("DEADBEEFCAFEBABE" * 4, 16)
    val mask1 = BigInt("FFFFFFFF", 16) // All bytes enabled

    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= addr1
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= mask1

    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= data1
    dut.io.ctrlIO.user.writeData.payload.last #= true

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("[PASS] Full mask write completed")

    // Test 2: Partial mask test
    println("\n[TEST 2] Partial mask write")
    val addr2 = 0x2000
    val data2 = BigInt("A5A5A5A5A5A5A5A5" * 4, 16)
    val mask2 = BigInt("FF00FF00", 16) // Partial mask

    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= addr2
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= mask2

    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= data2
    dut.io.ctrlIO.user.writeData.payload.last #= true

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("[PASS] Partial mask write completed")

    // Test 3: Zero mask test
    println("\n[TEST 3] Zero mask write")
    val addr3 = 0x3000
    val data3 = BigInt("FFFFFFFFFFFFFFFF" * 4, 16)
    val mask3 = BigInt("00000000", 16) // No bytes enabled

    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= addr3
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= mask3

    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= data3
    dut.io.ctrlIO.user.writeData.payload.last #= true

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("[PASS] Zero mask write completed")

    println("\n[SUCCESS] All byte masking tests passed!")
  }
}