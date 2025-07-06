package rpcdram

import spinal.core._

/**
 * RPC DRAM Timing Parameters
 *
 * All timing values in clock cycles at the specified frequency (default 800MHz).
 * Values calculated from datasheet Table 11-3 and related sections.
 *
 * Key timing constraints per datasheet:
 * - All values must satisfy: timing >= max(time_ns, cycles_nCK)
 * - tRFC is not specified in datasheet, using conservative DDR3-typical value
 * - PHY timings are implementation-specific, not from datasheet
 */
case class RpcDramTimingParams(
  // Power and reset timings
  tCke: Int = 3,       // CKE pulse width: max(7.5ns, 3nCK) per page 22
  tDpd: Int = 400000,  // Deep Power Down duration: 500µs @ 800MHz per page 23

  // DRAM access timings
  tRcd: Int = 12,      // Row-to-Column Delay: 15ns @ 800MHz per Table 11-3
  tRp: Int = 12,       // Precharge Time: 15ns @ 800MHz per Table 11-3
  tWr: Int = 12,       // Write Recovery Time: 15ns @ 800MHz per Table 11-3
  tRas: Int = 30,      // Row Active Time: 37.5ns @ 800MHz per Table 11-3
  tRrd: Int = 6,       // Row-to-Row Activation Delay: 7.5ns @ 800MHz per Table 11-3
  tPpd: Int = 8,       // Parallel Packet Delay: per page 19
  tZqInit: Int = 1600, // ZQ Calibration Time: 2µs @ 800MHz per Table 11-3
  tFaw: Int = 24,      // Four Activate Window: 30ns @ 800MHz per Table 11-3
  tRfc: Int = 88,      // Refresh Cycle Time: 110ns @ 800MHz (assumed, not in datasheet)

  // PHY-specific timings (implementation dependent)
  tPhyWrLat: Int = 2,  // PHY write latency cycles
  tPhyRdLat: Int = 5,  // PHY read latency cycles
  tPhyWrData: Int = 1, // Cycles from write command to write data valid
  tRddataEn: Int = 3   // Cycles from read command to read data enable
)

/**
 * RPC DRAM Timing Bundle
 *
 * Runtime-configurable timing parameters with optimized bit widths.
 * Used for dynamic timing updates (future enhancement).
 *
 * Bit widths chosen to minimize LUT usage while covering maximum expected values:
 * - DRAM timings: 8-12 bits (sufficient for 800MHz operation)
 * - Power timings: 20 bits (for large DPD counters)
 * - PHY timings: 8 bits (implementation specific)
 */
case class RpcDramTiming() extends Bundle {
  // DRAM timing constraints (8-12 bits for optimization)
  val tRcd = UInt(8 bits)     // Row-to-Column Delay
  val tRp = UInt(8 bits)      // Precharge Time
  val tWr = UInt(8 bits)      // Write Recovery Time
  val tRas = UInt(8 bits)     // Row Active Time
  val tRrd = UInt(8 bits)     // Row-to-Row Delay
  val tPpd = UInt(8 bits)     // Parallel Packet Delay
  val tZqInit = UInt(12 bits) // ZQ Calibration Time
  val tFaw = UInt(8 bits)     // Four Activate Window
  val tRfc = UInt(8 bits)     // Refresh Cycle Time

  // Power management timings
  val tCke = UInt(20 bits)    // CKE pulse width
  val tDpd = UInt(20 bits)    // Deep Power Down duration

  // PHY-specific timings (implementation dependent)
  val tPhyWrLat = UInt(8 bits)   // PHY write latency
  val tPhyRdLat = UInt(8 bits)   // PHY read latency
  val tPhyWrData = UInt(8 bits)  // Write command to data delay
  val tRddataEn = UInt(8 bits)   // Read command to data enable delay

  /**
   * Initialize timing bundle from parameter struct
   * Called during register initialization
   */
  def init(params: RpcDramTimingParams): Unit = {
    tCke := params.tCke
    tDpd := params.tDpd
    tRcd := params.tRcd
    tRp := params.tRp
    tWr := params.tWr
    tRas := params.tRas
    tRrd := params.tRrd
    tPpd := params.tPpd
    tZqInit := params.tZqInit
    tFaw := params.tFaw
    tRfc := params.tRfc
    tPhyWrLat := params.tPhyWrLat
    tPhyRdLat := params.tPhyRdLat
    tPhyWrData := params.tPhyWrData
    tRddataEn := params.tRddataEn
  }
}

/**
 * Feature Configuration
 *
 * Enables/disables optional controller features for area optimization.
 * Conditionally generated components reduce LUT usage when features not needed.
 */
case class RpcDramFeatureConfig(
  useRefreshManager: Boolean = true,   // Automatic refresh timing
  usePowerManager: Boolean = true,     // Power down/deep power down
  useOdt: Boolean = true,              // On-die termination control
  useResetN: Boolean = true,           // Hardware reset pin
  useBankTracker: Boolean = true,      // Bank state management
  useCommandBuffer: Boolean = true,    // Command buffering (future)
  useDataBuffer: Boolean = true        // Data buffering (future)
)

/**
 * Signal Configuration
 *
 * Defines which DRAM signals and protocols are active.
 * Allows optimization by disabling unused interfaces.
 */
case class RpcDramSignalConfig(
  features: RpcDramFeatureConfig = RpcDramFeatureConfig(),
  useSerialCommands: Boolean = true,     // Serial command protocol
  useParallelCommands: Boolean = true,   // Parallel command protocol
  useBidirectionalData: Boolean = true,  // Bidirectional DB bus
  useDqs: Boolean = true,                // DQS strobe signal
  useDqs1: Boolean = true,               // DQS1 complementary strobe
  useMaskedWrite: Boolean = true         // Byte masking for writes
) {
  // Derived convenience accessors
  def useRefresh = features.useRefreshManager
  def usePower = features.usePowerManager
  def useOdtControl = features.useOdt
}

/**
 * RPC DRAM Controller Configuration
 *
 * Central configuration class defining all controller parameters.
 * Includes memory geometry, timing, signal configuration, and system parameters.
 *
 * Memory geometry per Etron EM6GA16LGDBXCAEA datasheet:
 * - 4 banks, 12-bit row address, 10-bit column address
 * - 32-byte (256-bit) words, 16-bit bidirectional DB bus
 * - Single rank by default, multi-rank support available
 */
case class RpcDramConfig(
  // Timing configuration
  timingParams: RpcDramTimingParams = RpcDramTimingParams(),
  signalConfig: RpcDramSignalConfig = RpcDramSignalConfig(),

  // Memory organization (fixed per datasheet)
  bankCount: Int = 4,           // Number of banks (fixed at 4)
  bankAddrWidth: Int = 2,       // Bank address bits (2 bits for 4 banks)
  rankAddrWidth: Int = 0,       // Rank address bits (0 = single rank)
  rowAddrWidth: Int = 12,       // Row address bits per datasheet
  colAddrWidth: Int = 10,       // Column address bits per datasheet

  // Data interface (fixed per datasheet)
  wordBytes: Int = 32,          // Word size in bytes (256 bits total)
  dataWidth: Int = 16,          // DB bus width (x16 interface)
  dqsWidth: Int = 2,            // DQS signal width (differential)

  // System configuration
  freqMHz: Int = 800,           // Operating frequency in MHz
  burstLength: Int = 64,        // Maximum burst length (1-64 words)

  // Development flags
  simMode: Boolean = false,     // Simulation mode (skips calibration)
  phyType: String = "ecp5"      // PHY implementation: "ecp5" or "generic"
) {
  // Compile-time parameter validation
  assert(bankCount == 4, s"Etron RPC DRAM requires exactly 4 banks per datasheet, got $bankCount")
  assert(bankAddrWidth == 2, s"Bank address width must be 2 bits for 4 banks, got $bankAddrWidth")
  assert(rowAddrWidth == 12, s"Row address width must be 12 bits per datasheet, got $rowAddrWidth")
  assert(colAddrWidth == 10, s"Column address width must be 10 bits per datasheet, got $colAddrWidth")
  assert(wordBytes == 32, s"Word size must be 32 bytes (256 bits) per datasheet, got $wordBytes bytes")
  assert(dataWidth == 16, s"Data bus width must be 16 bits (x16 interface) per datasheet, got $dataWidth")
  assert(dqsWidth == 2, s"DQS width must be 2 bits for differential signaling, got $dqsWidth")
  assert(freqMHz <= 800, s"Maximum frequency is 800MHz per datasheet, got ${freqMHz}MHz")
  assert(burstLength <= 64 && burstLength >= 1, s"Burst length must be 1-64 words per datasheet, got $burstLength")

  // Derived parameters for address calculation and sizing
  val wordBits = wordBytes * 8                          // Total bits per word (256)
  val byteAddressWidth = log2Up(wordBytes)              // Address bits for byte selection (5)
  val totalAddressWidth = rankAddrWidth + bankAddrWidth + rowAddrWidth + colAddrWidth + byteAddressWidth // Total address space
  val maxBurstBytes = burstLength * wordBytes           // Maximum burst size in bytes
  val maxBurstBits = maxBurstBytes * 8                  // Maximum burst size in bits
  val rankCount = if (rankAddrWidth == 0) 1 else (1 << rankAddrWidth) // Number of ranks

  // Backward compatibility accessors (deprecated, use signalConfig instead)
  def withRefreshManager = signalConfig.useRefresh
  def withPowerManager = signalConfig.usePower
  def withOdt = signalConfig.useOdtControl
}