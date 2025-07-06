#!/bin/bash

# RPC DRAM Test Runner Script
# Runs all simulation tests and reports results

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
declare -A test_results
declare -A test_times
total_tests=0
passed_tests=0
failed_tests=0
skipped_tests=0

# Start time
start_time=$(date +%s)

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}RPC DRAM Comprehensive Test Suite${NC}"
echo -e "${BLUE}======================================${NC}"
echo "Started at: $(date)"
echo ""

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    local timeout_seconds=${3:-60}  # Default 60 seconds timeout
    
    total_tests=$((total_tests + 1))
    echo -e "${YELLOW}[$total_tests] Running: $test_name${NC}"
    echo "Command: sbt \"runMain $test_command\""
    
    # Create a temporary file for output
    local temp_output=$(mktemp)
    local test_start=$(date +%s)
    
    # Run the test with timeout
    if timeout $timeout_seconds sbt "runMain $test_command" > "$temp_output" 2>&1; then
        local test_end=$(date +%s)
        local test_duration=$((test_end - test_start))
        test_times["$test_name"]=$test_duration
        
        # Check for actual success in output
        if grep -q "SUCCESS\|success\|Test complete\|Simulation complete\|All tests passed" "$temp_output"; then
            echo -e "${GREEN}✓ PASSED${NC} (${test_duration}s)"
            test_results["$test_name"]="PASSED"
            passed_tests=$((passed_tests + 1))
        elif grep -q "ERROR\|FAILED\|Exception\|SpinalExit" "$temp_output"; then
            echo -e "${RED}✗ FAILED${NC} (${test_duration}s)"
            test_results["$test_name"]="FAILED"
            failed_tests=$((failed_tests + 1))
            # Show error details
            echo "Error details:"
            grep -A2 -B2 "ERROR\|FAILED\|Exception" "$temp_output" | head -10
        else
            echo -e "${YELLOW}? UNCLEAR${NC} (${test_duration}s) - Check output"
            test_results["$test_name"]="UNCLEAR"
            failed_tests=$((failed_tests + 1))
        fi
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}✗ TIMEOUT${NC} (>${timeout_seconds}s)"
            test_results["$test_name"]="TIMEOUT"
            failed_tests=$((failed_tests + 1))
        else
            echo -e "${RED}✗ FAILED${NC} (exit code: $exit_code)"
            test_results["$test_name"]="FAILED"
            failed_tests=$((failed_tests + 1))
            # Show error details
            tail -20 "$temp_output" | grep -E "error|Error|Exception" | head -10
        fi
    fi
    
    # Clean up
    rm -f "$temp_output"
    echo ""
}

# Compile project first
echo -e "${BLUE}Compiling project...${NC}"
if sbt compile > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}✗ Compilation failed${NC}"
    echo "Please fix compilation errors before running tests"
    exit 1
fi
echo ""

# Run all tests
echo -e "${BLUE}Running simulation tests...${NC}"
echo ""

# PHY Tests
run_test "Quick Test" "rpcdram.sim.QuickTest" 30
run_test "Calibration" "rpcdram.sim.CalibrationTest" 30
run_test "Phase Analysis" "rpcdram.sim.PhaseAnalysisTest" 30
run_test "Word Transfer" "rpcdram.sim.WordTransferTest" 30
run_test "Burst Transfer" "rpcdram.sim.BurstTransferTest" 30

# Controller Tests
run_test "Controller Basic" "rpcdram.sim.ControllerBasicTest" 60
run_test "Controller Complete" "rpcdram.sim.ControllerCompleteTest" 60
run_test "Command Flow" "rpcdram.sim.CommandFlowTest" 60
run_test "Byte Masking" "rpcdram.sim.ByteMaskingTest" 30

# Command Compliance Tests
run_test "Serial Commands" "rpcdram.sim.SerialCommandTest" 30
run_test "Chapter 8 Compliance" "rpcdram.sim.Chapter8ComplianceTest" 30

# Interface Tests
run_test "BMB Interface" "rpcdram.sim.BmbInterfaceTest" 120  # New comprehensive BMB test
run_test "BMB Minimal" "rpcdram.sim.BmbMinimalTest" 30
run_test "BMB Debug" "rpcdram.sim.BmbDebugTest" 120  # Debug test with init monitoring

# Additional tests
run_test "Init Only" "rpcdram.sim.InitOnlyTest" 120
run_test "User Cmd Debug" "rpcdram.sim.UserCmdDebugTest" 60
run_test "Detailed Debug" "rpcdram.sim.DetailedDebugTest" 60
run_test "MRS UTR Test" "rpcdram.sim.MrsUtrTest" 30

# Calculate total time
end_time=$(date +%s)
total_time=$((end_time - start_time))

# Print summary
echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo "Total tests run: $total_tests"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: ${RED}$failed_tests${NC}"
echo -e "Success rate: $(( passed_tests * 100 / total_tests ))%"
echo "Total time: ${total_time}s"
echo ""

# Detailed results
echo -e "${BLUE}Detailed Results:${NC}"
for test in "${!test_results[@]}"; do
    result=${test_results[$test]}
    time=${test_times[$test]:-"N/A"}
    
    case $result in
        "PASSED")
            echo -e "  ${GREEN}✓${NC} $test (${time}s)"
            ;;
        "FAILED")
            echo -e "  ${RED}✗${NC} $test"
            ;;
        "TIMEOUT")
            echo -e "  ${RED}⏱${NC} $test (timeout)"
            ;;
        *)
            echo -e "  ${YELLOW}?${NC} $test"
            ;;
    esac
done

echo ""
echo "Completed at: $(date)"

# Exit with appropriate code
if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi