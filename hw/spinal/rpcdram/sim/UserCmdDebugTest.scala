package rpcdram.sim

import rpcdram._
import spinal.core._
import spinal.core.sim._

object UserCmdDebugTest extends App {
  val cfg = RpcDramConfig(
    simMode = true,
    freqMHz = 100,
    timingParams = RpcDramTimingParams(
      tCke = 3,
      tDpd = 100,
      tRcd = 3,
      tRp = 3,
      tWr = 3,
      tRas = 6,
      tRrd = 2,
      tPpd = 2,
      tZqInit = 20,
      tFaw = 6,
      tRfc = 10
    )
  )

  Config.sim.compile {
    val dut = new RpcDramController(cfg, None)
    dut
  }.doSim("UserCmdDebug") { dut =>
    dut.clockDomain.forkStimulus(period = 10)
    
    println("[TEST] Starting user command debug")
    
    // Wait for initialization
    while (!dut.init.sequencer.io.initDone.toBoolean) {
      dut.clockDomain.waitSampling()
    }
    println("[SUCCESS] Initialization complete")
    
    // Issue a simple write command
    dut.io.ctrlIO.user.cmd.valid #= true
    dut.io.ctrlIO.user.cmd.payload.isWrite #= true
    dut.io.ctrlIO.user.cmd.payload.address #= 0x1000
    dut.io.ctrlIO.user.cmd.payload.burstLen #= 1
    dut.io.ctrlIO.user.cmd.payload.writeMask #= BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF", 16)
    
    dut.io.ctrlIO.user.writeData.valid #= true
    dut.io.ctrlIO.user.writeData.payload.fragment #= BigInt("DEADBEEFCAFEBABE" * 4, 16)
    dut.io.ctrlIO.user.writeData.payload.last #= true
    
    var cycles = 0
    var accepted = false
    
    while (cycles < 50 && !accepted) {
      dut.clockDomain.waitSampling()
      cycles += 1
      
      val cmdReady = dut.io.ctrlIO.user.cmd.ready.toBoolean
      val dataReady = dut.io.ctrlIO.user.writeData.ready.toBoolean
      val addrValid = dut.cmd.scheduler.addrDecodeArea.addrValid.toBoolean
      val userBuffered = dut.cmd.scheduler.addrDecodeArea.userCmdBuffered.toBoolean
      val state = dut.cmd.scheduler.io.debugInfo.currentState.toInt
      
      if (cycles % 5 == 0) {
        println(f"[Cycle $cycles%3d] CmdReady=$cmdReady%5s DataReady=$dataReady%5s AddrValid=$addrValid%5s UserBuf=$userBuffered%5s State=$state%d")
      }
      
      if (cmdReady && dataReady) {
        accepted = true
        println(f"[SUCCESS] Command accepted at cycle $cycles")
      }
    }
    
    if (!accepted) {
      println("[ERROR] Command not accepted within 50 cycles")
      simFailure("User command timeout")
    }
    
    dut.io.ctrlIO.user.cmd.valid #= false
    dut.io.ctrlIO.user.writeData.valid #= false
    
    println("[SUCCESS] User command test completed")
  }
}