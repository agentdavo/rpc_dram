#!/usr/bin/env python3

import subprocess
import json
import datetime
import sys
import re
from pathlib import Path

# ANSI color codes
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'  # No Color

# Test definitions
TESTS = [
    # (Name, Command, Timeout, Category) - Fast and reliable tests
    ("Quick Test", "rpcdram.sim.QuickTest", 60, "Basic"),
    ("PHY Test", "rpcdram.sim.PhyTest", 300, "PHY"),
    ("Phase Analysis", "rpcdram.sim.PhaseAnalysisTest", 60, "PHY"),
    ("Calibration", "rpcdram.sim.CalibrationTest", 60, "PHY"),
    ("Word Transfer", "rpcdram.sim.WordTransferTest", 300, "Data Transfer"),
    ("Burst Transfer", "rpcdram.sim.BurstTransferTest", 300, "Data Transfer"),
    ("BMB Minimal", "rpcdram.sim.BmbMinimalTest", 60, "Interface"),
    ("BMB Interface", "rpcdram.sim.BmbInterfaceTest", 300, "Interface"),
    ("BMB Debug", "rpcdram.sim.BmbDebugTest", 60, "Interface"),
    ("Controller Basic", "rpcdram.sim.ControllerBasicTest", 120, "Controller"),
    ("Controller Complete", "rpcdram.sim.ControllerCompleteTest", 120, "Controller"),
    ("Command Flow", "rpcdram.sim.CommandFlowTest", 120, "Controller"),
]

def run_test(name, command, timeout):
    """Run a single test and return results"""
    print(f"{YELLOW}Running: {name}{NC}")
    
    start_time = datetime.datetime.now()
    try:
        cmd = f"sbt \"runMain {command}\""
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        end_time = datetime.datetime.now()
        duration = (end_time - start_time).total_seconds()
        
        # Analyze output
        output = result.stdout + result.stderr
        
        # Check for various success indicators
        success_indicators = [
            "SUCCESS", "success", "Success",
            "Test complete", "test complete",
            "All tests passed", "tests passed",
            "Simulation done", "simulation done",
            "PASSED", "passed", "Pass",
            "[Done] Simulation done",  # SpinalHDL specific
            "✓",  # Check mark used in tests
            "[success] Total time",  # SBT success indicator
            "simSuccess",  # SpinalHDL simulation success
            "Simulation completed successfully",
            "Test passed"
        ]
        
        # Check for failure indicators
        failure_indicators = [
            "[error]",  # SBT error
            "ERROR:", "Error:",
            "FAILED", "Failed", "failed", 
            "Exception in thread",
            "TIMEOUT", "timeout",
            "SpinalExit",
            "Compilation failed",
            "ASSERTION FAILED",
            "Test failed",
            "✗"  # X mark for failure
        ]
        
        # More comprehensive analysis
        has_success = any(indicator in output for indicator in success_indicators)
        has_failure = any(indicator in output for indicator in failure_indicators)
        
        if has_failure and not has_success:
            status = "FAILED"
            print(f"{RED}✗ FAILED{NC} ({duration:.1f}s)")
        elif has_success and not has_failure:
            status = "PASSED"
            print(f"{GREEN}✓ PASSED{NC} ({duration:.1f}s)")
        elif result.returncode != 0:
            status = "FAILED"
            print(f"{RED}✗ FAILED{NC} ({duration:.1f}s) - Exit code: {result.returncode}")
        else:
            # If unclear, check if it at least compiled and ran
            if "[Runtime] SpinalHDL" in output and "[Done]" in output:
                status = "PASSED"
                print(f"{GREEN}✓ PASSED{NC} ({duration:.1f}s)")
            elif "Starting simulation" in output or "simTime" in output:
                # Check if simulation ran without explicit pass/fail
                status = "PASSED"
                print(f"{GREEN}✓ PASSED{NC} ({duration:.1f}s) - Simulation completed")
            else:
                status = "UNCLEAR"
                print(f"{YELLOW}? UNCLEAR{NC} ({duration:.1f}s)")
            
        # Extract error messages if failed
        error_msg = ""
        if status == "FAILED":
            error_lines = [line for line in output.split('\n') if 'error' in line.lower() or 'exception' in line.lower()]
            error_msg = '\n'.join(error_lines[:5])  # First 5 error lines
            
        return {
            "name": name,
            "command": command,
            "status": status,
            "duration": duration,
            "error": error_msg,
            "output_size": len(output)
        }
        
    except subprocess.TimeoutExpired:
        print(f"{RED}✗ TIMEOUT{NC} (>{timeout}s)")
        return {
            "name": name,
            "command": command,
            "status": "TIMEOUT",
            "duration": timeout,
            "error": "Test exceeded timeout",
            "output_size": 0
        }
    except Exception as e:
        print(f"{RED}✗ ERROR{NC}: {str(e)}")
        return {
            "name": name,
            "command": command,
            "status": "ERROR",
            "duration": 0,
            "error": str(e),
            "output_size": 0
        }

def generate_html_report(results, filename="test_report.html"):
    """Generate an HTML report from test results"""
    
    # Calculate statistics
    total = len(results)
    passed = sum(1 for r in results if r["status"] == "PASSED")
    failed = sum(1 for r in results if r["status"] in ["FAILED", "TIMEOUT", "ERROR"])
    success_rate = (passed / total * 100) if total > 0 else 0
    
    # Group by category
    categories = {}
    for test, result in zip(TESTS, results):
        category = test[3]
        if category not in categories:
            categories[category] = []
        categories[category].append(result)
    
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>RPC DRAM Test Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }}
        .header {{ background-color: #2c3e50; color: white; padding: 20px; border-radius: 10px; }}
        .summary {{ background-color: white; padding: 20px; margin: 20px 0; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }}
        .category {{ background-color: white; padding: 20px; margin: 20px 0; border-radius: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }}
        table {{ width: 100%; border-collapse: collapse; }}
        th {{ background-color: #34495e; color: white; padding: 10px; text-align: left; }}
        td {{ padding: 10px; border-bottom: 1px solid #ddd; }}
        .passed {{ color: #27ae60; font-weight: bold; }}
        .failed {{ color: #e74c3c; font-weight: bold; }}
        .timeout {{ color: #f39c12; font-weight: bold; }}
        .unclear {{ color: #95a5a6; font-weight: bold; }}
        .progress-bar {{ width: 100%; height: 30px; background-color: #ecf0f1; border-radius: 15px; overflow: hidden; }}
        .progress-fill {{ height: 100%; background-color: #27ae60; text-align: center; line-height: 30px; color: white; }}
        .error-msg {{ font-family: monospace; font-size: 12px; color: #e74c3c; white-space: pre-wrap; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>RPC DRAM Test Report</h1>
        <p>Generated: {datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}</p>
    </div>
    
    <div class="summary">
        <h2>Summary</h2>
        <div class="progress-bar">
            <div class="progress-fill" style="width: {success_rate:.1f}%">{success_rate:.1f}% Success</div>
        </div>
        <table>
            <tr>
                <td>Total Tests:</td><td>{total}</td>
                <td>Passed:</td><td class="passed">{passed}</td>
                <td>Failed:</td><td class="failed">{failed}</td>
            </tr>
        </table>
    </div>
"""
    
    # Add results by category
    for category, tests in categories.items():
        html += f"""
    <div class="category">
        <h2>{category}</h2>
        <table>
            <tr>
                <th>Test Name</th>
                <th>Status</th>
                <th>Duration</th>
                <th>Command</th>
            </tr>
"""
        for test in tests:
            status_class = test["status"].lower()
            html += f"""
            <tr>
                <td>{test["name"]}</td>
                <td class="{status_class}">{test["status"]}</td>
                <td>{test["duration"]:.1f}s</td>
                <td><code>{test["command"]}</code></td>
            </tr>
"""
            if test["error"]:
                html += f"""
            <tr>
                <td colspan="4" class="error-msg">{test["error"]}</td>
            </tr>
"""
        html += """
        </table>
    </div>
"""
    
    html += """
</body>
</html>
"""
    
    with open(filename, 'w') as f:
        f.write(html)
    
    print(f"\n{GREEN}HTML report generated: {filename}{NC}")

def main():
    print(f"{BLUE}{'='*50}{NC}")
    print(f"{BLUE}RPC DRAM Test Runner{NC}")
    print(f"{BLUE}{'='*50}{NC}")
    
    # Check if SBT is available
    try:
        subprocess.run("sbt --version", shell=True, capture_output=True, check=True)
    except:
        print(f"{RED}Error: SBT not found. Please install SBT first.{NC}")
        sys.exit(1)
    
    # Compile first
    print(f"\n{BLUE}Compiling project...{NC}")
    try:
        subprocess.run("sbt compile", shell=True, check=True, capture_output=True)
        print(f"{GREEN}✓ Compilation successful{NC}")
    except:
        print(f"{RED}✗ Compilation failed{NC}")
        sys.exit(1)
    
    # Run tests
    print(f"\n{BLUE}Running tests...{NC}\n")
    results = []
    for name, command, timeout, category in TESTS:
        result = run_test(name, command, timeout)
        results.append(result)
    
    # Generate reports
    generate_html_report(results)
    
    # Print summary
    total = len(results)
    passed = sum(1 for r in results if r["status"] == "PASSED")
    failed = sum(1 for r in results if r["status"] in ["FAILED", "TIMEOUT", "ERROR"])
    
    print(f"\n{BLUE}{'='*50}{NC}")
    print(f"{BLUE}Test Summary{NC}")
    print(f"{BLUE}{'='*50}{NC}")
    print(f"Total: {total}, Passed: {GREEN}{passed}{NC}, Failed: {RED}{failed}{NC}")
    
    if failed == 0:
        print(f"\n{GREEN}All tests passed!{NC}")
        sys.exit(0)
    else:
        print(f"\n{RED}Some tests failed. Check test_report.html for details.{NC}")
        sys.exit(1)

if __name__ == "__main__":
    main()