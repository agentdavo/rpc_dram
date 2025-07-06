package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.bmb._
import spinal.lib.bus.bmb.sim.{BmbDriver, BmbMonitor}

/**
 * RPC DRAM Test Framework
 * Provides common utilities and base classes for all RPC DRAM testing
 */
object BmbTestFramework {

  // Standard BMB parameters for RPC DRAM
  def defaultBmbParameter(cfg: RpcDramConfig) = BmbParameter(
    addressWidth = 32,
    dataWidth = cfg.wordBytes * 8,
    lengthWidth = 6,
    sourceWidth = 4,
    contextWidth = 8,
    canRead = true,
    canWrite = true,
    alignment = BmbParameter.BurstAlignement.BYTE
  )

  // Standard simulation config
  def defaultSimConfig = SimConfig
    .withWave
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(100 MHz)))

  // BMB Monitor for logging transactions
  class LoggingBmbMonitor(bus: Bmb, cd: ClockDomain) extends BmbMonitor(bus, cd) {
    override def getByte(address: Long, value: Byte): Unit = {
      println(f"[BMB_MONITOR] Read byte 0x$value%02X from address 0x$address%08X")
    }

    override def setByte(address: Long, value: Byte): Unit = {
      println(f"[BMB_MONITOR] Write byte 0x$value%02X to address 0x$address%08X")
    }
  }

  // Enhanced BMB Driver with length and mask support
  class EnhancedBmbDriver(ctrl: Bmb, cd: ClockDomain) extends BmbDriver(ctrl, cd) {
    def writeWithLength(data: BigInt, address: BigInt, length: Int, mask: BigInt = -1): Unit = {
      mutex.lock()
      val computedMask = if (mask == -1) (BigInt(1) << ctrl.p.access.byteCount) - 1 else mask
      ctrl.cmd.valid #= true
      ctrl.cmd.address #= address
      ctrl.cmd.data #= data
      ctrl.cmd.length #= length
      ctrl.cmd.mask #= computedMask
      ctrl.cmd.opcode #= Bmb.Cmd.Opcode.WRITE
      ctrl.cmd.last #= true
      ctrl.cmd.source #= 1
      ctrl.cmd.context #= 0x42
      cd.waitSamplingWhere(ctrl.cmd.ready.toBoolean)
      ctrl.cmd.valid #= false
      cd.waitSamplingWhere(ctrl.rsp.valid.toBoolean)
      mutex.unlock()
    }

    def readWithLength(address: BigInt, length: Int): BigInt = {
      mutex.lock()
      ctrl.cmd.valid #= true
      ctrl.cmd.address #= address
      ctrl.cmd.length #= length
      ctrl.cmd.opcode #= Bmb.Cmd.Opcode.READ
      ctrl.cmd.last #= true
      ctrl.cmd.source #= 1
      ctrl.cmd.context #= 0x42
      cd.waitSamplingWhere(ctrl.cmd.ready.toBoolean)
      ctrl.cmd.valid #= false
      cd.waitSamplingWhere(ctrl.rsp.valid.toBoolean)
      mutex.unlock()
      ctrl.rsp.data.toBigInt
    }
  }

  // Base test class for RPC DRAM BMB tests
  abstract class RpcDramBmbTestBase(val testName: String, val cfg: RpcDramConfig = RpcDramConfig(
    simMode = true,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 10,         // Further reduced
      tRcd = 2,          // Further reduced
      tRp = 2,           // Further reduced
      tWr = 2,           // Further reduced
      tRas = 3,          // Further reduced
      tRrd = 1,          // Further reduced
      tPpd = 1,          // Further reduced
      tZqInit = 5,       // Further reduced for fast simulation
      tFaw = 2,          // Further reduced
      tRfc = 5           // Further reduced
    ),
    freqMHz = 100        // Lower frequency for simulation
  )) {
    val bmbP = defaultBmbParameter(cfg)

    // Compile the DUT
    def compiled = defaultSimConfig.compile {
      val dut = new RpcDramController(cfg, Some(bmbP))

      // Make critical signals accessible in simulation
      dut.init.sequencer.io.initDone.simPublic()
      dut.cmd.scheduler.io.toPhy.simPublic()
      dut.phy.interface.io.cmdIn.simPublic()

      dut
    }

    // Run the test
    def runTest(): Unit = {
      compiled.doSim(testName) { dut =>
        println(s"[SIM] Starting $testName...")

        // Create driver and monitor
        val driver = new EnhancedBmbDriver(dut.io.ctrlIO.bmb, dut.clockDomain)
        val monitor = new LoggingBmbMonitor(dut.io.ctrlIO.bmb, dut.clockDomain)

        // Fork clock
        dut.clockDomain.forkStimulus(period = 10)

        // Wait for reset to deassert and initialization to start
        dut.clockDomain.waitSampling(20)

        // Initialize rsp.ready
        dut.io.ctrlIO.bmb.rsp.ready #= true

        // Initialize power control if present
        if (dut.io.ctrlIO.powerCtrl != null) {
          dut.io.ctrlIO.powerCtrl.enterPd #= false
          dut.io.ctrlIO.powerCtrl.exitPd #= false
          dut.io.ctrlIO.powerCtrl.enterDpd #= false
        }

        // Wait for initialization
        waitForInit(dut)

        // Run the specific test
        runSpecificTest(dut, driver, monitor)

        dut.clockDomain.waitSampling(10)
        println(s"[SIM] $testName complete")
      }
    }

    // Wait for DRAM initialization
    protected def waitForInit(dut: RpcDramController): Unit = {
      println("[SIM] Waiting for initialization...")
      var cycles = 0
      while (!dut.init.sequencer.io.initDone.toBoolean && cycles < 10000) {
        dut.clockDomain.waitSampling()
        cycles += 1
        if (cycles % 1000 == 0) {
          println(s"[SIM] Still waiting... ($cycles cycles)")
        }
      }

      if (dut.init.sequencer.io.initDone.toBoolean) {
        println(s"[SIM] Initialization complete after $cycles cycles")
      } else {
        println("[SIM] ERROR: Initialization failed")
        simFailure()
      }
    }

    // Override this method in subclasses to implement specific test logic
    protected def runSpecificTest(dut: RpcDramController, driver: EnhancedBmbDriver, monitor: LoggingBmbMonitor): Unit
  }
}