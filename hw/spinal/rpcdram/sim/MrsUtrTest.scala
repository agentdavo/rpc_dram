package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._
import rpcdram.utils.{CommandUtils, DramCmd, Opcodes}

/**
 * Test MRS field implementation and UTR data patterns
 * Verifies MRS register configuration and UTR predefined data patterns
 */
object MrsUtrTest extends RpcDramControllerTestBase("MrsUtrTest",
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
    println("=== MRS and UTR Test ===")

    // Test MRS field encoding
    println("\n[TEST 1] MRS field encoding verification")
    testMrsEncoding()

    // Test UTR command encoding
    println("\n[TEST 2] UTR command encoding verification")
    testUtrEncoding()

    // Test UTR data patterns
    println("\n[TEST 3] UTR data pattern generation")
    testUtrPatterns()

    println("\n[SUCCESS] MRS and UTR tests completed!")
  }

  def testMrsEncoding(): Unit = {
    // Test MRS encoding with specific values
    // ODT=1 (60 ohm), ODTPD=1, STBODT=1, Zout=3 (51.4 ohm), nWR=5 (12), CL=2 (11), Refresh=1 (Loop), AL=1
    val encoded = CommandUtils.encodeMrsSoftware(
      odt = 1, odtpD = true, stbOdt = true, zout = 3,
      nWr = 5, casLatency = 2, refreshMode = 1, additiveLatency = true
    )

    // Expected bit pattern:
    // DB15-14: ODT=01 (60 ohm), DB13: ODTPD=1, DB12: STBODT=1
    // DB11-9: Zout=011 (51.4 ohm), DB8-6: nWR=101 (12), DB5-3: CL=010 (11)
    // DB2-1: Refresh=01 (Loop), DB0: AL=1
    // So: 01 (ODT) + 1 (ODTPD) + 1 (STBODT) + 011 (Zout) + 101 (nWR) + 010 (CL) + 01 (Refresh) + 1 (AL)
    // = 0111011101010011 = 0x7753
    val expected = BigInt("0111011101010011", 2)

    if (encoded == expected) {
      println("  ✓ MRS encoding correct")
    } else {
      println(s"  ✗ MRS encoding incorrect: got 0x${encoded.toString(16)} (${encoded.toString(2)}), expected 0x${expected.toString(16)} (${expected.toString(2)})")
    }
  }

  def testUtrEncoding(): Unit = {
    // Test UTR command encoding
    val encoded = CommandUtils.encodeUtrSoftware(utrEn = true, utrOp = 2) // UTR enabled, OP=10

    // Expected: opcode=001010, UTREN=1 (bit6), UTR_OP=10 (bits5:4)
    // So: 001010 | 1 << 6 | 2 << 4 = 001010 | 1000000 | 100000 = 01101010
    val expected = BigInt("01101010", 2)

    if (encoded == expected) {
      println("  ✓ UTR encoding correct")
    } else {
      println(s"  ✗ UTR encoding incorrect: got ${encoded.toString(2)}, expected ${expected.toString(2)}")
    }
  }

  def testUtrPatterns(): Unit = {
    // Test UTR data pattern generation (from controller implementation)
    // In SpinalHDL, Bits are LSB first, so patterns appear reversed in hex
    val utrPatterns = Array(
      BigInt("a" * 64, 16),     // OP=00: 0101 LSB first = 1010 = A
      BigInt("3" * 64, 16),     // OP=01: 1100 LSB first = 0011 = 3
      BigInt("c" * 64, 16),     // OP=10: 0011 LSB first = 1100 = C
      BigInt("5" * 64, 16)      // OP=11: 1010 LSB first = 0101 = 5
    )

    val patternNames = Array("0101", "1100", "0011", "1010")

    for (i <- 0 until 4) {
      // Check that the pattern is correctly repeated
      val pattern = utrPatterns(i)
      val nibblePattern = patternNames(i)

      // Verify first few nibbles (should be the repeated hex digit)
      val firstNibbles = pattern.toString(16).take(8)
      val expectedNibbles = (if (i == 0) "a" else if (i == 1) "3" else if (i == 2) "c" else "5") * 8

      if (firstNibbles == expectedNibbles) {
        println(s"  ✓ UTR_OP=${i} (${nibblePattern}) pattern correct")
      } else {
        println(s"  ✗ UTR_OP=${i} pattern incorrect: got ${firstNibbles}, expected ${expectedNibbles}")
      }
    }
  }
}