# RPC DRAM Makefile
# Provides convenient targets for building and testing

.PHONY: all compile clean test test-quick test-all test-report help synth-ecp5 synth-ecp5-12k synth-ecp5-25k synth-ecp5-45k synth-ecp5-85k

# Default target
all: compile

# Compile the project
compile:
	@echo "Compiling RPC DRAM Controller..."
	@sbt compile

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@sbt clean
	@rm -rf simWorkspace/
	@rm -f test_report.html
	@rm -f *.fst *.vcd

# Run quick tests
test-quick: compile
	@echo "Running quick test suite..."
	@./run_quick_tests.sh

# Run all tests
test-all: compile
	@echo "Running comprehensive test suite..."
	@./run_all_tests.sh

# Run tests and generate HTML report
test-report: compile
	@echo "Running tests and generating report..."
	@python3 generate_test_report.py

# Run quick test report
test-quick-report: compile
	@echo "Running quick test report..."
	@python3 quick_test_report.py

# Run medium test report
test-medium-report: compile
	@echo "Running medium test report..."
	@python3 medium_test_report.py

# Alias for test-quick
test: test-quick

# Generate Verilog
verilog: compile
	@echo "Generating Verilog..."
	@sbt "runMain rpcdram.RpcDramVerilog"
	@echo "Verilog generated in hw/gen/"

# Generate DRAM-only Verilog (minimal pin count for FPGA testing)
verilog-dram-only: compile
	@echo "Generating DRAM-only Verilog..."
	@sbt "runMain rpcdram.RpcDramDramOnlyVerilog"
	@echo "DRAM-only Verilog generated in hw/gen/"

# ECP5 FPGA synthesis (DRAM-only version with ~22 pins)
synth-ecp5: verilog-dram-only
	@echo "Running ECP5 synthesis..."
	@cd hw/boards/ecp5 && ./synth_ecp5.sh

synth-ecp5-12k: verilog-dram-only
	@echo "Running ECP5 synthesis for LFE5U-12F..."
	@cd hw/boards/ecp5 && ./synth_ecp5.sh LFE5U-12F CABGA381 8

synth-ecp5-25k: verilog-dram-only
	@echo "Running ECP5 synthesis for LFE5U-25F..."
	@cd hw/boards/ecp5 && ./synth_ecp5.sh LFE5U-25F CABGA381 8

synth-ecp5-45k: verilog-dram-only
	@echo "Running ECP5 synthesis for LFE5U-45F..."
	@cd hw/boards/ecp5 && ./synth_ecp5.sh LFE5U-45F CABGA554 8

synth-ecp5-85k: verilog-dram-only
	@echo "Running ECP5 synthesis for LFE5U-85F..."
	@cd hw/boards/ecp5 && ./synth_ecp5.sh LFE5U-85F CABGA756 8

# Run specific simulations
sim-phy:
	@sbt "runMain rpcdram.sim.PhySim"

sim-controller:
	@sbt "runMain rpcdram.sim.ControllerBasicSim"

sim-bmb:
	@sbt "runMain rpcdram.sim.BmbInterfaceSim"

sim-bmb-minimal:
	@sbt "runMain rpcdram.sim.BmbMinimalTest"

sim-word-transfer:
	@sbt "runMain rpcdram.sim.WordTransferSim"

sim-burst:
	@sbt "runMain rpcdram.sim.BurstTransferSim"

sim-phase:
	@sbt "runMain rpcdram.sim.PhaseAnalysisSim"

sim-chapter8:
	@sbt "runMain rpcdram.sim.Chapter8ComplianceSim"

# Run formal verification
formal:
	@echo "Running formal verification..."
	@sbt "runMain rpcdram.formal.BankTrackerBasicFormal"
	@sbt "runMain rpcdram.formal.InitSequencerFormal"
	@sbt "runMain rpcdram.formal.CmdSchedulerTimingFormal"

# Watch for changes and recompile
watch:
	@sbt "~compile"

# Help target
help:
	@echo "RPC DRAM Controller - Available targets:"
	@echo ""
	@echo "  make compile      - Compile the project"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make test         - Run quick test suite"
	@echo "  make test-quick   - Run quick test suite"
	@echo "  make test-all     - Run comprehensive test suite"
	@echo "  make test-report  - Run tests and generate HTML report"
	@echo "  make test-quick-report - Run quick tests with summary report"
	@echo "  make test-medium-report - Run medium test suite with HTML report"
	@echo "  make verilog      - Generate Verilog output"
	@echo "  make synth-ecp5   - Synthesize for ECP5 FPGA (default LFE5U-25F)"
	@echo "  make synth-ecp5-12k - Synthesize for ECP5 LFE5U-12F"
	@echo "  make synth-ecp5-25k - Synthesize for ECP5 LFE5U-25F"
	@echo "  make synth-ecp5-45k - Synthesize for ECP5 LFE5U-45F"
	@echo "  make synth-ecp5-85k - Synthesize for ECP5 LFE5U-85F"
	@echo ""
	@echo "Specific simulations:"
	@echo "  make sim-phy            - Run PHY simulation"
	@echo "  make sim-controller     - Run basic controller simulation"
	@echo "  make sim-bmb           - Run BMB interface simulation"
	@echo "  make sim-bmb-minimal   - Run minimal BMB test"
	@echo "  make sim-word-transfer - Run word transfer simulation"
	@echo "  make sim-burst         - Run burst transfer simulation"
	@echo "  make sim-phase         - Run phase analysis simulation"
	@echo "  make sim-chapter8      - Run Chapter 8 compliance simulation"
	@echo ""
	@echo "Other targets:"
	@echo "  make formal       - Run formal verification"
	@echo "  make watch        - Watch for changes and recompile"
	@echo "  make help         - Show this help message"