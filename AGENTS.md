# AGENTS.md - Development Guidelines for RPC DRAM Controller

## Overview

This document provides guidelines for AI agents and developers working on the RPC DRAM Controller project. It contains information about the codebase structure, development workflow, optimization strategies, and best practices.

## Project Structure

```
rpc_dram/
├── hw/spinal/rpcdram/          # Main SpinalHDL source code
│   ├── RpcDramController.scala # Top-level controller
│   ├── RpcDramConfig.scala     # Configuration classes
│   ├── core/                   # Core controller components
│   │   ├── CmdScheduler.scala  # Command scheduling FSM
│   │   ├── BankTracker.scala   # Bank state management
│   │   ├── RefreshManager.scala# Auto-refresh logic
│   │   ├── PowerManager.scala  # Power state control
│   │   ├── TimingRegs.scala    # Timing parameter storage
│   │   └── InitSequencer.scala # Initialization sequence
│   ├── phy/                    # Physical interface layer
│   │   └── RpcDramPhy.scala    # DDR I/O and calibration
│   ├── sim/                    # Simulation test suite
│   └── utils/                  # Utility functions
├── hw/boards/ecp5/            # FPGA-specific files
├── docs/                      # Documentation
└── project/                   # Build configuration
```

## Development Workflow

### 1. Code Review & Optimization Checklist

When working on code improvements:

- [x] **Remove dead code**: Eliminate unused variables, imports, and functions
- [x] **Optimize algorithms**: Review timing calculations and state machines
- [x] **Fix SpinalHDL patterns**: Ensure proper use of `when`/`otherwise`, avoid `return` in `when` blocks
- [x] **Minimize resource usage**: Reduce register counts and LUT utilization
- [x] **Add comprehensive comments**: Document logic with datasheet references
- [x] **Validate functionality**: Run test suite after changes
- [x] **Import cleanup**: Remove unused SpinalHDL imports for cleaner compilation
- [x] **Dead code elimination**: Remove commented-out code blocks and unused formal tests

### 2. SpinalHDL Insights from Code Review

#### Key Learnings from Codebase Analysis

- **Import Management**: Always verify SpinalHDL imports are actually used - unused imports like `SdramXdrPhyCtrl` and `SdramXdrPhyCtrlPhase` can be safely removed
- **Dead Code Detection**: Large commented-out blocks (like unused formal verification tests) should be completely removed rather than left as comments
- **Documentation Standards**: All major components should have comprehensive class-level documentation with datasheet references
- **Counter Optimization**: Use `log2Up()` consistently for minimum bit-width calculations
- **State Machine Patterns**: Complex state machines work well with clear state names and proper transition logic
- **Area Organization**: DFI-inspired area-based organization provides excellent separation of concerns

#### Advanced SpinalHDL Patterns Observed

- **Analog Signal Handling**: Proper use of `Analog` type for bidirectional buses with TriState control
- **Clock Domain Management**: Strategic use of `ClockingArea` for DDR phase relationships
- **Formal Verification Integration**: Seamless integration with `pastValidAfterReset()` for temporal properties
- **Conditional Component Generation**: Extensive use of `generate` for feature-optional components
- **Stream Interface Compliance**: Proper IMasterSlave implementation with ready/valid handshakes

### 3. Common Optimization Patterns

#### Timing Calculations
```scala
// Correct: Proper cycle calculation for 64ms @ 800MHz
val refreshCycles = cfg.freqMHz * 64000

// Incorrect: Wrong units or temperature assumptions
val wrongCalc = cfg.freqMHz * (if (cfg.timingParams.tCke > 85) 32 else 64) * 1000
```

#### SpinalHDL Conditional Logic
```scala
// Correct: Use when for mux-style conditionals
val legal = Bool()
when(isSpecial) {
  legal := True
}.elsewhen(otherCondition) {
  legal := validateCommandTransition(cmd)
}.otherwise {
  legal := False

// Incorrect: Don't use return in when blocks
when(condition) {
  return True  // This doesn't work as expected
}
```

#### State Machine Best Practices
```scala
// Good: Clear state names and transitions
val fsm = new StateMachine {
  val sIdle = new State with EntryPoint
  val sActive = new State
  // ... clear transitions
}

// Avoid: Complex nested conditions
when(state === IDLE && condition1 && condition2) {
  // Hard to read and maintain
}
```

### 3. Testing Strategy

#### Quick Validation
```bash
# Run single test for immediate feedback
sbt "runMain rpcdram.sim.QuickTest"

# Run initialization test
sbt "runMain rpcdram.sim.InitOnlyTest"
```

#### Full Test Suite
```bash
# Run all tests (13 comprehensive tests)
./run_all_tests.sh

# Generate test report
python3 generate_test_report.py
```

#### Formal Verification
```bash
# Run formal verification (requires SymbiYosys)
make formal
```

### 4. Synthesis Optimization

#### ECP5 Specific
- Target DRAM-only version for prototyping (~28 pins, 850-890 LUTs)
- Use `synth_ecp5.sh` for automated synthesis
- Check `.lpf` constraints for pin assignments

#### Resource Monitoring
- LUT utilization: Target <4% for ECP5-25F
- FF utilization: Target <2%
- I/O utilization: ~14% for DRAM interface

## Code Quality Standards

### Commenting Guidelines

#### File Headers
```scala
/**
 * Component Name
 *
 * Brief description of component purpose and functionality.
 * Include datasheet section references where applicable.
 *
 * @param param1 Description of parameter
 * @param param2 Description of parameter
 */
case class ComponentName(param1: Type, param2: Type) extends Component {
```

#### Function Documentation
```scala
/**
 * Function purpose and algorithm description.
 *
 * @param input Description of input parameter
 * @return Description of return value
 */
def functionName(input: InputType): ReturnType = {
  // Implementation with inline comments for complex logic
}
```

#### Datasheet References
```scala
// Per datasheet section 2.8: Initialization sequence requirements
// Table 7-1: Command packet formats
// Figure 12-2: DQS read timing relationships
```

### Naming Conventions

#### SpinalHDL Specific
- Use `cfg` for configuration parameters
- Use `io` for component interfaces
- Use `fsm` for state machines
- Use descriptive area names: `timing`, `cmd`, `phy`, `init`

#### Signal Naming
- `valid`/`ready` for stream interfaces
- `fire` for stream transactions
- `payload` for stream data
- `setWhen`/`clearWhen` for register updates

### Error Handling

#### Assertions
```scala
// Compile-time parameter validation
assert(bankCount == 4, s"Bank count must be 4 per datasheet, got $bankCount")

// Runtime checks in simulation
if (cfg.simMode) {
  assert(commandValid, "Invalid command detected")
}
```

#### Debug Signals
```scala
// Simulation-only debug signals
if (cfg.simMode) {
  io.debugSignal.simPublic()
}
```

#### Import Validation
```scala
// Always verify imports are actually used
// Remove unused imports like:
// import spinal.lib.memory.sdram.xdr.{PhyLayout, SdramXdrPhyCtrl, SdramXdrPhyCtrlPhase}
// Should be:
// import spinal.lib.memory.sdram.xdr.PhyLayout
```

#### Dead Code Prevention
```scala
// Remove large commented-out blocks entirely rather than leaving them
// Bad: /* large block of commented code */
// Good: Delete the commented code completely
```

## Performance Optimization Guide

### 1. LUT Reduction Techniques

#### Counter Optimization
```scala
// Good: Minimum bit width
val counter = Counter(log2Up(maxValue) bits)

// Avoid: Over-sized counters
val counter = Counter(32 bits) // Wasteful if max < 1000
```

#### Register Duplication
```scala
// Good: Duplicate critical timing paths
val timingDup = Vec.fill(2)(RegNext(io.timing))

// Avoid: Excessive duplication
val timingDup = Vec.fill(8)(RegNext(io.timing)) // Unnecessary
```

### 2. Timing Critical Paths

#### Pipeline Breaking
```scala
// Use register stages to break long combinational paths
val stage1 = RegNext(complexCalculation1)
val stage2 = RegNext(complexCalculation2 + stage1)
val result = stage2
```

#### Address Decode Pipeline
```scala
// Pipeline address decoding to reduce critical path
val addrDecodeArea = new Area {
  val stage1 = RegNext(io.address)
  val stage2 = RegNext(decodeBank(stage1))
  // Use stage2 for bank selection
}
```

### 3. SpinalHDL Best Practices

#### Component Organization
```scala
case class MyComponent(cfg: Config) extends Component {
  // 1. IO bundle first
  val io = new Bundle { /* ... */ }

  // 2. Internal logic areas
  val area1 = new Area { /* ... */ }
  val area2 = new Area { /* ... */ }

  // 3. Connections last
  area1.io <> area2.io
  io.output := area2.result
}
```

#### Conditional Generation
```scala
// Good: Conditional component generation
val optionalComponent = cfg.enableFeature generate new Area {
  val component = FeatureComponent(cfg)
}

// Avoid: Runtime conditionals for static features
when(cfg.enableFeature) {
  // This creates muxes instead of eliminating logic
}
```

#### Import Best Practices
```scala
// Good: Specific imports only
import spinal.lib.memory.sdram.xdr.PhyLayout
import spinal.lib.blackbox.lattice.ecp5.IDDRX1F

// Avoid: Wildcard imports that hide unused dependencies
// import spinal.lib.memory.sdram.xdr._  // May include unused classes
```

#### Dead Code Prevention
```scala
// Good: Clean removal of unused code
// (no commented-out blocks)

// Bad: Leaving dead code as comments
/*
val unusedVariable = Reg(Bool()) init(False)
// Lots of commented code...
*/
```

## Troubleshooting Guide

### Common Issues

#### Compilation Errors
- Check SpinalHDL version compatibility (v1.12.0 required)
- Verify import statements and package structure - remove unused imports
- Ensure proper case class parameter ordering
- Check for missing documentation on new components

#### Code Quality Issues
- Run comprehensive code review checklist before committing
- Remove any commented-out code blocks completely
- Verify all imports are actually used in the file
- Ensure datasheet references are included in comments

#### Simulation Failures
- Check timing parameters match datasheet values
- Verify clock domain relationships (DDR phases)
- Use `simPublic()` for debugging internal signals
- Validate that cleanup changes didn't break functionality

#### Synthesis Issues
- Review `.lpf`/`.xdc` constraint files
- Check for unregistered outputs causing timing violations
- Verify DDR primitive instantiation
- Ensure import cleanup didn't remove required dependencies

#### Formal Verification
- Ensure `pastValidAfterReset()` usage for temporal properties
- Check stream interface assumptions
- Validate state machine invariants
- Verify formal test cleanup didn't remove important coverage

### Debug Workflow

1. **Isolate the issue**: Run minimal test case
2. **Add debug signals**: Use `simPublic()` for internal signals
3. **Check timing**: Verify clock relationships and delays
4. **Review datasheet**: Ensure compliance with EM6GA16LGDBXCAEA specs
5. **Optimize incrementally**: Make small changes and re-test

## Contribution Guidelines

### Code Review Checklist
- [ ] Code compiles without warnings
- [ ] All tests pass (run `./run_all_tests.sh`)
- [ ] Comments added for complex logic
- [ ] Datasheet references included
- [ ] SpinalHDL best practices followed
- [ ] Resource utilization reasonable
- [ ] No dead code or unused variables

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Example:
```
fix(phy): correct DQS timing phase relationships

Fixed DDR phase calculations per datasheet Figure 12-2.
DQS read now properly aligned with DB signals.

Closes #123
```

## Resources

### Documentation
- [SpinalHDL Guide](https://spinalhdl.github.io/SpinalHDL/)
- [Etron EM6GA16LGDBXCAEA Datasheet](docs/EM6GA16LGDBXCAEA%20datasheet.txt)
- [ECP5 Technical Reference](https://www.latticesemi.com/Products/FPGAandCPLD/ECP5)

### Tools
- [Verilator](https://www.veripool.org/verilator/) for simulation
- [SymbiYosys](https://symbiyosys.readthedocs.io/) for formal verification
- [Yosys + nextpnr-ecp5](https://github.com/YosysHQ/yosys) for synthesis

### Related Projects
- [SpinalHDL Templates](https://github.com/SpinalHDL/SpinalHDL-templates)
- [DFI Specification](https://www.dfi.org/) (inspiration for architecture)

---

*Last updated: September 2025*
*Code review completed: Comprehensive SpinalHDL codebase analysis and optimization*
*Maintained by: opencode development team*