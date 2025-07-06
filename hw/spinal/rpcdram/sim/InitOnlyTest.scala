package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._

/**
 * Minimal test to debug initialization issue
 */
object InitOnlyTest extends App {
  val cfg = RpcDramConfig(
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
      tZqInit = 20,
      tFaw = 4,
      tRfc = 10
    )
  )
  
  Config.sim.compile {
    val dut = new RpcDramController(cfg, None)
    // Make internal signals public for debugging
    dut.phy.interface.io.calibDone.simPublic()
    dut.phy.interface.io.cmdIn.ready.simPublic()
    dut.init.sequencer.io.start.simPublic()
    dut.init.sequencer.io.cmdOut.valid.simPublic()
    dut.cmd.scheduler.io.initCmd.ready.simPublic()
    dut
  }.doSim("InitOnly") { dut =>
    dut.clockDomain.forkStimulus(period = 10)
    
    // Initialize all inputs
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    dut.io.ctrlIO.user.readData.ready #= true
    dut.io.ctrlIO.powerCtrl.enterPd #= false
    dut.io.ctrlIO.powerCtrl.exitPd #= false
    dut.io.ctrlIO.powerCtrl.enterDpd #= false
    
    // Monitor key signals
    println("[TEST] Starting initialization test")
    
    var cycle = 0
    var initDone = false
    
    // Monitor for up to 1000 cycles
    while (cycle < 1000 && !initDone) {
      dut.clockDomain.waitRisingEdge()
      
       val phyCalibDone = dut.phy.interface.io.calibDone.toBoolean
       val phyCmdReady = dut.phy.interface.io.cmdIn.ready.toBoolean
       val initStart = dut.init.sequencer.io.start.toBoolean
       val initCmdValid = dut.init.sequencer.io.cmdOut.valid.toBoolean
       val schedulerInitCmdReady = dut.cmd.scheduler.io.initCmd.ready.toBoolean
       initDone = dut.init.sequencer.io.initDone.toBoolean
      
       // Print state every 10 cycles
       if (cycle % 10 == 0) {
         println(f"[Cycle $cycle%4d] PHY calib=$phyCalibDone cmdReady=$phyCmdReady | Init start=$initStart cmdValid=$initCmdValid | Sched initReady=$schedulerInitCmdReady | Done=$initDone")
       }
      
      // Check for specific conditions
      if (cycle == 50 && !phyCalibDone) {
        println("[ERROR] PHY calibration not done after 50 cycles!")
      }
      
      if (cycle == 100 && !initCmdValid) {
        println("[ERROR] Init sequencer not sending commands after 100 cycles!")
      }
      
      cycle += 1
    }
    
    if (initDone) {
      println(s"[SUCCESS] Initialization completed after $cycle cycles")
    } else {
      println("[ERROR] Initialization failed to complete within 1000 cycles")
      simFailure("Init timeout")
    }
  }
}