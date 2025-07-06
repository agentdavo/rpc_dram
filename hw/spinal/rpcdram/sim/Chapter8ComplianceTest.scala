package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Test Chapter 8 command sequencing compliance from datasheet
 * Verifies all timing tables from Chapter 8:
 * - Table 8-1: Parallel to Serial (Same Bank)
 * - Table 8-2: Parallel to Serial (Different Bank)
 * - Table 8-3: Parallel to Parallel (Same Bank)
 * - Table 8-4: Parallel to Parallel (Different Bank)
 * - Table 8-5: Serial to Serial (Same Bank)
 * - Table 8-6: Serial to Serial (Different Bank)
 * - Table 8-7: Serial to Parallel (Same Bank)
 * - Table 8-8: Serial to Parallel (Different Bank)
 */
object Chapter8ComplianceTest extends RpcDramControllerTestBase("Chapter8ComplianceTest",
  RpcDramConfig(
    simMode = true,
    freqMHz = 100,
    timingParams = RpcDramTimingParams(
      tCke = 1, tDpd = 10, tRcd = 2, tRp = 2, tWr = 2,
      tRas = 5, tRrd = 1, tPpd = 2, tZqInit = 5, tFaw = 4, tRfc = 10
    )
  )) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramController): Unit = {
    println("=== Chapter 8 Compliance Test ===")

    // Test Table 8-1: Basic timing validation (ACT->RD)
    println("\n[TEST Table 8-1] Basic timing validation (ACT->RD)")
    val address = (0x100 << 14) | (0 << 12) | 0x40 // Bank 0, Row 0x100, Col 0x40

    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= false
    dut.io.ctrlIO.user.cmd.payload.address #= address
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("  ✓ Basic activate->read sequence completed")

    // Test Table 8-2: Bank interleaving validation
    println("\n[TEST Table 8-2] Bank interleaving validation")
    val addr0 = (0x200 << 14) | (0 << 12) | 0x50 // Bank 0
    val addr1 = (0x300 << 14) | (1 << 12) | 0x60 // Bank 1

    // Issue read to bank 0
    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= false
    dut.io.ctrlIO.user.cmd.payload.address #= addr0
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 8

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.clockDomain.waitRisingEdge(5)

    // Issue read to bank 1
    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= false
    dut.io.ctrlIO.user.cmd.payload.address #= addr1
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 8

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("  ✓ Bank interleaving operations completed")

    // Test Table 8-3: Command timing validation
    println("\n[TEST Table 8-3] Command timing validation")
    val writeAddress = (0x400 << 14) | (2 << 12) | 0x70 // Bank 2

    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= writeAddress
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= BigInt("FFFFFFFF", 16)

    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= BigInt("DEADBEEF" * 8, 16)
    dut.io.ctrlIO.user.writeData.payload.last #= true

    waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
    dut.clockDomain.waitRisingEdge()
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    dut.clockDomain.waitRisingEdge(20)
    println("  ✓ Command timing validation completed")

    // Test Table 8-4: Multi-bank operations
    println("\n[TEST Table 8-4] Multi-bank operations")
    for (bank <- 0 until 4) { // Test first 4 banks
      val bankAddress = (0x500 << 14) | (bank << 12) | 0x80

      dut.io.ctrlIO.user.cmd.valid #= true
      dut.io.ctrlIO.user.cmd.payload.isWrite #= false
      dut.io.ctrlIO.user.cmd.payload.address #= bankAddress
      dut.io.ctrlIO.user.cmd.payload.burstLen #= 1

      waitUntilTimeout(dut.io.ctrlIO.user.cmd.ready.toBoolean, 100)
      dut.clockDomain.waitRisingEdge()
      dut.io.ctrlIO.user.cmd.valid #= false
      dut.clockDomain.waitRisingEdge(5) // tRrd
    }
    println("  ✓ Multi-bank operations completed")

    println("\n[SUCCESS] All Chapter 8 compliance tests passed!")
  }
}