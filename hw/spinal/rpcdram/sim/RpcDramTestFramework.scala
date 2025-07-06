package rpcdram.sim

import rpcdram._
import rpcdram.phy.RpcDramPhy
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.bmb._
import spinal.lib.bus.bmb.sim.{BmbDriver, BmbMonitor}

/**
 * RPC DRAM Test Framework
 * Provides common utilities and base classes for all RPC DRAM testing
 */
object RpcDramTestFramework {

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
      ctrl.cmd.opcode #= 1  // WRITE
      ctrl.cmd.length #= length
      ctrl.cmd.data #= data
      ctrl.cmd.mask #= computedMask
      ctrl.cmd.last #= true
      ctrl.cmd.source #= 0
      ctrl.cmd.context #= 0

      // Wait for cmd ready with timeout
      var cycles = 0
      val maxCycles = 1000
      while (!ctrl.cmd.ready.toBoolean && cycles < maxCycles) {
        cd.waitSampling()
        cycles += 1
      }
      if (!ctrl.cmd.ready.toBoolean) {
        println(s"[BMB_DRIVER] WARNING: Write cmd.ready timeout after $maxCycles cycles")
        ctrl.cmd.valid #= false
        mutex.unlock()
        throw new Exception("BMB write cmd.ready timeout")
      }

      cd.waitSampling()
      ctrl.cmd.valid #= false

      // Wait for response with timeout
      cycles = 0
      while (!ctrl.rsp.valid.toBoolean && cycles < maxCycles) {
        cd.waitSampling()
        cycles += 1
      }
      if (!ctrl.rsp.valid.toBoolean) {
        println(s"[BMB_DRIVER] WARNING: Write rsp.valid timeout after $maxCycles cycles")
        mutex.unlock()
        throw new Exception("BMB write rsp.valid timeout")
      }

      cd.waitSampling()
      mutex.unlock()
    }

    def readWithLength(address: BigInt, length: Int): BigInt = {
      mutex.lock()
      ctrl.cmd.valid #= true
      ctrl.cmd.address #= address
      ctrl.cmd.opcode #= 0  // READ
      ctrl.cmd.length #= length
      ctrl.cmd.source #= 0
      ctrl.cmd.context #= 0

      // Wait for cmd ready with timeout
      var cycles = 0
      val maxCycles = 1000
      while (!ctrl.cmd.ready.toBoolean && cycles < maxCycles) {
        cd.waitSampling()
        cycles += 1
      }
      if (!ctrl.cmd.ready.toBoolean) {
        println(s"[BMB_DRIVER] WARNING: Read cmd.ready timeout after $maxCycles cycles")
        ctrl.cmd.valid #= false
        mutex.unlock()
        throw new Exception("BMB read cmd.ready timeout")
      }

      cd.waitSampling()
      ctrl.cmd.valid #= false

      // Wait for response with timeout
      cycles = 0
      while (!ctrl.rsp.valid.toBoolean && cycles < maxCycles) {
        cd.waitSampling()
        cycles += 1
      }
      if (!ctrl.rsp.valid.toBoolean) {
        println(s"[BMB_DRIVER] WARNING: Read rsp.valid timeout after $maxCycles cycles")
        mutex.unlock()
        throw new Exception("BMB read rsp.valid timeout")
      }

      val data = ctrl.rsp.data.toBigInt
      cd.waitSampling()
      mutex.unlock()
      data
    }
  }

  // Base test class for RPC DRAM Controller tests
  abstract class RpcDramControllerTestBase(val testName: String, val cfg: RpcDramConfig = RpcDramConfig(
    simMode = true,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 100,        // Reduced from 400000
      tRcd = 3,          // Reduced from 12
      tRp = 3,           // Reduced from 12
      tWr = 3,           // Reduced from 12
      tRas = 5,          // Reduced from 30
      tRrd = 2,          // Reduced from 6
      tPpd = 0,          // Reduced from 8 for fast init
      tZqInit = 20,      // Reduced from 1600 for fast simulation
      tFaw = 4,          // Reduced from 24
      tRfc = 10          // Reduced from 88
    ),
    freqMHz = 100        // Lower frequency for simulation
  )) {
    // Compile the DUT
    def compiled = defaultSimConfig.compile(new RpcDramController(cfg, None))

    // Run the test
    def runTest(): Unit = {
      compiled.doSim(testName) { dut =>
        println(s"[SIM] Starting $testName...")

        // Fork clock
        dut.clockDomain.forkStimulus(period = 10)

        // Initialize controller
        initializeController(dut)

        // Wait for reset to deassert and initialization to start
        dut.clockDomain.waitSampling(20)

        // Wait for initialization
        waitForInit(dut)

        // Run the specific test
        runSpecificTest(dut)

        dut.clockDomain.waitSampling(10)
        println(s"[SIM] $testName complete")
      }
    }

    // Initialize controller signals
    protected def initializeController(dut: RpcDramController): Unit = {
      dut.io.ctrlIO.user.cmd.valid #= false
      dut.io.ctrlIO.user.cmd.payload.isWrite #= false
      dut.io.ctrlIO.user.cmd.payload.address #= 0
      dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
      dut.io.ctrlIO.user.cmd.payload.writeMask #= 0

      dut.io.ctrlIO.user.writeData.valid #= false
      dut.io.ctrlIO.user.writeData.payload.fragment #= 0
      dut.io.ctrlIO.user.writeData.payload.last #= false

      dut.io.ctrlIO.user.readData.ready #= true

       dut.io.ctrlIO.powerCtrl.enterPd #= false
       dut.io.ctrlIO.powerCtrl.exitPd #= false
       dut.io.ctrlIO.powerCtrl.enterDpd #= false
     }

      // Wait for DRAM initialization
      protected def waitForInit(dut: RpcDramController): Unit = {
        println("[SIM] Waiting for initialization...")
        val initSuccess = waitUntilTimeout(dut.init.sequencer.io.initDone.toBoolean, 2000)
        if (!initSuccess) {
          println("[ERROR] Initialization timeout! Check timing parameters.")
          simFailure()
        } else {
          println("[SIM] Initialization complete!")
        }
      }

    // Helper function for timeouts
    protected def waitUntilTimeout(condition: => Boolean, maxCycles: Int = 1000): Boolean = {
       var cycles = 0
       while (!condition && cycles < maxCycles) {
         sleep(1)
         cycles += 1
       }
       condition
     }

    // Override this method in subclasses to implement specific test logic
    protected def runSpecificTest(dut: RpcDramController): Unit
  }

  // Base test class for RPC DRAM PHY tests
  abstract class RpcDramPhyTestBase(val testName: String, val cfg: RpcDramConfig = RpcDramConfig(
    simMode = true,
    freqMHz = 200
  )) {
    // Compile the DUT
    def compiled = defaultSimConfig.compile(new RpcDramPhy(cfg))

    // Run the test
    def runTest(): Unit = {
      compiled.doSim(testName) { dut =>
        println(s"[SIM] Starting $testName...")

        // Fork clock
        dut.clockDomain.forkStimulus(period = 1000 / cfg.freqMHz) // Period in ns

        // Initialize PHY
        initializePhy(dut)

        // Wait for reset to deassert
        dut.clockDomain.waitSampling(20)

        // Run the specific test
        runSpecificTest(dut)

        dut.clockDomain.waitSampling(10)
        println(s"[SIM] $testName complete")
      }
    }

    // Initialize PHY signals
    protected def initializePhy(dut: RpcDramPhy): Unit = {
      dut.io.cmdIn.valid #= false
      dut.io.writeDataIn.valid #= false
      dut.io.writeDataIn.payload.fragment #= 0
      dut.io.writeDataIn.payload.last #= false
      dut.io.readDataOut.ready #= true
    }



    // Override this method in subclasses to implement specific test logic
    protected def runSpecificTest(dut: RpcDramPhy): Unit
  }

  // BMB-specific base class (moved from BmbTestFramework)
  abstract class RpcDramBmbTestBase(val testName: String, val cfg: RpcDramConfig = RpcDramConfig(
    simMode = true,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 100,        // Reduced from 400000
      tRcd = 3,          // Reduced from 12
      tRp = 3,           // Reduced from 12
      tWr = 3,           // Reduced from 12
      tRas = 5,          // Reduced from 30
      tRrd = 2,          // Reduced from 6
      tPpd = 2,          // Reduced from 8
      tZqInit = 20,      // Reduced from 1600 for fast simulation
      tFaw = 4,          // Reduced from 24
      tRfc = 10          // Reduced from 88
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