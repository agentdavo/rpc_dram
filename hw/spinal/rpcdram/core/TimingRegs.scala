package rpcdram.core

import rpcdram.{RpcDramTiming, RpcDramTimingParams}
import spinal.core._
import spinal.lib._

/**
 * Timing Registers Component
 *
 * Stores and manages DRAM timing parameters for dynamic updates.
 * Currently initialized from static config, but designed for future
 * dynamic timing adjustment via bus interface.
 *
 * Timing parameters per datasheet section 11.3:
 * - tRCD: Row to Column Delay
 * - tRP: Precharge Time
 * - tRAS: Row Active Time
 * - tRRD: Row to Row Delay
 * - tPPD: Parallel Packet Delay
 * - tRFC: Refresh Cycle Time
 * - tFAW: Four Activate Window
 * - tWR: Write Recovery Time
 *
 * @param timingParams Static timing parameters from configuration
 */
case class TimingRegs(timingParams: RpcDramTimingParams) extends Component {
  val io = new Bundle {
    val update = slave Flow(RpcDramTiming())  // Dynamic timing updates (future use)
    val current = out(RpcDramTiming())        // Current timing values
  }

  // Timing register with static initialization
  val regs = Reg(RpcDramTiming())
  regs.init(timingParams)

  // Dynamic update capability (currently unused, for future enhancement)
  when(io.update.valid) {
    regs := io.update.payload
  }

  // Output current timing values
  io.current := regs
}