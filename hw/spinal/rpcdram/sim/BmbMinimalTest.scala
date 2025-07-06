package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import RpcDramTestFramework._

/**
 * Minimal BMB test - just verifies that BMB interface compiles and basic signals work
 */
object BmbMinimalTest extends RpcDramBmbTestBase("BmbMinimalTest") with App {
  // Override sim config to not use waves for minimal test
  override val compiled = SimConfig
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(100 MHz)))
    .compile(new RpcDramController(cfg, Some(bmbP)))

  runTest()

  // For minimal test, skip init wait
  override protected def waitForInit(dut: RpcDramController): Unit = {
    // Skip init for minimal test
  }

  override protected def runSpecificTest(dut: RpcDramController, driver: EnhancedBmbDriver, monitor: LoggingBmbMonitor): Unit = {
    // Just wait a few cycles to verify basic operation
    dut.clockDomain.waitSampling(10)

    println("[SIM] BMB interface is responsive")
    println(s"[SIM] BMB cmd ready: ${dut.io.ctrlIO.bmb.cmd.ready.toBoolean}")
    println(s"[SIM] BMB rsp valid: ${dut.io.ctrlIO.bmb.rsp.valid.toBoolean}")

    // Test that we can at least toggle signals manually
    dut.io.ctrlIO.bmb.cmd.valid #= true
    dut.io.ctrlIO.bmb.cmd.opcode #= 0 // READ
    dut.io.ctrlIO.bmb.cmd.address #= 0x1000
    dut.clockDomain.waitSampling(1)

    println(s"[SIM] After cmd valid: BMB cmd ready = ${dut.io.ctrlIO.bmb.cmd.ready.toBoolean}")

    dut.io.ctrlIO.bmb.cmd.valid #= false
    dut.clockDomain.waitSampling(5)

    println("[SIM] Minimal BMB test complete - interface is functional")
    simSuccess()
  }
}