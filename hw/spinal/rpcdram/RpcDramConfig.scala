package rpcdram

import spinal.core._

case class RpcDramTimingParams(

  tCke: Int = 3,       // min CKE pulse width (max(7.5ns, 3nCK), Page 22)
  tDpd: Int = 400000,  // min DPD duration (500µs @ 800MHz, Page 23)
  tRcd: Int = 12,      // Row-to-Column Delay (15ns @ 800MHz, Table 11-3)
  tRp: Int = 12,       // Precharge Time (15ns @ 800MHz, Table 11-3)
  tWr: Int = 12,       // Write Recovery Time (15ns @ 800MHz, Table 11-3)
  tRas: Int = 30,      // Row Active Time (37.5ns @ 800MHz, Table 11-3)
  tRrd: Int = 6,       // Row-to-Row Activation Delay (7.5ns @ 800MHz, Table 11-3)
  tPpd: Int = 8,       // Parallel command period (Page 19)
  tZqInit: Int = 1600, // ZQ Calibration (2µs @ 800MHz = 1600 cycles, Table 11-3 p.59 line 3311)
  tFaw: Int = 24,      // Four Activate Window (30ns @ 800MHz, Table 11-3)
  tRfc: Int = 88,      // Refresh Cycle Time (assumed 110ns @ 800MHz, typical DDR3)
  
  // PHY timing parameters (inspired by DFI timeConfig)
  tPhyWrLat: Int = 2,  // PHY write latency
  tPhyRdLat: Int = 5,  // PHY read latency  
  tPhyWrData: Int = 1, // Cycles from write cmd to write data
  tRddataEn: Int = 3   // Cycles from read cmd to read enable
  
  // Note: tZqInit confirmed as 2µs per datasheet Table 11-3 (not 512 cycles)
  // Note: tRFC not explicitly stated in datasheet. Assumed typical DDR3 value.
)

case class RpcDramTiming() extends Bundle {

  val tCke = UInt(20 bits)
  val tDpd = UInt(20 bits)
  val tRcd = UInt(8 bits)
  val tRp = UInt(8 bits)
  val tWr = UInt(8 bits)
  val tRas = UInt(8 bits)
  val tRrd = UInt(8 bits)
  val tPpd = UInt(8 bits)
  val tZqInit = UInt(12 bits)
  val tFaw = UInt(8 bits)
  val tRfc = UInt(8 bits)
  
  // PHY timing parameters
  val tPhyWrLat = UInt(8 bits)
  val tPhyRdLat = UInt(8 bits)
  val tPhyWrData = UInt(8 bits)
  val tRddataEn = UInt(8 bits)

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

// Feature configuration inspired by DfiFunctionConfig
case class RpcDramFeatureConfig(
  useRefreshManager: Boolean = true,
  usePowerManager: Boolean = true,
  useOdt: Boolean = true,
  useResetN: Boolean = true,
  useBankTracker: Boolean = true,
  useCommandBuffer: Boolean = true,
  useDataBuffer: Boolean = true
)

// Signal configuration inspired by DfiSignalConfig  
case class RpcDramSignalConfig(
  features: RpcDramFeatureConfig = RpcDramFeatureConfig(),
  useSerialCommands: Boolean = true,
  useParallelCommands: Boolean = true,
  useBidirectionalData: Boolean = true,
  useDqs: Boolean = true,
  useDqs1: Boolean = true,
  useMaskedWrite: Boolean = true
) {
  // Derived feature flags (inspired by DfiSignalConfig)
  def useRefresh = features.useRefreshManager
  def usePower = features.usePowerManager
  def useOdtControl = features.useOdt
}

case class RpcDramConfig(

  timingParams: RpcDramTimingParams = RpcDramTimingParams(),
  signalConfig: RpcDramSignalConfig = RpcDramSignalConfig(),
  
  // Memory geometry
  bankCount: Int = 4,
  bankAddrWidth: Int = 2,
  rankAddrWidth: Int = 0,  // 0 = single rank, >0 = multi-rank
  rowAddrWidth: Int = 12,
  colAddrWidth: Int = 10,
  
  // Data interface
  wordBytes: Int = 32,
  dataWidth: Int = 16,  // Bidirectional bus width
  dqsWidth: Int = 2,    // DQS signal width
  
  // System parameters
  freqMHz: Int = 800,
  burstLength: Int = 64, // Max burst length (1-64 WORDs)
  
  // Simulation mode
  simMode: Boolean = false // Skip PHY calibration in simulation
) {
  // Parameter validation (compile-time assertions)
  assert(bankCount == 4, s"Etron RPC DRAM requires exactly 4 banks, got $bankCount")
  assert(bankAddrWidth == 2, s"Bank address width must be 2 bits for 4 banks, got $bankAddrWidth")
  assert(rowAddrWidth == 12, s"Row address width must be 12 bits per datasheet, got $rowAddrWidth")
  assert(colAddrWidth == 10, s"Column address width must be 10 bits per datasheet, got $colAddrWidth")
  assert(wordBytes == 32, s"Word size must be 32 bytes (256 bits) per datasheet, got $wordBytes bytes")
  assert(dataWidth == 16, s"Data bus width must be 16 bits (x16 interface) per datasheet, got $dataWidth")
  assert(dqsWidth == 2, s"DQS width must be 2 bits for differential signaling, got $dqsWidth")
  assert(freqMHz <= 800, s"Maximum frequency is 800MHz per datasheet, got ${freqMHz}MHz")
  assert(burstLength <= 64 && burstLength >= 1, s"Burst length must be 1-64 per datasheet, got $burstLength")

  // Derived parameters (inspired by DfiConfig calculations)
  val wordBits = wordBytes * 8
  val byteAddressWidth = log2Up(wordBytes)
  val totalAddressWidth = rankAddrWidth + bankAddrWidth + rowAddrWidth + colAddrWidth + byteAddressWidth
  val maxBurstBytes = burstLength * wordBytes
  val maxBurstBits = maxBurstBytes * 8
  val rankCount = if (rankAddrWidth == 0) 1 else (1 << rankAddrWidth)

  // Convenience accessors for backward compatibility
  def withRefreshManager = signalConfig.useRefresh
  def withPowerManager = signalConfig.usePower
  def withOdt = signalConfig.useOdtControl
}