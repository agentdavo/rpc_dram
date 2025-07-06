# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RPC DRAM Controller - A high-performance SpinalHDL controller for Etron 256Mb RPC DRAM (EM6GA16LGDBXCAEA), designed for 800 MHz DDR operation (1600 MT/s). Built using SpinalHDL, a hardware description language embedded in Scala.

## Essential Commands

### Building and Compilation
```bash
# Compile project (required before running any tests)
sbt compile

# Generate Verilog for full controller (output: hw/gen/RpcDramController.v)
sbt "runMain rpcdram.RpcDramVerilog"

# Generate DRAM-only Verilog for FPGA synthesis (~28 pins, output: hw/gen/RpcDramDramOnly.v)
sbt "runMain rpcdram.RpcDramDramOnlyVerilog"
```

### Testing
```bash
# Quick validation (4 tests, ~1 minute)
./run_all_tests.sh  # Note: run_quick_tests.sh doesn't exist, use this instead

# Generate HTML test report
python3 generate_test_report.py

# Run individual tests (prefix with 'timeout 30' to avoid hangs)
timeout 30 sbt "runMain rpcdram.sim.QuickTest"              # PHY validation
timeout 30 sbt "runMain rpcdram.sim.CalibrationTest"        # IDELAY calibration
timeout 30 sbt "runMain rpcdram.sim.ControllerCompleteTest" # Basic controller
timeout 30 sbt "runMain rpcdram.sim.BmbInterfaceTest"       # BMB interface
timeout 30 sbt "runMain rpcdram.sim.Chapter8ComplianceTest" # Protocol compliance
```

### Formal Verification
```bash
# Run formal verification (requires SymbiYosys)
make formal

# Individual formal tests
sbt "runMain rpcdram.formal.BankTrackerBasicFormal"
sbt "runMain rpcdram.formal.InitSequencerFormal"
sbt "runMain rpcdram.formal.CmdSchedulerTimingFormal"
```

### ECP5 FPGA Synthesis
```bash
# Generate DRAM-only Verilog and synthesize for specific ECP5 devices
make synth-ecp5-12k  # LFE5U-12F
make synth-ecp5-25k  # LFE5U-25F
make synth-ecp5-45k  # LFE5U-45F
make synth-ecp5-85k  # LFE5U-85F
```

## Code Architecture

### Source Structure

```
hw/spinal/rpcdram/
├── RpcDramController.scala    # Top-level controller with DFI-inspired Areas
├── RpcDramVerilog.scala        # Verilog generation entry points
├── Config.scala                # SpinalHDL and simulation config
├── core/                       # Core controller components
│   ├── BankTracker.scala       # Bank state tracking (IDLE/ACTIVE)
│   ├── CmdScheduler.scala      # Command scheduling with Chapter 8 timing rules
│   ├── InitSequencer.scala     # 6-step initialization sequence
│   ├── RefreshManager.scala    # Auto-refresh timing (64ms cycle)
│   ├── PowerManager.scala      # Power state management
│   └── TimingRegs.scala        # Dynamic timing parameters
├── phy/
│   └── RpcDramPhy.scala        # PHY with ECP5 DDR primitives (IDDRX1F/ODDRX1F)
├── utils/
│   └── CommandUtils.scala      # Command encoding/decoding per datasheet
├── sim/                        # Simulation tests (~20 test files)
│   ├── RpcDramTestFramework.scala  # Base test classes
│   ├── BmbTestFramework.scala      # BMB-specific test utilities
│   ├── QuickTest.scala         # PHY validation
│   ├── CalibrationTest.scala   # IDELAY calibration
│   ├── ControllerCompleteTest.scala # Basic controller test
│   └── Chapter8ComplianceTest.scala # Protocol compliance
└── formal/
    └── RpcDramFormal.scala     # Formal verification suite (6 tests)
```

### Key Architectural Concepts

#### Controller Organization (DFI-Inspired)
The `RpcDramController` component organizes functionality into separate `Area` blocks:
- **timing**: Manages DRAM timing parameters (tRCD, tRP, tRAS, etc.)
- **banks**: Tracks bank states (IDLE/ACTIVE) and open row addresses
- **init**: Handles 6-step power-on initialization sequence
- **scheduler**: Command scheduling with Chapter 8 timing enforcement
- **refresh**: Auto-refresh management with 64ms cycle timing
- **power**: Power state management and re-initialization
- **phy**: DDR I/O interface with ECP5 primitives
- **connections**: External DRAM signal routing

#### Command Scheduling (Chapter 8 Compliance)
The `CmdScheduler` component implements all 8 command sequencing tables from the datasheet:
- Tables 8-1 through 8-8 define timing between command types
- Critical timing parameters: tRCD, tRP, tRAS, tRRD, tPPD, tRFC, tFAW, tWR
- State validation: ACTIVATE requires bank IDLE, PRECHARGE requires bank ACTIVE
- Priority order: Power commands → Init commands → Refresh commands → User commands

#### PHY Implementation
The `RpcDramPhy` uses platform-specific DDR primitives:
- **Hardware**: Lattice ECP5 `IDDRX1F`/`ODDRX1F` primitives for true DDR signaling
- **Simulation**: Behavioral models provide cycle-accurate DDR simulation
- **Bidirectional**: `Analog` type for DB/DQS buses with TriState control
- **Phase relationships**: STB (90°), DQS Write (270°), DQS Read (edge-aligned)

#### Bank State Management
The `BankTracker` maintains:
- Per-bank state registers (IDLE/ACTIVE using SpinalEnum)
- Open row address tracking
- Command validation for ACTIVATE/PRECHARGE operations

#### Command Encoding
The `CommandUtils` module provides:
- Parallel packet encoding (32-bit command-specific formats)
- Serial packet encoding (16-bit formats)
- Unified 6-bit opcode system
- MRS register field mapping
- ZQ calibration and refresh command encoding

### Bus Memory Bus (BMB) Interface
When `bmbP` parameter is provided, the controller exposes a BMB interface instead of direct user bus. BMB is SpinalHDL's standard memory bus protocol with:
- Address-based memory access
- Burst support
- Ready/valid handshaking

### Test Framework
All tests inherit from `RpcDramTestBase` which provides:
- Standardized test structure with `runTest()` method
- Clock domain management
- Default test configuration
- FST waveform generation

## Important Design Patterns

### SpinalHDL Specifics
- **Component**: Hardware module (like Verilog `module`)
- **Area**: Organizational block within a component (no hierarchy)
- **Bundle**: Signal grouping (like Verilog `struct`)
- **Stream**: Ready/valid interface with `.fire` for transaction detection
- **Analog**: Bidirectional signal type for inout ports

### Conditional Generation
Components can be conditionally generated based on configuration:
```scala
val banks = cfg.signalConfig.features.useBankTracker generate new Area {
  val tracker = BankTracker(cfg)
}
```

### Clock Domains
SpinalHDL uses explicit clock domain specification:
- Main clock domain for controller logic
- Phase-shifted domains for STB and DQS signals
- Simulation uses `ClockDomain.waitSampling()` for cycle advancement

### Formal Verification Patterns
- Use `pastValidAfterReset()` for temporal assertions
- Use `anyseq` + `assume` for stream ready signals
- State invariants prove protocol compliance
- Counter validation ensures timing bounds

## FPGA Synthesis Notes

The full controller requires ~580 I/O pins (ASIC-oriented design). For FPGA prototyping:
- Use `RpcDramDramOnly` variant with ~28 pins
- This version ties off user interfaces, keeping controller idle
- Enables FPGA testing of DRAM signaling and timing logic
- Synthesis results: 850-890 LUTs (3.5%), 343 FFs (1.4%) on LFE5U-25F

## Configuration System

The `RpcDramConfig` case class centralizes all parameters:
- Timing parameters (tRCD, tRP, tRAS, etc.)
- Signal configuration (data width, DQS usage)
- Feature flags (bank tracker, refresh manager, etc.)
- Address widths (row, column, bank)
- Burst configuration

## Testing Approach

Tests are organized by functionality:
- **PHY Tests**: QuickTest, CalibrationTest, PhyTest, PhaseAnalysisTest
- **Controller Tests**: ControllerCompleteTest, InitOnlyTest, CommandFlowTest, SerialCommandTest
- **BMB Tests**: BmbInterfaceTest, BmbMinimalTest, BmbDebugTest
- **Protocol Tests**: Chapter8ComplianceTest, MrsUtrTest
- **Transfer Tests**: BurstTransferTest
- **Debug Tests**: DetailedDebugTest, UserCmdDebugTest

Each test produces FST waveform files in the `simWorkspace` directory for debugging.

## Common Development Patterns

### Adding a New Test

**IMPORTANT:** Read `SPINALHDL_SIMULATION_PATTERNS.md` for detailed best practices before writing tests.

1. Extend appropriate base class in `hw/spinal/rpcdram/sim/`
   - `RpcDramPhyTestBase` for PHY tests
   - `RpcDramControllerTestBase` for controller tests
   - `RpcDramBmbTestBase` for BMB interface tests

2. Follow proper fork thread management patterns:
```scala
override protected def runSpecificTest(dut: Component): Unit = {
  var testComplete = false  // Shared flag

  val monitor = fork {
    var cycles = 0
    val maxCycles = 1000  // Safety limit

    while (!testComplete && cycles < maxCycles) {
      dut.clockDomain.waitRisingEdge()
      cycles += 1
      // monitoring logic
    }
  }

  // Test logic...

  testComplete = true  // Signal completion
  dut.clockDomain.waitRisingEdge(5)  // Allow cleanup
}
```

3. Use appropriate frequency: 100-400 MHz (NOT 800 MHz in simulation)
4. Enable `simMode = true` in config
5. Add test to `run_all_tests.sh` or `generate_test_report.py`

### Fork Thread Best Practices

**Always provide exit conditions:**
- ❌ `while (true)` - NEVER use infinite loops
- ✅ `while (!testComplete && cycles < maxCycles)` - Use flags + limits
- ✅ `while (!dut.io.done.toBoolean)` - Natural hardware exit
- ✅ `while (cycles < 1000)` - Fixed iteration count

**Always include:**
- Cycle/iteration counter
- Maximum cycle limit (safety)
- Summary println at fork exit
- 5+ cycle wait after setting testComplete flag

See `SPINALHDL_SIMULATION_PATTERNS.md` for complete examples.

### Timeout Loop Pattern (MANDATORY)

**CRITICAL:** Never use `waitUntil()` without timeout protection!

**❌ UNSAFE - Will hang if signal never asserts:**
```scala
waitUntil(signal.toBoolean)

while (!signal.toBoolean) {
  dut.clockDomain.waitRisingEdge()
}
```

**✅ SAFE - Has timeout and graceful degradation:**
```scala
var cycles = 0
val maxCycles = 100  // Adjust based on operation
while (!signal.toBoolean && cycles < maxCycles) {
  dut.clockDomain.waitRisingEdge()
  cycles += 1
}

if (!signal.toBoolean) {
  println(f"[TEST] WARNING: Signal timeout after $maxCycles cycles")
  // Clean up resources
  dut.io.cmdIn.valid #= false
  return  // Or throw exception
}

// Continue with test...
```

**Timeout Guidelines:**
- Command ready: 100 cycles
- Data ready: 200 cycles
- Calibration: 1000 cycles
- Initialization: 2000 cycles
- BMB transactions: 1000 cycles

**Project Status:** All 13 unsafe `waitUntil()` calls eliminated ✅

See `TIMEOUT_PATTERN_APPLIED_PROJECT_WIDE.md` for complete documentation.

### Modifying Timing Parameters
1. Update default values in `RpcDramConfig` case class
2. For dynamic updates, use `TimingRegs.io.update` stream
3. Rerun Chapter8ComplianceTest to verify timing enforcement

### Adding New Commands
1. Add opcode to `Opcodes` object in `CommandUtils.scala`
2. Implement encoding in `CommandUtils` (parallel and serial)
3. Update `CmdScheduler` state machine if needed
4. Add formal verification for new command sequences
5. Create dedicated simulation test

## Dependencies

- SpinalHDL (dev version) - Hardware description language
- Scala 2.12.18 - Programming language
- sbt - Build tool
- Verilator (optional) - Simulation backend
- SymbiYosys (optional) - Formal verification
- Yosys + nextpnr-ecp5 (optional) - ECP5 FPGA synthesis
