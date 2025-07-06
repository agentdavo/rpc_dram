package rpcdram.utils

import rpcdram.RpcDramConfig
import spinal.core._
import spinal.lib._

object Opcodes {
  // Parallel Commands (Table 7-1, Page 50) - 6 bits
  def PAR_NOP    = B"000000"
  def PAR_ACT    = B"000001"
  def PAR_RD     = B"000010"
  def PAR_WR     = B"000011"
  def PAR_PRE    = B"000101"
  def PAR_REF    = B"000110"
  def PAR_MRS    = B"001000"
  def PAR_ZQ     = B"001001"
  def PAR_RESET  = B"001111"
  def PAR_UTR    = B"001010" // Utility Register Read

  // Serial Commands (Table 7-7, Page 53) - 6 bits (padded with 0)
  def SER_NOP    = B"000000"
  def SER_RD     = B"000010"
  def SER_WR     = B"000011"
  def SER_ACT    = B"001001"
  def SER_PRE    = B"000101"
  def SER_TG2R   = B"000110" // Toggle to Read
  def SER_TG2W   = B"000111" // Toggle to Write
  def SER_BST    = B"001000" // Burst Stop
  def SER_REF    = B"001010"
}

case class MrsConfig() extends Bundle {
  // MRS register fields per Table 7-2
  val odt = Bits(2 bits)        // DB[15:14]: ODT resistance (00=Open, 01=60Ω, 10=45Ω, 11=25.7Ω)
  val odtpD = Bool()            // DB[13]: ODT enabled during PD (0=disabled, 1=enabled)
  val stbOdt = Bool()           // DB[12]: STB ODT (0=disable, 1=always enable)
  val zout = Bits(3 bits)       // DB[11:9]: Zout resistance selection
  val nWr = Bits(3 bits)        // DB[8:6]: Write recovery time
  val casLatency = Bits(3 bits) // DB[5:3]: CAS latency
  val refreshMode = Bits(2 bits)// DB[2:1]: Refresh mode (0=One-shot, 1=Loop)
  val additiveLatency = Bool()  // DB[0]: Additive latency (fixed to 1 per datasheet)
}

case class UtrConfig() extends Bundle {
  val utrEn = Bool()            // Enable UTR mode
  val utrOp = Bits(2 bits)      // UTR operation (00=0101..., 01=1100..., 10=0011..., 11=1010...)
}

object CommandDefaults {
  def defaultMrsConfig: MrsConfig = {
    val config = MrsConfig()
    config.odt := B"00"              // Open (default)
    config.odtpD := False            // Disabled
    config.stbOdt := False           // Disabled
    config.zout := B"000"            // Open (default)
    config.nWr := B"011"             // 8 (default)
    config.casLatency := B"000"      // 8 (default)
    config.refreshMode := B"00"      // One-shot (default)
    config.additiveLatency := True   // 1 (fixed)
    config
  }

  def defaultUtrConfig: UtrConfig = {
    val config = UtrConfig()
    config.utrEn := False
    config.utrOp := B"00"
    config
  }

  def defaultDramCmd(cfg: RpcDramConfig): DramCmd = {
    val cmd = DramCmd(cfg)
    cmd.isSerial := False
    cmd.opcode := Opcodes.PAR_NOP
    cmd.rank := 0
    cmd.bank := 0
    cmd.rowAddr := 0
    cmd.colAddr := 0
    cmd.burstCount := 0
    cmd.writeMask := 0
    cmd.odt := False
    cmd.mrsConfig := defaultMrsConfig
    cmd.utrConfig := defaultUtrConfig
    cmd
  }
}

case class DramCmd(cfg: RpcDramConfig) extends Bundle {
  val isSerial   = Bool()
  val opcode     = Bits(6 bits)
  val rank       = UInt(cfg.rankAddrWidth bits)
  val bank       = UInt(cfg.bankAddrWidth bits)
  val rowAddr    = UInt(cfg.rowAddrWidth bits)
  val colAddr    = UInt(cfg.colAddrWidth bits)
  val burstCount = UInt(6 bits) // 1-64 WORDs
  val writeMask  = Bits(cfg.wordBytes * 8 bits) // 256-bit mask
  val odt        = Bool() // Added for ODT control
  val mrsConfig  = MrsConfig() // MRS register configuration
  val utrConfig  = UtrConfig() // UTR configuration
}

object CommandUtils {
  def createDefaultCmd(cfg: RpcDramConfig): DramCmd = {
    CommandDefaults.defaultDramCmd(cfg)
  }

  def encodeParallelPacket(cmd: DramCmd): Bits = {
    // Command-specific 32-bit packet format per Table 7-1
    val packet = Bits(32 bits)
    packet := 0 // Initialize to 0
    when(cmd.isSerial) {
      packet := B(0, 32 bits)
    } otherwise {
      switch(cmd.opcode) {
        // RD/WR commands: DB[10:5]=BC[5:0], DB[29:20]=CA[9:0], DB[19:8]=RA[11:0], DB[7:6]=BA[1:0], DB[5:0]=OP[5:0]
        is(Opcodes.PAR_RD, Opcodes.PAR_WR) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          packet(7 downto 6) := cmd.bank.asBits.resize(2)
          packet(19 downto 8) := cmd.rowAddr.asBits.resize(12)
          packet(29 downto 20) := cmd.colAddr.asBits.resize(10)
          packet(10 downto 5) := cmd.burstCount.asBits.resize(6)
        }
        // ACT command: DB[29:20]=RA[9:0], DB[19:8]=RA[11:10] + X, DB[7:6]=BA[1:0], DB[5:0]=OP[5:0]
        is(Opcodes.PAR_ACT) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          packet(7 downto 6) := cmd.bank.asBits.resize(2)
          packet(29 downto 20) := cmd.rowAddr.asBits.resize(10)
          packet(19 downto 18) := cmd.rowAddr.asBits.resize(12)(11 downto 10)
        }
        // PRE command: DB[7:6]=BA[1:0], DB[5:0]=OP[5:0], others X
        is(Opcodes.PAR_PRE) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          packet(7 downto 6) := cmd.bank.asBits.resize(2)
        }
        // REF command: DB[7:6]=BA[1:0], DB[2:1]=REF_OP[1:0], DB[5:0]=OP[5:0]
        is(Opcodes.PAR_REF) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          packet(7 downto 6) := cmd.bank.asBits.resize(2)
          // REF_OP defaults to 00 (FST Refresh)
          packet(2 downto 1) := B"00"
        }
        // MRS command: 16-bit packet in DB[15:0], DB[31:16]=X
        is(Opcodes.PAR_MRS) {
          // MRS fields per Table 7-2
          packet(15 downto 14) := cmd.mrsConfig.odt         // ODT resistance
          packet(13) := cmd.mrsConfig.odtpD                 // ODTPD
          packet(12) := cmd.mrsConfig.stbOdt                // STBODT
          packet(11 downto 9) := cmd.mrsConfig.zout         // Zout resistance
          packet(8 downto 6) := cmd.mrsConfig.nWr           // nWR
          packet(5 downto 3) := cmd.mrsConfig.casLatency    // CL
          packet(2 downto 1) := cmd.mrsConfig.refreshMode   // CSRFX
          packet(0) := cmd.mrsConfig.additiveLatency        // AL (fixed to 1)
        }
        // UTR command: DB[5:4]=UTR_OP[1:0], DB[6]=UTREN, others X
        is(Opcodes.PAR_UTR) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          packet(6) := cmd.utrConfig.utrEn                  // UTREN
          packet(5 downto 4) := cmd.utrConfig.utrOp         // UTR_OP
        }
        // ZQ command: DB[15:14]=ZQC_OP[1:0], others X
        is(Opcodes.PAR_ZQ) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
          // ZQC_OP defaults to 00 (Calibration after initialization)
          packet(15 downto 14) := B"00"
        }
        // RESET command: DB[5:0]=OP[5:0], others X
        is(Opcodes.PAR_RESET) {
          packet(5 downto 0) := cmd.opcode(5 downto 0)
        }
      }
    }
    packet
  }

  def encodeSerialPacket(cmd: DramCmd): Bits = {
    // 16-bit serial packet format per Table 7-7 and 7-8
    val packet = Bits(16 bits)
    packet := 0 // Initialize to 0
    when(cmd.isSerial) {
      switch(cmd.opcode) {
        // RD command: bit0=0 (RD), bits1-2=BA[1:0], bits3-9=CA[9:3], bits10-15=X
        is(Opcodes.SER_RD) {
          packet(0) := False // RD
          packet(2 downto 1) := cmd.bank.asBits.resize(2)
          packet(9 downto 3) := cmd.colAddr.asBits(9 downto 3).resize(7)
        }
        // WR command: bit0=1 (WR), bits1-2=BA[1:0], bits3-9=CA[9:3], bits10-15=X
        is(Opcodes.SER_WR) {
          packet(0) := True // WR
          packet(2 downto 1) := cmd.bank.asBits.resize(2)
          packet(9 downto 3) := cmd.colAddr.asBits(9 downto 3).resize(7)
        }
        // ACT command: bit0=1, bit1=0, bit2=0, bit3=1, bits4-5=BA[1:0], bits6-15=RA[9:0]
        is(Opcodes.SER_ACT) {
          packet(0) := True
          packet(1) := False
          packet(2) := False
          packet(3) := True
          packet(5 downto 4) := cmd.bank.asBits.resize(2)
          packet(15 downto 6) := cmd.rowAddr.asBits.resize(10)
        }
        // PRE command: bit0=1, bit1=0, bit2=0, bit3=1, bit4=0, bit5=1, bits6-7=BA[1:0], bits8-15=X
        is(Opcodes.SER_PRE) {
          packet(0) := True
          packet(1) := False
          packet(2) := False
          packet(3) := True
          packet(4) := False
          packet(5) := True
          packet(7 downto 6) := cmd.bank.asBits.resize(2)
        }
        // Utility commands per Table 7-8
        is(Opcodes.SER_TG2R, Opcodes.SER_TG2W) {
          // Toggle RW: bit2=1, others 0
          packet(2) := True
        }
        is(Opcodes.SER_BST) {
          // BST: bit3=1, others 0
          packet(3) := True
        }
        is(Opcodes.SER_REF) {
          // REF: bit5=1, bits6-9=BK[0:3], bits10-11=REFOP[1:0] (default 00)
          packet(5) := True
          packet(9 downto 6) := cmd.bank.asBits.resize(4)
          packet(11 downto 10) := B"00" // REFOP
        }
      }
    }
    packet
  }

  def decodeParallelPacket(packet: Bits, cfg: RpcDramConfig): DramCmd = {
    val cmd = DramCmd(cfg)
    cmd.isSerial := False
    cmd.opcode := packet(5 downto 0)
    cmd.bank := packet(7 downto 6).asUInt
    cmd.rowAddr := packet(19 downto 8).asUInt
    cmd.colAddr := packet(29 downto 20).asUInt
    cmd.burstCount := packet(35 downto 30).asUInt
    cmd.writeMask := B(0, cfg.wordBytes * 8 bits)
    cmd.odt := False

    // Initialize MRS config with defaults
    cmd.mrsConfig.odt := B"00"              // Open (default)
    cmd.mrsConfig.odtpD := False            // Disabled
    cmd.mrsConfig.stbOdt := False           // Disabled
    cmd.mrsConfig.zout := B"000"            // Open (default)
    cmd.mrsConfig.nWr := B"011"             // 8 (default)
    cmd.mrsConfig.casLatency := B"000"      // 8 (default)
    cmd.mrsConfig.refreshMode := B"00"      // One-shot (default)
    cmd.mrsConfig.additiveLatency := True   // 1 (fixed)

    // Initialize UTR config
    cmd.utrConfig.utrEn := False
    cmd.utrConfig.utrOp := B"00"

    cmd
  }

  // Software version for testing (no SpinalHDL constructs)
  def encodeMrsSoftware(odt: Int, odtpD: Boolean, stbOdt: Boolean, zout: Int,
                       nWr: Int, casLatency: Int, refreshMode: Int, additiveLatency: Boolean): BigInt = {
    var packet = BigInt(0)
    packet = packet | (BigInt(odt) << 14)
    packet = packet | (BigInt(if (odtpD) 1 else 0) << 13)
    packet = packet | (BigInt(if (stbOdt) 1 else 0) << 12)
    packet = packet | (BigInt(zout) << 9)
    packet = packet | (BigInt(nWr) << 6)
    packet = packet | (BigInt(casLatency) << 3)
    packet = packet | (BigInt(refreshMode) << 1)
    packet = packet | (BigInt(if (additiveLatency) 1 else 0) << 0)
    packet
  }

  def encodeUtrSoftware(utrEn: Boolean, utrOp: Int): BigInt = {
    var packet = BigInt(0x0A) // PAR_UTR opcode = 001010 = 0x0A
    packet |= BigInt(if (utrEn) 1 else 0) << 6
    packet |= BigInt(utrOp) << 4
    packet
  }
}