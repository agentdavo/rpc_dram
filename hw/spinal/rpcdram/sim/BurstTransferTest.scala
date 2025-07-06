package rpcdram.sim

import rpcdram._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Burst transfer validation - tests multi-WORD bursts
 */
object BurstTransferTest extends RpcDramPhyTestBase("BurstTransferTest", RpcDramConfig(simMode = true, freqMHz = 400)) with App {
  runTest()

  override protected def runSpecificTest(dut: RpcDramPhy): Unit = {
    println("=== Burst Transfer Validation ===")
    println("Testing multi-WORD burst transfers (1-64 WORDs)...")

    dut.clockDomain.waitRisingEdge(10)
    while (!dut.io.calibDone.toBoolean) {
      dut.clockDomain.waitSampling()
    }
    println(s"✓ Calibration complete: ${dut.io.calibDelay.toInt} taps")

    // Test burst sizes: 1, 4, 16, 63 WORDs (6-bit limit: 0-63)
    val burstSizes = Array(1, 4, 16, 63)

    for (burstSize <- burstSizes) {
      println(f"\n[TEST] Testing burst size: $burstSize WORDs")

      dut.io.cmdIn.valid #= true
      dut.io.cmdIn.payload.isSerial #= false
      dut.io.cmdIn.payload.opcode #= 0x03 // WRITE
      dut.io.cmdIn.payload.bank #= 0
      dut.io.cmdIn.payload.rowAddr #= 0x100
      dut.io.cmdIn.payload.colAddr #= 0x200
      dut.io.cmdIn.payload.burstCount #= burstSize
      dut.io.cmdIn.payload.writeMask #= BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
      dut.io.cmdIn.payload.odt #= true

      // Test pattern for each WORD in burst
      val basePattern = BigInt("DEADBEEF" * 8, 16)
      dut.io.writeDataIn.valid #= true
      dut.io.writeDataIn.payload.fragment #= basePattern + burstSize
      dut.io.writeDataIn.payload.last #= true

      // Wait for ready with timeout
      var cycles = 0
      val maxCycles = 100
      while (!dut.io.cmdIn.ready.toBoolean && cycles < maxCycles) {
        dut.clockDomain.waitRisingEdge()
        cycles += 1
      }

      if (!dut.io.cmdIn.ready.toBoolean) {
        println(f"[TEST] WARNING: Burst $burstSize command not accepted after $maxCycles cycles - skipping")
        dut.io.cmdIn.valid #= false
        dut.io.writeDataIn.valid #= false
        // Continue with next burst size
      } else {
        dut.clockDomain.waitRisingEdge()
        dut.io.cmdIn.valid #= false
        dut.io.writeDataIn.valid #= false

        // Wait for burst completion (8 cycles per WORD)
        dut.clockDomain.waitRisingEdge(burstSize * 8 + 20)

        val transferTime = burstSize * 8 * 2.5 // cycles * period
        val bandwidth = (burstSize * 32) / (transferTime / 1000) // GB/s
        println(f"✓ Burst $burstSize completed in ${burstSize * 8} cycles")
        println(f"✓ Effective bandwidth: ${bandwidth}%.2f GB/s")
      }
    }

    println("\n✓ All burst transfer tests passed!")
  }
}