package rpcdram.core

import rpcdram.{RpcDramConfig, RpcDramTiming}
import rpcdram.utils.{CommandDefaults, CommandUtils, DramCmd, Opcodes}
import spinal.core._
import spinal.lib._

/**
 * Refresh Request Bundle
 *
 * Defines refresh command parameters (currently unused, for future extension)
 */
case class RefreshReq() extends Bundle {
  val mode = Bool() // True = Loop mode, False = One-Shot mode
  val bank = UInt(2 bits) // Bank selection for targeted refresh
}

/**
 * Refresh Manager Component
 *
 * Handles DRAM refresh timing and command generation per datasheet section 5.
 * Implements automatic refresh every 64ms (normal temperature) to maintain data integrity.
 *
 * Key features:
 * - Configurable refresh interval based on operating conditions
 * - Auto-refresh enable/disable control
 * - REFRESH command generation for all banks
 * - Proper tRFC timing enforcement
 *
 * Refresh interval calculation:
 * - Normal temperature: 64ms
 * - Extended temperature: 32ms (future enhancement)
 * - Converted to clock cycles: freqMHz * 1e6 * interval_ms / 1000
 *
 * @param cfg Configuration with frequency and timing parameters
 */
case class RefreshManager(cfg: RpcDramConfig) extends Component {
  val io = new Bundle {
    val timing = in(RpcDramTiming())                    // Current timing parameters
    val toScheduler = master Stream(DramCmd(cfg))       // Refresh commands to scheduler
    val autoRefresh = in Bool() default(True)           // Enable/disable auto refresh
  }

  // Refresh interval calculation: 64ms in clock cycles
  // freqMHz is in MHz, so cycles/second = freqMHz * 1e6
  // 64ms = 0.064 seconds
  // cycles = freqMHz * 1e6 * 0.064 = freqMHz * 64000
  val refreshIntervalCycles = cfg.freqMHz * 64000
  val refreshCounterWidth = log2Up(refreshIntervalCycles + 1)
  val refreshCounter = Reg(UInt(refreshCounterWidth bits)) init(refreshIntervalCycles)
  val refreshHit = refreshCounter === 0

  // Countdown timer: decrement each cycle, reload on refresh or disable
  when(refreshHit && io.autoRefresh) {
    refreshCounter := refreshIntervalCycles
  }.elsewhen(io.autoRefresh) {
    refreshCounter := refreshCounter - 1
  }.otherwise {
    refreshCounter := refreshIntervalCycles // Hold at max when disabled
  }

  // Refresh request pending flag
  // Set when refresh timer expires, cleared when command accepted or auto-refresh disabled
  val refreshPending = RegInit(False)
    .clearWhen(io.toScheduler.ready)
    .setWhen(refreshHit && io.autoRefresh)
    .clearWhen(!io.autoRefresh)

  /**
   * Refresh Command Generation Area
   *
   * Generates PAR_REF (Parallel Refresh) commands per datasheet Table 7-5.
   * REFRESH refreshes all banks simultaneously, no specific bank/row addressing needed.
   */
  val cmdGen = new Area {
    val cmd = DramCmd(cfg)

    // REFRESH command configuration
    cmd.isSerial := False
    cmd.opcode := Opcodes.PAR_REF
    cmd.rank := 0
    cmd.bank := 0        // Don't care for refresh
    cmd.rowAddr := 0     // Don't care for refresh
    cmd.colAddr := 0     // Don't care for refresh
    cmd.burstCount := 0  // Not applicable
    cmd.writeMask := 0   // Not applicable
    cmd.odt := Bool(cfg.signalConfig.useOdtControl) // ODT control if enabled

    // Initialize MRS/UTR configs with defaults (not used for REF)
    cmd.mrsConfig := CommandDefaults.defaultMrsConfig
    cmd.utrConfig := CommandDefaults.defaultUtrConfig

    // Stream interface: valid when refresh pending
    io.toScheduler.valid := refreshPending
    io.toScheduler.payload := cmd
  }
}