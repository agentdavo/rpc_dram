# RPC DRAM Controller Timing Constraints for Xilinx Artix-7
# Target: XC7A100T, Speed Grade -2
# DRAM Interface: 800 MHz DDR (1.25ns period)

# =============================================================================
# Clock Constraints
# =============================================================================

# Core clock (400 MHz to generate 800 MHz DDR via 2:1 ratio)
create_clock -period 2.5 -name core_clk [get_ports clk]
# DDR clock output (800 MHz)
create_generated_clock -name ddr_clk -source [get_clocks core_clk] -divide_by 1 -multiply_by 2 [get_ports ddr_clk_p]
create_generated_clock -name ddr_clk_n -source [get_clocks core_clk] -divide_by 1 -multiply_by 2 -invert [get_ports ddr_clk_n]

# STB clock (90° phase shift from core clock)
create_generated_clock -name stb_clk -source [get_clocks core_clk] -divide_by 1 -phase 90 [get_ports stb]

# =============================================================================
# I/O Constraints
# =============================================================================

# DRAM Data Bus (x16 interface, SSTL15 class I)
set_property IOSTANDARD SSTL15 [get_ports {db[*]}]
set_property SLEW FAST [get_ports {db[*]}]
set_input_delay -clock ddr_clk -max 0.5 [get_ports {db[*]}]
set_output_delay -clock ddr_clk -max 0.5 [get_ports {db[*]}]

# DQS Signals (differential, SSTL15)
set_property IOSTANDARD DIFF_SSTL15 [get_ports {dqs_p[*] dqs_n[*]}]
set_property SLEW FAST [get_ports {dqs_p[*] dqs_n[*]}]
set_input_delay -clock ddr_clk -max 0.5 [get_ports {dqs_p[*] dqs_n[*]}]
set_output_delay -clock ddr_clk -max 0.5 [get_ports {dqs_p[*] dqs_n[*]}]

# DQS1 Signals (differential, SSTL15)
set_property IOSTANDARD DIFF_SSTL15 [get_ports {dqs1_p[*] dqs1_n[*]}]
set_property SLEW FAST [get_ports {dqs1_p[*] dqs1_n[*]}]
set_input_delay -clock ddr_clk -max 0.5 [get_ports {dqs1_p[*] dqs1_n[*]}]
set_output_delay -clock ddr_clk -max 0.5 [get_ports {dqs1_p[*] dqs1_n[*]}]

# Control Signals (SSTL15)
set_property IOSTANDARD SSTL15 [get_ports {cs_n[*] stb reset_n odt}]
set_property SLEW FAST [get_ports {cs_n[*] stb reset_n odt}]
set_output_delay -clock core_clk -max 0.5 [get_ports {cs_n[*] stb reset_n odt}]

# =============================================================================
# Phase Relationships (Critical for DDR Timing)
# =============================================================================

# STB signal 90° phase shift from clock
set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *stb_phase*]

# DQS write center-aligned (270° phase shift)
set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *dqs_write_phase*]

# DQS read edge-aligned (0° phase shift)
set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *dqs_read_phase*]

# =============================================================================
# IDELAY Calibration Constraints
# =============================================================================

# IDELAYCTRL for DQS calibration
create_generated_clock -name idelay_ref -source [get_clocks core_clk] -divide_by 1 [get_pins -hierarchical *idelayctrl_inst/REFCLK]
set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *idelay_inst]

# =============================================================================
# Multi-Rank Support
# =============================================================================

# CS signals are independent per rank
set_property IOSTANDARD SSTL15 [get_ports {cs_n[*]}]
set_property SLEW FAST [get_ports {cs_n[*]}]
set_output_delay -clock core_clk -max 0.5 [get_ports {cs_n[*]}]

# =============================================================================
# False Path Constraints
# =============================================================================

# Calibration logic is asynchronous to main clock
set_false_path -from [get_clocks core_clk] -to [get_cells -hierarchical *calib_*]
set_false_path -from [get_cells -hierarchical *calib_*] -to [get_clocks core_clk]

# =============================================================================
# Physical Constraints (Board-Specific - Update for Your Board)
# =============================================================================

# Pin locations for XC7A100T (example - update for your board)
# set_property PACKAGE_PIN Y18 [get_ports clk]  # Core clock input
# set_property PACKAGE_PIN Y19 [get_ports ddr_clk_p]  # DDR clock P
# set_property PACKAGE_PIN Y20 [get_ports ddr_clk_n]  # DDR clock N
# set_property PACKAGE_PIN W18 [get_ports stb]  # STB signal
# set_property PACKAGE_PIN V18 [get_ports reset_n]  # Reset
# set_property PACKAGE_PIN U18 [get_ports odt]  # ODT
# set_property PACKAGE_PIN T18 [get_ports {cs_n[0]}]  # CS for rank 0
# set_property PACKAGE_PIN R18 [get_ports {cs_n[1]}]  # CS for rank 1 (if multi-rank)
# DB pins (16-bit)
# set_property PACKAGE_PIN V17 [get_ports {db[0]}]
# ... (add all 16 DB pins)
# DQS pins (2 pairs)
# set_property PACKAGE_PIN U17 [get_ports dqs_p[0]]
# set_property PACKAGE_PIN T17 [get_ports dqs_n[0]]
# set_property PACKAGE_PIN R16 [get_ports dqs_p[1]]
# set_property PACKAGE_PIN P16 [get_ports dqs_n[1]]
# DQS1 pins (2 pairs)
# set_property PACKAGE_PIN N17 [get_ports dqs1_p[0]]
# set_property PACKAGE_PIN M17 [get_ports dqs1_n[0]]
# set_property PACKAGE_PIN L16 [get_ports dqs1_p[1]]
# set_property PACKAGE_PIN K16 [get_ports dqs1_n[1]]

# =============================================================================
# Timing Exceptions
# =============================================================================

# STB signal has dedicated routing
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hierarchical *stb*]

# Multi-cycle paths for calibration
set_multicycle_path -from [get_cells -hierarchical *calib_*] -to [get_cells -hierarchical *idelay_*] 2
set_multicycle_path -from [get_cells -hierarchical *idelay_*] -to [get_cells -hierarchical *calib_*] 2