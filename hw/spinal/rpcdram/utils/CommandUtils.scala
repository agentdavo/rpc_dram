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
}

object CommandUtils {
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
          // For now, use default values: CL=8, nWR=8, Zout=Open, etc.
          val mrsData = B"0000000000000000" // Default MRS settings
          packet(15 downto 0) := mrsData
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
    cmd
  }
}