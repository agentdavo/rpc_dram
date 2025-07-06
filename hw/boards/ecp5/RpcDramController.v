// Generator : SpinalHDL v1.12.0    git head : 1aa7d7b5732f11cca2dd83bacc2a4cb92ca8e5c9
// Component : RpcDramDramOnly
// Git hash  : ced6f502d438639b5a40ab8ad1774eee5672c8b2

`timescale 1ns/1ps

module RpcDramDramOnly (
  output wire          io_dram_clkP,
  output wire          io_dram_clkN,
  output wire          io_dram_csN_0,
  output wire          io_dram_stb,
  output wire          io_dram_resetN,
  output wire          io_dram_odt,
  inout  wire [15:0]   io_dramDb,
  inout  wire [1:0]    io_dramDqs,
  inout  wire [1:0]    io_dramDqs1,
  input  wire          reset,
  input  wire          clk
);

  wire                controller_io_ctrlIO_user_cmd_ready;
  wire                controller_io_ctrlIO_user_writeData_ready;
  wire                controller_io_ctrlIO_user_readData_valid;
  wire                controller_io_ctrlIO_user_readData_payload_last;
  wire       [255:0]  controller_io_ctrlIO_user_readData_payload_fragment;
  wire                controller_io_ctrlIO_dram_clkP;
  wire                controller_io_ctrlIO_dram_clkN;
  wire                controller_io_ctrlIO_dram_csN_0;
  wire                controller_io_ctrlIO_dram_stb;
  wire                controller_io_ctrlIO_dram_resetN;
  wire                controller_io_ctrlIO_dram_odt;
  wire                controller_io_ctrlIO_powerCtrl_reInitRequired;

  RpcDramController controller (
    .io_ctrlIO_user_cmd_valid                  (1'b0                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_cmd_ready                  (controller_io_ctrlIO_user_cmd_ready                                                                                                                                                                                                                                  ), //o
    .io_ctrlIO_user_cmd_payload_isWrite        (1'bx                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_cmd_payload_address        (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_cmd_payload_burstLen       (6'bxxxxxx                                                                                                                                                                                                                                                            ), //i
    .io_ctrlIO_user_cmd_payload_writeMask      (256'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx), //i
    .io_ctrlIO_user_writeData_valid            (1'b0                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_writeData_ready            (controller_io_ctrlIO_user_writeData_ready                                                                                                                                                                                                                            ), //o
    .io_ctrlIO_user_writeData_payload_last     (1'bx                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_writeData_payload_fragment (256'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx), //i
    .io_ctrlIO_user_readData_valid             (controller_io_ctrlIO_user_readData_valid                                                                                                                                                                                                                             ), //o
    .io_ctrlIO_user_readData_ready             (1'b1                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_user_readData_payload_last      (controller_io_ctrlIO_user_readData_payload_last                                                                                                                                                                                                                      ), //o
    .io_ctrlIO_user_readData_payload_fragment  (controller_io_ctrlIO_user_readData_payload_fragment[255:0]                                                                                                                                                                                                           ), //o
    .io_ctrlIO_dram_clkP                       (controller_io_ctrlIO_dram_clkP                                                                                                                                                                                                                                       ), //o
    .io_ctrlIO_dram_clkN                       (controller_io_ctrlIO_dram_clkN                                                                                                                                                                                                                                       ), //o
    .io_ctrlIO_dram_csN_0                      (controller_io_ctrlIO_dram_csN_0                                                                                                                                                                                                                                      ), //o
    .io_ctrlIO_dram_stb                        (controller_io_ctrlIO_dram_stb                                                                                                                                                                                                                                        ), //o
    .io_ctrlIO_dram_resetN                     (controller_io_ctrlIO_dram_resetN                                                                                                                                                                                                                                     ), //o
    .io_ctrlIO_dram_odt                        (controller_io_ctrlIO_dram_odt                                                                                                                                                                                                                                        ), //o
    .io_ctrlIO_powerCtrl_enterPd               (1'b0                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_powerCtrl_exitPd                (1'b0                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_powerCtrl_enterDpd              (1'b0                                                                                                                                                                                                                                                                 ), //i
    .io_ctrlIO_powerCtrl_reInitRequired        (controller_io_ctrlIO_powerCtrl_reInitRequired                                                                                                                                                                                                                        ), //o
    .io_dramDb                                 (io_dramDb                                                                                                                                                                                                                                                            ), //~
    .io_dramDqs                                (io_dramDqs                                                                                                                                                                                                                                                           ), //~
    .io_dramDqs1                               (io_dramDqs1                                                                                                                                                                                                                                                          ), //~
    .reset                                     (reset                                                                                                                                                                                                                                                                ), //i
    .clk                                       (clk                                                                                                                                                                                                                                                                  )  //i
  );
  assign io_dram_clkP = controller_io_ctrlIO_dram_clkP;
  assign io_dram_clkN = controller_io_ctrlIO_dram_clkN;
  assign io_dram_csN_0 = controller_io_ctrlIO_dram_csN_0;
  assign io_dram_stb = controller_io_ctrlIO_dram_stb;
  assign io_dram_resetN = controller_io_ctrlIO_dram_resetN;
  assign io_dram_odt = controller_io_ctrlIO_dram_odt;

endmodule

module RpcDramController (
  input  wire          io_ctrlIO_user_cmd_valid,
  output wire          io_ctrlIO_user_cmd_ready,
  input  wire          io_ctrlIO_user_cmd_payload_isWrite,
  input  wire [31:0]   io_ctrlIO_user_cmd_payload_address,
  input  wire [5:0]    io_ctrlIO_user_cmd_payload_burstLen,
  input  wire [255:0]  io_ctrlIO_user_cmd_payload_writeMask,
  input  wire          io_ctrlIO_user_writeData_valid,
  output wire          io_ctrlIO_user_writeData_ready,
  input  wire          io_ctrlIO_user_writeData_payload_last,
  input  wire [255:0]  io_ctrlIO_user_writeData_payload_fragment,
  output wire          io_ctrlIO_user_readData_valid,
  input  wire          io_ctrlIO_user_readData_ready,
  output wire          io_ctrlIO_user_readData_payload_last,
  output wire [255:0]  io_ctrlIO_user_readData_payload_fragment,
  output wire          io_ctrlIO_dram_clkP,
  output wire          io_ctrlIO_dram_clkN,
  output wire          io_ctrlIO_dram_csN_0,
  output wire          io_ctrlIO_dram_stb,
  output wire          io_ctrlIO_dram_resetN,
  output wire          io_ctrlIO_dram_odt,
  input  wire          io_ctrlIO_powerCtrl_enterPd,
  input  wire          io_ctrlIO_powerCtrl_exitPd,
  input  wire          io_ctrlIO_powerCtrl_enterDpd,
  output wire          io_ctrlIO_powerCtrl_reInitRequired,
  inout  wire [15:0]   io_dramDb,
  inout  wire [1:0]    io_dramDqs,
  inout  wire [1:0]    io_dramDqs1,
  input  wire          reset,
  input  wire          clk
);
  localparam BankState_IDLE = 2'd0;
  localparam BankState_ACTIVATING = 2'd1;
  localparam BankState_ACTIVE = 2'd2;
  localparam BankState_PRECHARGING = 2'd3;

  wire                init_sequencer_io_start;
  wire                power_manager_io_isIdle;
  wire       [19:0]   timing_regs_io_current_tCke;
  wire       [19:0]   timing_regs_io_current_tDpd;
  wire       [7:0]    timing_regs_io_current_tRcd;
  wire       [7:0]    timing_regs_io_current_tRp;
  wire       [7:0]    timing_regs_io_current_tWr;
  wire       [7:0]    timing_regs_io_current_tRas;
  wire       [7:0]    timing_regs_io_current_tRrd;
  wire       [7:0]    timing_regs_io_current_tPpd;
  wire       [11:0]   timing_regs_io_current_tZqInit;
  wire       [7:0]    timing_regs_io_current_tFaw;
  wire       [7:0]    timing_regs_io_current_tRfc;
  wire       [7:0]    timing_regs_io_current_tPhyWrLat;
  wire       [7:0]    timing_regs_io_current_tPhyRdLat;
  wire       [7:0]    timing_regs_io_current_tPhyWrData;
  wire       [7:0]    timing_regs_io_current_tRddataEn;
  wire                banks_tracker_io_cmd_activate_ready;
  wire                banks_tracker_io_cmd_precharge_ready;
  wire       [1:0]    banks_tracker_io_status_bankStates_0;
  wire       [1:0]    banks_tracker_io_status_bankStates_1;
  wire       [1:0]    banks_tracker_io_status_bankStates_2;
  wire       [1:0]    banks_tracker_io_status_bankStates_3;
  wire       [11:0]   banks_tracker_io_status_openRow_0;
  wire       [11:0]   banks_tracker_io_status_openRow_1;
  wire       [11:0]   banks_tracker_io_status_openRow_2;
  wire       [11:0]   banks_tracker_io_status_openRow_3;
  wire                init_sequencer_io_cmdOut_valid;
  wire                init_sequencer_io_cmdOut_payload_isSerial;
  wire       [5:0]    init_sequencer_io_cmdOut_payload_opcode;
  wire       [1:0]    init_sequencer_io_cmdOut_payload_bank;
  wire       [11:0]   init_sequencer_io_cmdOut_payload_rowAddr;
  wire       [9:0]    init_sequencer_io_cmdOut_payload_colAddr;
  wire       [5:0]    init_sequencer_io_cmdOut_payload_burstCount;
  wire       [255:0]  init_sequencer_io_cmdOut_payload_writeMask;
  wire                init_sequencer_io_cmdOut_payload_odt;
  wire                init_sequencer_io_initDone;
  wire                cmd_scheduler_io_user_cmd_ready;
  wire                cmd_scheduler_io_user_writeData_ready;
  wire                cmd_scheduler_io_user_readData_valid;
  wire                cmd_scheduler_io_user_readData_payload_last;
  wire       [255:0]  cmd_scheduler_io_user_readData_payload_fragment;
  wire                cmd_scheduler_io_initCmd_ready;
  wire                cmd_scheduler_io_refreshCmd_ready;
  wire                cmd_scheduler_io_powerCmd_ready;
  wire                cmd_scheduler_io_toPhy_valid;
  wire                cmd_scheduler_io_toPhy_payload_isSerial;
  wire       [5:0]    cmd_scheduler_io_toPhy_payload_opcode;
  wire       [1:0]    cmd_scheduler_io_toPhy_payload_bank;
  wire       [11:0]   cmd_scheduler_io_toPhy_payload_rowAddr;
  wire       [9:0]    cmd_scheduler_io_toPhy_payload_colAddr;
  wire       [5:0]    cmd_scheduler_io_toPhy_payload_burstCount;
  wire       [255:0]  cmd_scheduler_io_toPhy_payload_writeMask;
  wire                cmd_scheduler_io_toPhy_payload_odt;
  wire                cmd_scheduler_io_toBankTracker_activate_valid;
  wire       [1:0]    cmd_scheduler_io_toBankTracker_activate_payload_bank;
  wire       [11:0]   cmd_scheduler_io_toBankTracker_activate_payload_rowAddr;
  wire                cmd_scheduler_io_toBankTracker_precharge_valid;
  wire       [1:0]    cmd_scheduler_io_toBankTracker_precharge_payload;
  wire                cmd_scheduler_io_fromPhy_ready;
  wire       [3:0]    cmd_scheduler_io_debugInfo_currentState;
  wire                cmd_scheduler_io_debugInfo_timingViolation;
  wire                cmd_scheduler_io_debugInfo_illegalTransition;
  wire                cmd_scheduler_io_debugInfo_burstCountExceeded;
  wire       [2:0]    cmd_scheduler_io_debugInfo_cmdSource;
  wire       [5:0]    cmd_scheduler_io_debugInfo_pendingOpcode;
  wire                cmd_scheduler_io_debugInfo_validationLegal;
  wire                cmd_scheduler_io_debugInfo_validationDone;
  wire                cmd_scheduler_io_debugInfo_bubbleNopActive;
  wire                cmd_scheduler_io_debugInfo_serialCmdLimitViolated;
  wire       [31:0]   cmd_scheduler_io_debugInfo_totalCommands;
  wire       [15:0]   cmd_scheduler_io_debugInfo_timingViolations;
  wire       [15:0]   cmd_scheduler_io_debugInfo_illegalTransitions;
  wire       [15:0]   cmd_scheduler_io_debugInfo_burstLimitViolations;
  wire                refresh_manager_io_toScheduler_valid;
  wire                refresh_manager_io_toScheduler_payload_isSerial;
  wire       [5:0]    refresh_manager_io_toScheduler_payload_opcode;
  wire       [1:0]    refresh_manager_io_toScheduler_payload_bank;
  wire       [11:0]   refresh_manager_io_toScheduler_payload_rowAddr;
  wire       [9:0]    refresh_manager_io_toScheduler_payload_colAddr;
  wire       [5:0]    refresh_manager_io_toScheduler_payload_burstCount;
  wire       [255:0]  refresh_manager_io_toScheduler_payload_writeMask;
  wire                refresh_manager_io_toScheduler_payload_odt;
  wire                power_manager_io_ctrl_reInitRequired;
  wire                power_manager_io_cmdOut_valid;
  wire                power_manager_io_cmdOut_payload_isSerial;
  wire       [5:0]    power_manager_io_cmdOut_payload_opcode;
  wire       [1:0]    power_manager_io_cmdOut_payload_bank;
  wire       [11:0]   power_manager_io_cmdOut_payload_rowAddr;
  wire       [9:0]    power_manager_io_cmdOut_payload_colAddr;
  wire       [5:0]    power_manager_io_cmdOut_payload_burstCount;
  wire       [255:0]  power_manager_io_cmdOut_payload_writeMask;
  wire                power_manager_io_cmdOut_payload_odt;
  wire                power_manager_io_inPowerDown;
  wire                power_manager_io_reInitRequired;
  wire                phy_interface_io_cmdIn_ready;
  wire                phy_interface_io_writeDataIn_ready;
  wire                phy_interface_io_readDataOut_valid;
  wire                phy_interface_io_readDataOut_payload_last;
  wire       [255:0]  phy_interface_io_readDataOut_payload_fragment;
  wire                phy_interface_io_dram_clkP;
  wire                phy_interface_io_dram_clkN;
  wire                phy_interface_io_dram_csN_0;
  wire                phy_interface_io_dram_stb;
  wire                phy_interface_io_dram_resetN;
  wire                phy_interface_io_dram_odt;
  wire                phy_interface_io_calibDone;
  wire       [7:0]    phy_interface_io_calibDelay;
  wire       [3:0]    phy_interface_io_phaseStatus;
  wire                phy_responseStream_valid;
  wire                phy_responseStream_ready;
  wire                phy_responseStream_payload;

  TimingRegs timing_regs (
    .io_update_valid              (1'b0                                  ), //i
    .io_update_payload_tCke       (20'bxxxxxxxxxxxxxxxxxxxx              ), //i
    .io_update_payload_tDpd       (20'bxxxxxxxxxxxxxxxxxxxx              ), //i
    .io_update_payload_tRcd       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tRp        (8'bxxxxxxxx                           ), //i
    .io_update_payload_tWr        (8'bxxxxxxxx                           ), //i
    .io_update_payload_tRas       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tRrd       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tPpd       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tZqInit    (12'bxxxxxxxxxxxx                      ), //i
    .io_update_payload_tFaw       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tRfc       (8'bxxxxxxxx                           ), //i
    .io_update_payload_tPhyWrLat  (8'bxxxxxxxx                           ), //i
    .io_update_payload_tPhyRdLat  (8'bxxxxxxxx                           ), //i
    .io_update_payload_tPhyWrData (8'bxxxxxxxx                           ), //i
    .io_update_payload_tRddataEn  (8'bxxxxxxxx                           ), //i
    .io_current_tCke              (timing_regs_io_current_tCke[19:0]     ), //o
    .io_current_tDpd              (timing_regs_io_current_tDpd[19:0]     ), //o
    .io_current_tRcd              (timing_regs_io_current_tRcd[7:0]      ), //o
    .io_current_tRp               (timing_regs_io_current_tRp[7:0]       ), //o
    .io_current_tWr               (timing_regs_io_current_tWr[7:0]       ), //o
    .io_current_tRas              (timing_regs_io_current_tRas[7:0]      ), //o
    .io_current_tRrd              (timing_regs_io_current_tRrd[7:0]      ), //o
    .io_current_tPpd              (timing_regs_io_current_tPpd[7:0]      ), //o
    .io_current_tZqInit           (timing_regs_io_current_tZqInit[11:0]  ), //o
    .io_current_tFaw              (timing_regs_io_current_tFaw[7:0]      ), //o
    .io_current_tRfc              (timing_regs_io_current_tRfc[7:0]      ), //o
    .io_current_tPhyWrLat         (timing_regs_io_current_tPhyWrLat[7:0] ), //o
    .io_current_tPhyRdLat         (timing_regs_io_current_tPhyRdLat[7:0] ), //o
    .io_current_tPhyWrData        (timing_regs_io_current_tPhyWrData[7:0]), //o
    .io_current_tRddataEn         (timing_regs_io_current_tRddataEn[7:0] ), //o
    .clk                          (clk                                   ), //i
    .reset                        (reset                                 )  //i
  );
  BankTracker banks_tracker (
    .io_cmd_activate_valid           (cmd_scheduler_io_toBankTracker_activate_valid                ), //i
    .io_cmd_activate_ready           (banks_tracker_io_cmd_activate_ready                          ), //o
    .io_cmd_activate_payload_bank    (cmd_scheduler_io_toBankTracker_activate_payload_bank[1:0]    ), //i
    .io_cmd_activate_payload_rowAddr (cmd_scheduler_io_toBankTracker_activate_payload_rowAddr[11:0]), //i
    .io_cmd_precharge_valid          (cmd_scheduler_io_toBankTracker_precharge_valid               ), //i
    .io_cmd_precharge_ready          (banks_tracker_io_cmd_precharge_ready                         ), //o
    .io_cmd_precharge_payload        (cmd_scheduler_io_toBankTracker_precharge_payload[1:0]        ), //i
    .io_status_bankStates_0          (banks_tracker_io_status_bankStates_0[1:0]                    ), //o
    .io_status_bankStates_1          (banks_tracker_io_status_bankStates_1[1:0]                    ), //o
    .io_status_bankStates_2          (banks_tracker_io_status_bankStates_2[1:0]                    ), //o
    .io_status_bankStates_3          (banks_tracker_io_status_bankStates_3[1:0]                    ), //o
    .io_status_openRow_0             (banks_tracker_io_status_openRow_0[11:0]                      ), //o
    .io_status_openRow_1             (banks_tracker_io_status_openRow_1[11:0]                      ), //o
    .io_status_openRow_2             (banks_tracker_io_status_openRow_2[11:0]                      ), //o
    .io_status_openRow_3             (banks_tracker_io_status_openRow_3[11:0]                      ), //o
    .clk                             (clk                                                          ), //i
    .reset                           (reset                                                        )  //i
  );
  InitSequencer init_sequencer (
    .io_start                     (init_sequencer_io_start                          ), //i
    .io_timing_tCke               (timing_regs_io_current_tCke[19:0]                ), //i
    .io_timing_tDpd               (timing_regs_io_current_tDpd[19:0]                ), //i
    .io_timing_tRcd               (timing_regs_io_current_tRcd[7:0]                 ), //i
    .io_timing_tRp                (timing_regs_io_current_tRp[7:0]                  ), //i
    .io_timing_tWr                (timing_regs_io_current_tWr[7:0]                  ), //i
    .io_timing_tRas               (timing_regs_io_current_tRas[7:0]                 ), //i
    .io_timing_tRrd               (timing_regs_io_current_tRrd[7:0]                 ), //i
    .io_timing_tPpd               (timing_regs_io_current_tPpd[7:0]                 ), //i
    .io_timing_tZqInit            (timing_regs_io_current_tZqInit[11:0]             ), //i
    .io_timing_tFaw               (timing_regs_io_current_tFaw[7:0]                 ), //i
    .io_timing_tRfc               (timing_regs_io_current_tRfc[7:0]                 ), //i
    .io_timing_tPhyWrLat          (timing_regs_io_current_tPhyWrLat[7:0]            ), //i
    .io_timing_tPhyRdLat          (timing_regs_io_current_tPhyRdLat[7:0]            ), //i
    .io_timing_tPhyWrData         (timing_regs_io_current_tPhyWrData[7:0]           ), //i
    .io_timing_tRddataEn          (timing_regs_io_current_tRddataEn[7:0]            ), //i
    .io_cmdOut_valid              (init_sequencer_io_cmdOut_valid                   ), //o
    .io_cmdOut_ready              (cmd_scheduler_io_initCmd_ready                   ), //i
    .io_cmdOut_payload_isSerial   (init_sequencer_io_cmdOut_payload_isSerial        ), //o
    .io_cmdOut_payload_opcode     (init_sequencer_io_cmdOut_payload_opcode[5:0]     ), //o
    .io_cmdOut_payload_bank       (init_sequencer_io_cmdOut_payload_bank[1:0]       ), //o
    .io_cmdOut_payload_rowAddr    (init_sequencer_io_cmdOut_payload_rowAddr[11:0]   ), //o
    .io_cmdOut_payload_colAddr    (init_sequencer_io_cmdOut_payload_colAddr[9:0]    ), //o
    .io_cmdOut_payload_burstCount (init_sequencer_io_cmdOut_payload_burstCount[5:0] ), //o
    .io_cmdOut_payload_writeMask  (init_sequencer_io_cmdOut_payload_writeMask[255:0]), //o
    .io_cmdOut_payload_odt        (init_sequencer_io_cmdOut_payload_odt             ), //o
    .io_initDone                  (init_sequencer_io_initDone                       ), //o
    .clk                          (clk                                              ), //i
    .reset                        (reset                                            )  //i
  );
  CmdScheduler cmd_scheduler (
    .io_user_cmd_valid                         (io_ctrlIO_user_cmd_valid                                     ), //i
    .io_user_cmd_ready                         (cmd_scheduler_io_user_cmd_ready                              ), //o
    .io_user_cmd_payload_isWrite               (io_ctrlIO_user_cmd_payload_isWrite                           ), //i
    .io_user_cmd_payload_address               (io_ctrlIO_user_cmd_payload_address[31:0]                     ), //i
    .io_user_cmd_payload_burstLen              (io_ctrlIO_user_cmd_payload_burstLen[5:0]                     ), //i
    .io_user_cmd_payload_writeMask             (io_ctrlIO_user_cmd_payload_writeMask[255:0]                  ), //i
    .io_user_writeData_valid                   (                                                             ), //i
    .io_user_writeData_ready                   (cmd_scheduler_io_user_writeData_ready                        ), //o
    .io_user_writeData_payload_last            (                                                             ), //i
    .io_user_writeData_payload_fragment        (                                                             ), //i
    .io_user_readData_valid                    (cmd_scheduler_io_user_readData_valid                         ), //o
    .io_user_readData_ready                    (                                                             ), //i
    .io_user_readData_payload_last             (cmd_scheduler_io_user_readData_payload_last                  ), //o
    .io_user_readData_payload_fragment         (cmd_scheduler_io_user_readData_payload_fragment[255:0]       ), //o
    .io_initCmd_valid                          (init_sequencer_io_cmdOut_valid                               ), //i
    .io_initCmd_ready                          (cmd_scheduler_io_initCmd_ready                               ), //o
    .io_initCmd_payload_isSerial               (init_sequencer_io_cmdOut_payload_isSerial                    ), //i
    .io_initCmd_payload_opcode                 (init_sequencer_io_cmdOut_payload_opcode[5:0]                 ), //i
    .io_initCmd_payload_bank                   (init_sequencer_io_cmdOut_payload_bank[1:0]                   ), //i
    .io_initCmd_payload_rowAddr                (init_sequencer_io_cmdOut_payload_rowAddr[11:0]               ), //i
    .io_initCmd_payload_colAddr                (init_sequencer_io_cmdOut_payload_colAddr[9:0]                ), //i
    .io_initCmd_payload_burstCount             (init_sequencer_io_cmdOut_payload_burstCount[5:0]             ), //i
    .io_initCmd_payload_writeMask              (init_sequencer_io_cmdOut_payload_writeMask[255:0]            ), //i
    .io_initCmd_payload_odt                    (init_sequencer_io_cmdOut_payload_odt                         ), //i
    .io_refreshCmd_valid                       (refresh_manager_io_toScheduler_valid                         ), //i
    .io_refreshCmd_ready                       (cmd_scheduler_io_refreshCmd_ready                            ), //o
    .io_refreshCmd_payload_isSerial            (refresh_manager_io_toScheduler_payload_isSerial              ), //i
    .io_refreshCmd_payload_opcode              (refresh_manager_io_toScheduler_payload_opcode[5:0]           ), //i
    .io_refreshCmd_payload_bank                (refresh_manager_io_toScheduler_payload_bank[1:0]             ), //i
    .io_refreshCmd_payload_rowAddr             (refresh_manager_io_toScheduler_payload_rowAddr[11:0]         ), //i
    .io_refreshCmd_payload_colAddr             (refresh_manager_io_toScheduler_payload_colAddr[9:0]          ), //i
    .io_refreshCmd_payload_burstCount          (refresh_manager_io_toScheduler_payload_burstCount[5:0]       ), //i
    .io_refreshCmd_payload_writeMask           (refresh_manager_io_toScheduler_payload_writeMask[255:0]      ), //i
    .io_refreshCmd_payload_odt                 (refresh_manager_io_toScheduler_payload_odt                   ), //i
    .io_powerCmd_valid                         (power_manager_io_cmdOut_valid                                ), //i
    .io_powerCmd_ready                         (cmd_scheduler_io_powerCmd_ready                              ), //o
    .io_powerCmd_payload_isSerial              (power_manager_io_cmdOut_payload_isSerial                     ), //i
    .io_powerCmd_payload_opcode                (power_manager_io_cmdOut_payload_opcode[5:0]                  ), //i
    .io_powerCmd_payload_bank                  (power_manager_io_cmdOut_payload_bank[1:0]                    ), //i
    .io_powerCmd_payload_rowAddr               (power_manager_io_cmdOut_payload_rowAddr[11:0]                ), //i
    .io_powerCmd_payload_colAddr               (power_manager_io_cmdOut_payload_colAddr[9:0]                 ), //i
    .io_powerCmd_payload_burstCount            (power_manager_io_cmdOut_payload_burstCount[5:0]              ), //i
    .io_powerCmd_payload_writeMask             (power_manager_io_cmdOut_payload_writeMask[255:0]             ), //i
    .io_powerCmd_payload_odt                   (power_manager_io_cmdOut_payload_odt                          ), //i
    .io_toPhy_valid                            (cmd_scheduler_io_toPhy_valid                                 ), //o
    .io_toPhy_ready                            (phy_interface_io_cmdIn_ready                                 ), //i
    .io_toPhy_payload_isSerial                 (cmd_scheduler_io_toPhy_payload_isSerial                      ), //o
    .io_toPhy_payload_opcode                   (cmd_scheduler_io_toPhy_payload_opcode[5:0]                   ), //o
    .io_toPhy_payload_bank                     (cmd_scheduler_io_toPhy_payload_bank[1:0]                     ), //o
    .io_toPhy_payload_rowAddr                  (cmd_scheduler_io_toPhy_payload_rowAddr[11:0]                 ), //o
    .io_toPhy_payload_colAddr                  (cmd_scheduler_io_toPhy_payload_colAddr[9:0]                  ), //o
    .io_toPhy_payload_burstCount               (cmd_scheduler_io_toPhy_payload_burstCount[5:0]               ), //o
    .io_toPhy_payload_writeMask                (cmd_scheduler_io_toPhy_payload_writeMask[255:0]              ), //o
    .io_toPhy_payload_odt                      (cmd_scheduler_io_toPhy_payload_odt                           ), //o
    .io_toBankTracker_activate_valid           (cmd_scheduler_io_toBankTracker_activate_valid                ), //o
    .io_toBankTracker_activate_ready           (banks_tracker_io_cmd_activate_ready                          ), //i
    .io_toBankTracker_activate_payload_bank    (cmd_scheduler_io_toBankTracker_activate_payload_bank[1:0]    ), //o
    .io_toBankTracker_activate_payload_rowAddr (cmd_scheduler_io_toBankTracker_activate_payload_rowAddr[11:0]), //o
    .io_toBankTracker_precharge_valid          (cmd_scheduler_io_toBankTracker_precharge_valid               ), //o
    .io_toBankTracker_precharge_ready          (banks_tracker_io_cmd_precharge_ready                         ), //i
    .io_toBankTracker_precharge_payload        (cmd_scheduler_io_toBankTracker_precharge_payload[1:0]        ), //o
    .io_fromBankTracker_bankStates_0           (banks_tracker_io_status_bankStates_0[1:0]                    ), //i
    .io_fromBankTracker_bankStates_1           (banks_tracker_io_status_bankStates_1[1:0]                    ), //i
    .io_fromBankTracker_bankStates_2           (banks_tracker_io_status_bankStates_2[1:0]                    ), //i
    .io_fromBankTracker_bankStates_3           (banks_tracker_io_status_bankStates_3[1:0]                    ), //i
    .io_fromBankTracker_openRow_0              (banks_tracker_io_status_openRow_0[11:0]                      ), //i
    .io_fromBankTracker_openRow_1              (banks_tracker_io_status_openRow_1[11:0]                      ), //i
    .io_fromBankTracker_openRow_2              (banks_tracker_io_status_openRow_2[11:0]                      ), //i
    .io_fromBankTracker_openRow_3              (banks_tracker_io_status_openRow_3[11:0]                      ), //i
    .io_fromPhy_valid                          (phy_responseStream_valid                                     ), //i
    .io_fromPhy_ready                          (cmd_scheduler_io_fromPhy_ready                               ), //o
    .io_fromPhy_payload                        (phy_responseStream_payload                                   ), //i
    .io_initDone                               (init_sequencer_io_initDone                                   ), //i
    .io_currentTiming_tCke                     (timing_regs_io_current_tCke[19:0]                            ), //i
    .io_currentTiming_tDpd                     (timing_regs_io_current_tDpd[19:0]                            ), //i
    .io_currentTiming_tRcd                     (timing_regs_io_current_tRcd[7:0]                             ), //i
    .io_currentTiming_tRp                      (timing_regs_io_current_tRp[7:0]                              ), //i
    .io_currentTiming_tWr                      (timing_regs_io_current_tWr[7:0]                              ), //i
    .io_currentTiming_tRas                     (timing_regs_io_current_tRas[7:0]                             ), //i
    .io_currentTiming_tRrd                     (timing_regs_io_current_tRrd[7:0]                             ), //i
    .io_currentTiming_tPpd                     (timing_regs_io_current_tPpd[7:0]                             ), //i
    .io_currentTiming_tZqInit                  (timing_regs_io_current_tZqInit[11:0]                         ), //i
    .io_currentTiming_tFaw                     (timing_regs_io_current_tFaw[7:0]                             ), //i
    .io_currentTiming_tRfc                     (timing_regs_io_current_tRfc[7:0]                             ), //i
    .io_currentTiming_tPhyWrLat                (timing_regs_io_current_tPhyWrLat[7:0]                        ), //i
    .io_currentTiming_tPhyRdLat                (timing_regs_io_current_tPhyRdLat[7:0]                        ), //i
    .io_currentTiming_tPhyWrData               (timing_regs_io_current_tPhyWrData[7:0]                       ), //i
    .io_currentTiming_tRddataEn                (timing_regs_io_current_tRddataEn[7:0]                        ), //i
    .io_debugInfo_currentState                 (cmd_scheduler_io_debugInfo_currentState[3:0]                 ), //o
    .io_debugInfo_timingViolation              (cmd_scheduler_io_debugInfo_timingViolation                   ), //o
    .io_debugInfo_illegalTransition            (cmd_scheduler_io_debugInfo_illegalTransition                 ), //o
    .io_debugInfo_burstCountExceeded           (cmd_scheduler_io_debugInfo_burstCountExceeded                ), //o
    .io_debugInfo_cmdSource                    (cmd_scheduler_io_debugInfo_cmdSource[2:0]                    ), //o
    .io_debugInfo_pendingOpcode                (cmd_scheduler_io_debugInfo_pendingOpcode[5:0]                ), //o
    .io_debugInfo_validationLegal              (cmd_scheduler_io_debugInfo_validationLegal                   ), //o
    .io_debugInfo_validationDone               (cmd_scheduler_io_debugInfo_validationDone                    ), //o
    .io_debugInfo_bubbleNopActive              (cmd_scheduler_io_debugInfo_bubbleNopActive                   ), //o
    .io_debugInfo_serialCmdLimitViolated       (cmd_scheduler_io_debugInfo_serialCmdLimitViolated            ), //o
    .io_debugInfo_totalCommands                (cmd_scheduler_io_debugInfo_totalCommands[31:0]               ), //o
    .io_debugInfo_timingViolations             (cmd_scheduler_io_debugInfo_timingViolations[15:0]            ), //o
    .io_debugInfo_illegalTransitions           (cmd_scheduler_io_debugInfo_illegalTransitions[15:0]          ), //o
    .io_debugInfo_burstLimitViolations         (cmd_scheduler_io_debugInfo_burstLimitViolations[15:0]        ), //o
    .clk                                       (clk                                                          ), //i
    .reset                                     (reset                                                        )  //i
  );
  RefreshManager refresh_manager (
    .io_timing_tCke                    (timing_regs_io_current_tCke[19:0]                      ), //i
    .io_timing_tDpd                    (timing_regs_io_current_tDpd[19:0]                      ), //i
    .io_timing_tRcd                    (timing_regs_io_current_tRcd[7:0]                       ), //i
    .io_timing_tRp                     (timing_regs_io_current_tRp[7:0]                        ), //i
    .io_timing_tWr                     (timing_regs_io_current_tWr[7:0]                        ), //i
    .io_timing_tRas                    (timing_regs_io_current_tRas[7:0]                       ), //i
    .io_timing_tRrd                    (timing_regs_io_current_tRrd[7:0]                       ), //i
    .io_timing_tPpd                    (timing_regs_io_current_tPpd[7:0]                       ), //i
    .io_timing_tZqInit                 (timing_regs_io_current_tZqInit[11:0]                   ), //i
    .io_timing_tFaw                    (timing_regs_io_current_tFaw[7:0]                       ), //i
    .io_timing_tRfc                    (timing_regs_io_current_tRfc[7:0]                       ), //i
    .io_timing_tPhyWrLat               (timing_regs_io_current_tPhyWrLat[7:0]                  ), //i
    .io_timing_tPhyRdLat               (timing_regs_io_current_tPhyRdLat[7:0]                  ), //i
    .io_timing_tPhyWrData              (timing_regs_io_current_tPhyWrData[7:0]                 ), //i
    .io_timing_tRddataEn               (timing_regs_io_current_tRddataEn[7:0]                  ), //i
    .io_toScheduler_valid              (refresh_manager_io_toScheduler_valid                   ), //o
    .io_toScheduler_ready              (cmd_scheduler_io_refreshCmd_ready                      ), //i
    .io_toScheduler_payload_isSerial   (refresh_manager_io_toScheduler_payload_isSerial        ), //o
    .io_toScheduler_payload_opcode     (refresh_manager_io_toScheduler_payload_opcode[5:0]     ), //o
    .io_toScheduler_payload_bank       (refresh_manager_io_toScheduler_payload_bank[1:0]       ), //o
    .io_toScheduler_payload_rowAddr    (refresh_manager_io_toScheduler_payload_rowAddr[11:0]   ), //o
    .io_toScheduler_payload_colAddr    (refresh_manager_io_toScheduler_payload_colAddr[9:0]    ), //o
    .io_toScheduler_payload_burstCount (refresh_manager_io_toScheduler_payload_burstCount[5:0] ), //o
    .io_toScheduler_payload_writeMask  (refresh_manager_io_toScheduler_payload_writeMask[255:0]), //o
    .io_toScheduler_payload_odt        (refresh_manager_io_toScheduler_payload_odt             ), //o
    .io_autoRefresh                    (1'b1                                                   ), //i
    .clk                               (clk                                                    ), //i
    .reset                             (reset                                                  )  //i
  );
  PowerManager power_manager (
    .io_ctrl_enterPd              (io_ctrlIO_powerCtrl_enterPd                     ), //i
    .io_ctrl_exitPd               (io_ctrlIO_powerCtrl_exitPd                      ), //i
    .io_ctrl_enterDpd             (io_ctrlIO_powerCtrl_enterDpd                    ), //i
    .io_ctrl_reInitRequired       (power_manager_io_ctrl_reInitRequired            ), //o
    .io_timing_tCke               (timing_regs_io_current_tCke[19:0]               ), //i
    .io_timing_tDpd               (timing_regs_io_current_tDpd[19:0]               ), //i
    .io_timing_tRcd               (timing_regs_io_current_tRcd[7:0]                ), //i
    .io_timing_tRp                (timing_regs_io_current_tRp[7:0]                 ), //i
    .io_timing_tWr                (timing_regs_io_current_tWr[7:0]                 ), //i
    .io_timing_tRas               (timing_regs_io_current_tRas[7:0]                ), //i
    .io_timing_tRrd               (timing_regs_io_current_tRrd[7:0]                ), //i
    .io_timing_tPpd               (timing_regs_io_current_tPpd[7:0]                ), //i
    .io_timing_tZqInit            (timing_regs_io_current_tZqInit[11:0]            ), //i
    .io_timing_tFaw               (timing_regs_io_current_tFaw[7:0]                ), //i
    .io_timing_tRfc               (timing_regs_io_current_tRfc[7:0]                ), //i
    .io_timing_tPhyWrLat          (timing_regs_io_current_tPhyWrLat[7:0]           ), //i
    .io_timing_tPhyRdLat          (timing_regs_io_current_tPhyRdLat[7:0]           ), //i
    .io_timing_tPhyWrData         (timing_regs_io_current_tPhyWrData[7:0]          ), //i
    .io_timing_tRddataEn          (timing_regs_io_current_tRddataEn[7:0]           ), //i
    .io_cmdOut_valid              (power_manager_io_cmdOut_valid                   ), //o
    .io_cmdOut_ready              (cmd_scheduler_io_powerCmd_ready                 ), //i
    .io_cmdOut_payload_isSerial   (power_manager_io_cmdOut_payload_isSerial        ), //o
    .io_cmdOut_payload_opcode     (power_manager_io_cmdOut_payload_opcode[5:0]     ), //o
    .io_cmdOut_payload_bank       (power_manager_io_cmdOut_payload_bank[1:0]       ), //o
    .io_cmdOut_payload_rowAddr    (power_manager_io_cmdOut_payload_rowAddr[11:0]   ), //o
    .io_cmdOut_payload_colAddr    (power_manager_io_cmdOut_payload_colAddr[9:0]    ), //o
    .io_cmdOut_payload_burstCount (power_manager_io_cmdOut_payload_burstCount[5:0] ), //o
    .io_cmdOut_payload_writeMask  (power_manager_io_cmdOut_payload_writeMask[255:0]), //o
    .io_cmdOut_payload_odt        (power_manager_io_cmdOut_payload_odt             ), //o
    .io_isIdle                    (power_manager_io_isIdle                         ), //i
    .io_inPowerDown               (power_manager_io_inPowerDown                    ), //o
    .io_reInitRequired            (power_manager_io_reInitRequired                 ), //o
    .clk                          (clk                                             ), //i
    .reset                        (reset                                           )  //i
  );
  RpcDramPhy phy_interface (
    .io_cmdIn_valid                  (cmd_scheduler_io_toPhy_valid                        ), //i
    .io_cmdIn_ready                  (phy_interface_io_cmdIn_ready                        ), //o
    .io_cmdIn_payload_isSerial       (cmd_scheduler_io_toPhy_payload_isSerial             ), //i
    .io_cmdIn_payload_opcode         (cmd_scheduler_io_toPhy_payload_opcode[5:0]          ), //i
    .io_cmdIn_payload_bank           (cmd_scheduler_io_toPhy_payload_bank[1:0]            ), //i
    .io_cmdIn_payload_rowAddr        (cmd_scheduler_io_toPhy_payload_rowAddr[11:0]        ), //i
    .io_cmdIn_payload_colAddr        (cmd_scheduler_io_toPhy_payload_colAddr[9:0]         ), //i
    .io_cmdIn_payload_burstCount     (cmd_scheduler_io_toPhy_payload_burstCount[5:0]      ), //i
    .io_cmdIn_payload_writeMask      (cmd_scheduler_io_toPhy_payload_writeMask[255:0]     ), //i
    .io_cmdIn_payload_odt            (cmd_scheduler_io_toPhy_payload_odt                  ), //i
    .io_writeDataIn_valid            (io_ctrlIO_user_writeData_valid                      ), //i
    .io_writeDataIn_ready            (phy_interface_io_writeDataIn_ready                  ), //o
    .io_writeDataIn_payload_last     (io_ctrlIO_user_writeData_payload_last               ), //i
    .io_writeDataIn_payload_fragment (io_ctrlIO_user_writeData_payload_fragment[255:0]    ), //i
    .io_readDataOut_valid            (phy_interface_io_readDataOut_valid                  ), //o
    .io_readDataOut_ready            (io_ctrlIO_user_readData_ready                       ), //i
    .io_readDataOut_payload_last     (phy_interface_io_readDataOut_payload_last           ), //o
    .io_readDataOut_payload_fragment (phy_interface_io_readDataOut_payload_fragment[255:0]), //o
    .io_dram_clkP                    (phy_interface_io_dram_clkP                          ), //o
    .io_dram_clkN                    (phy_interface_io_dram_clkN                          ), //o
    .io_dram_csN_0                   (phy_interface_io_dram_csN_0                         ), //o
    .io_dram_stb                     (phy_interface_io_dram_stb                           ), //o
    .io_dram_resetN                  (phy_interface_io_dram_resetN                        ), //o
    .io_dram_odt                     (phy_interface_io_dram_odt                           ), //o
    .io_db                           (io_dramDb                                           ), //~
    .io_dqs                          (io_dramDqs                                          ), //~
    .io_dqs1                         (io_dramDqs1                                         ), //~
    .io_calibDone                    (phy_interface_io_calibDone                          ), //o
    .io_calibDelay                   (phy_interface_io_calibDelay[7:0]                    ), //o
    .io_phaseStatus                  (phy_interface_io_phaseStatus[3:0]                   ), //o
    .reset                           (reset                                               ), //i
    .clk                             (clk                                                 )  //i
  );
  assign init_sequencer_io_start = (! reset);
  assign io_ctrlIO_powerCtrl_reInitRequired = power_manager_io_ctrl_reInitRequired;
  assign power_manager_io_isIdle = (init_sequencer_io_initDone && (! io_ctrlIO_user_cmd_valid));
  assign phy_responseStream_valid = (phy_interface_io_readDataOut_valid && phy_interface_io_readDataOut_payload_last);
  assign phy_responseStream_payload = 1'b1;
  assign phy_responseStream_ready = cmd_scheduler_io_fromPhy_ready;
  assign io_ctrlIO_dram_clkP = phy_interface_io_dram_clkP;
  assign io_ctrlIO_dram_clkN = phy_interface_io_dram_clkN;
  assign io_ctrlIO_dram_csN_0 = phy_interface_io_dram_csN_0;
  assign io_ctrlIO_dram_stb = phy_interface_io_dram_stb;
  assign io_ctrlIO_dram_resetN = phy_interface_io_dram_resetN;
  assign io_ctrlIO_dram_odt = phy_interface_io_dram_odt;
  assign io_ctrlIO_user_cmd_ready = cmd_scheduler_io_user_cmd_ready;
  assign io_ctrlIO_user_writeData_ready = phy_interface_io_writeDataIn_ready;
  assign io_ctrlIO_user_readData_valid = phy_interface_io_readDataOut_valid;
  assign io_ctrlIO_user_readData_payload_last = phy_interface_io_readDataOut_payload_last;
  assign io_ctrlIO_user_readData_payload_fragment = phy_interface_io_readDataOut_payload_fragment;

endmodule

module RpcDramPhy (
  input  wire          io_cmdIn_valid,
  output wire          io_cmdIn_ready,
  input  wire          io_cmdIn_payload_isSerial,
  input  wire [5:0]    io_cmdIn_payload_opcode,
  input  wire [1:0]    io_cmdIn_payload_bank,
  input  wire [11:0]   io_cmdIn_payload_rowAddr,
  input  wire [9:0]    io_cmdIn_payload_colAddr,
  input  wire [5:0]    io_cmdIn_payload_burstCount,
  input  wire [255:0]  io_cmdIn_payload_writeMask,
  input  wire          io_cmdIn_payload_odt,
  input  wire          io_writeDataIn_valid,
  output wire          io_writeDataIn_ready,
  input  wire          io_writeDataIn_payload_last,
  input  wire [255:0]  io_writeDataIn_payload_fragment,
  output wire          io_readDataOut_valid,
  input  wire          io_readDataOut_ready,
  output wire          io_readDataOut_payload_last,
  output wire [255:0]  io_readDataOut_payload_fragment,
  output wire          io_dram_clkP,
  output wire          io_dram_clkN,
  output reg           io_dram_csN_0,
  output wire          io_dram_stb,
  output wire          io_dram_resetN,
  output reg           io_dram_odt,
  inout  wire [15:0]   io_db,
  inout  wire [1:0]    io_dqs,
  inout  wire [1:0]    io_dqs1,
  output wire          io_calibDone,
  output wire [7:0]    io_calibDelay,
  output wire [3:0]    io_phaseStatus,
  input  wire          reset,
  input  wire          clk
);
  localparam fsm_3_BOOT = 4'd0;
  localparam fsm_3_sIdle = 4'd1;
  localparam fsm_3_sStbPrep = 4'd2;
  localparam fsm_3_sDrivePacket = 4'd3;
  localparam fsm_3_sSerialPacket = 4'd4;
  localparam fsm_3_sSerialNop = 4'd5;
  localparam fsm_3_sBubbleNop = 4'd6;
  localparam fsm_3_sMaskTransfer = 4'd7;
  localparam fsm_3_sDataTransfer = 4'd8;

  wire                reset_asyncAssertSyncDeassert_buffercc_io_dataOut;
  wire                reset_asyncAssertSyncDeassert_buffercc_1_io_dataOut;
  wire       [7:0]    _zz_delayCalib_tapCounter_valueNext;
  wire       [0:0]    _zz_delayCalib_tapCounter_valueNext_1;
  wire       [3:0]    _zz_fsm_cycleCounter_valueNext;
  wire       [0:0]    _zz_fsm_cycleCounter_valueNext_1;
  wire       [1:0]    _zz_fsm_stbCounter_valueNext;
  wire       [0:0]    _zz_fsm_stbCounter_valueNext_1;
  wire       [2:0]    _zz_fsm_dataCounter_valueNext;
  wire       [0:0]    _zz_fsm_dataCounter_valueNext_1;
  wire       [5:0]    _zz_fsm_burstCounter_valueNext;
  wire       [0:0]    _zz_fsm_burstCounter_valueNext_1;
  wire       [2:0]    _zz_fsm_tPpdCounter_valueNext;
  wire       [0:0]    _zz_fsm_tPpdCounter_valueNext_1;
  wire       [0:0]    _zz__zz_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l462;
  wire       [4:0]    _zz_when_RpcDramPhy_l462_1;
  wire       [9:0]    _zz__zz_fsm_packetBuffer;
  wire       [1:0]    _zz__zz_fsm_packetBuffer_1;
  wire       [5:0]    _zz__zz_fsm_packetBuffer_1_1;
  reg        [15:0]   _zz__zz_dbWritePhases_0;
  wire       [0:0]    _zz__zz_dbWritePhases_0_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l536;
  wire       [4:0]    _zz_when_RpcDramPhy_l536_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l524;
  wire       [4:0]    _zz_when_RpcDramPhy_l524_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l600;
  wire       [4:0]    _zz_when_RpcDramPhy_l600_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l600_2;
  wire       [4:0]    _zz_when_RpcDramPhy_l600_3;
  wire       [5:0]    _zz_when_RpcDramPhy_l585;
  wire       [4:0]    _zz_when_RpcDramPhy_l585_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l585_2;
  wire       [4:0]    _zz_when_RpcDramPhy_l585_3;
  wire       [5:0]    _zz_when_RpcDramPhy_l612;
  wire       [4:0]    _zz_when_RpcDramPhy_l612_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l612_2;
  wire       [4:0]    _zz_when_RpcDramPhy_l612_3;
  wire       [5:0]    _zz_when_RpcDramPhy_l616;
  wire       [4:0]    _zz_when_RpcDramPhy_l616_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l703;
  wire       [4:0]    _zz_when_RpcDramPhy_l703_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l703_2;
  wire       [4:0]    _zz_when_RpcDramPhy_l703_3;
  wire       [5:0]    _zz__zz_dbWritePhases_0_1_1;
  reg        [1:0]    _zz__zz_dbWritePhases_0_2;
  wire       [3:0]    _zz__zz_dbWritePhases_0_2_1;
  reg        [15:0]   _zz__zz_dbWritePhases_0_3;
  wire       [3:0]    _zz__zz_dbWritePhases_0_3_1;
  wire       [9:0]    _zz_fsm_currentColAddr;
  wire       [5:0]    _zz_when_RpcDramPhy_l754;
  wire       [31:0]   _zz_readDataOutBuffer_payload_fragment;
  wire       [9:0]    _zz_fsm_currentColAddr_1;
  wire       [5:0]    _zz_when_RpcDramPhy_l787;
  wire       [15:0]   _zz_io_db_1;
  wire       [1:0]    _zz_io_dqs_1;
  wire       [1:0]    _zz_io_dqs1_1;
  wire                cmdBuffer_valid;
  reg                 cmdBuffer_ready;
  wire                cmdBuffer_payload_isSerial;
  wire       [5:0]    cmdBuffer_payload_opcode;
  wire       [1:0]    cmdBuffer_payload_bank;
  wire       [11:0]   cmdBuffer_payload_rowAddr;
  wire       [9:0]    cmdBuffer_payload_colAddr;
  wire       [5:0]    cmdBuffer_payload_burstCount;
  wire       [255:0]  cmdBuffer_payload_writeMask;
  wire                cmdBuffer_payload_odt;
  reg                 io_cmdIn_rValidN;
  reg                 io_cmdIn_rData_isSerial;
  reg        [5:0]    io_cmdIn_rData_opcode;
  reg        [1:0]    io_cmdIn_rData_bank;
  reg        [11:0]   io_cmdIn_rData_rowAddr;
  reg        [9:0]    io_cmdIn_rData_colAddr;
  reg        [5:0]    io_cmdIn_rData_burstCount;
  reg        [255:0]  io_cmdIn_rData_writeMask;
  reg                 io_cmdIn_rData_odt;
  wire                writeDataBuffer_valid;
  reg                 writeDataBuffer_ready;
  wire                writeDataBuffer_payload_last;
  wire       [255:0]  writeDataBuffer_payload_fragment;
  reg                 io_writeDataIn_rValidN;
  reg                 io_writeDataIn_rData_last;
  reg        [255:0]  io_writeDataIn_rData_fragment;
  reg                 readDataOutBuffer_valid;
  reg                 readDataOutBuffer_ready;
  reg                 readDataOutBuffer_payload_last;
  reg        [255:0]  readDataOutBuffer_payload_fragment;
  wire                readDataOutBuffer_m2sPipe_valid;
  wire                readDataOutBuffer_m2sPipe_ready;
  wire                readDataOutBuffer_m2sPipe_payload_last;
  wire       [255:0]  readDataOutBuffer_m2sPipe_payload_fragment;
  reg                 readDataOutBuffer_rValid;
  reg                 readDataOutBuffer_rData_last;
  reg        [255:0]  readDataOutBuffer_rData_fragment;
  wire                when_Stream_l399;
  wire                reset_asyncAssertSyncDeassert;
  wire                clkGen_clk270Rst;
  wire                reset_asyncAssertSyncDeassert_1;
  wire                clkGen_clk90Rst;
  reg                 delayCalib_tapCounter_willIncrement;
  reg                 delayCalib_tapCounter_willClear;
  reg        [7:0]    delayCalib_tapCounter_valueNext;
  reg        [7:0]    delayCalib_tapCounter_value;
  wire                delayCalib_tapCounter_willOverflowIfInc;
  wire                delayCalib_tapCounter_willOverflow;
  reg        [7:0]    delayCalib_bestDelay;
  wire                delayCalib_sampleValid;
  reg        [7:0]    delayCalib_sampleHistory;
  reg                 delayCalib_done;
  reg        [2:0]    delayCalib_state;
  wire       [2:0]    delayCalib_sIdle;
  wire       [2:0]    delayCalib_sPrep;
  wire       [2:0]    delayCalib_sSweep;
  wire       [2:0]    delayCalib_sAnalyze;
  wire       [2:0]    delayCalib_sComplete;
  wire                when_RpcDramPhy_l289;
  wire                when_RpcDramPhy_l317;
  wire                when_RpcDramPhy_l328;
  reg        [15:0]   dbWritePhases_0;
  reg        [15:0]   dbWritePhases_1;
  reg        [15:0]   dbReadPhases_0;
  reg        [15:0]   dbReadPhases_1;
  reg        [1:0]    dqsWritePhases_0;
  reg        [1:0]    dqsWritePhases_1;
  reg        [1:0]    dqsReadPhases_0;
  reg        [1:0]    dqsReadPhases_1;
  reg        [1:0]    dqs1WritePhases_0;
  reg        [1:0]    dqs1WritePhases_1;
  reg        [1:0]    dqs1ReadPhases_0;
  reg        [1:0]    dqs1ReadPhases_1;
  reg                 when_RpcDramPhy_l171;
  reg        [15:0]   io_db_regNext;
  reg        [15:0]   io_db_regNext_1;
  reg                 _zz_io_db;
  reg                 when_RpcDramPhy_l171_1;
  reg        [1:0]    io_dqs_regNext;
  reg        [1:0]    io_dqs_regNext_1;
  reg                 _zz_io_dqs;
  reg                 when_RpcDramPhy_l171_2;
  reg        [1:0]    io_dqs1_regNext;
  reg        [1:0]    io_dqs1_regNext_1;
  reg                 _zz_io_dqs1;
  reg                 stbArea_stbSignal;
  reg                 stbArea_stbControl;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg                 fsm_cycleCounter_willIncrement;
  reg                 fsm_cycleCounter_willClear;
  reg        [3:0]    fsm_cycleCounter_valueNext;
  reg        [3:0]    fsm_cycleCounter_value;
  wire                fsm_cycleCounter_willOverflowIfInc;
  wire                fsm_cycleCounter_willOverflow;
  reg                 fsm_stbCounter_willIncrement;
  reg                 fsm_stbCounter_willClear;
  reg        [1:0]    fsm_stbCounter_valueNext;
  reg        [1:0]    fsm_stbCounter_value;
  wire                fsm_stbCounter_willOverflowIfInc;
  wire                fsm_stbCounter_willOverflow;
  reg                 fsm_maskCounter_willIncrement;
  reg                 fsm_maskCounter_willClear;
  reg        [0:0]    fsm_maskCounter_valueNext;
  reg        [0:0]    fsm_maskCounter_value;
  wire                fsm_maskCounter_willOverflowIfInc;
  wire                fsm_maskCounter_willOverflow;
  reg                 fsm_dataCounter_willIncrement;
  reg                 fsm_dataCounter_willClear;
  reg        [2:0]    fsm_dataCounter_valueNext;
  reg        [2:0]    fsm_dataCounter_value;
  wire                fsm_dataCounter_willOverflowIfInc;
  wire                fsm_dataCounter_willOverflow;
  reg                 fsm_burstCounter_willIncrement;
  reg                 fsm_burstCounter_willClear;
  reg        [5:0]    fsm_burstCounter_valueNext;
  reg        [5:0]    fsm_burstCounter_value;
  wire                fsm_burstCounter_willOverflowIfInc;
  wire                fsm_burstCounter_willOverflow;
  reg        [31:0]   fsm_packetBuffer;
  reg        [255:0]  fsm_wordBuffer;
  reg        [31:0]   fsm_firstMask;
  reg        [31:0]   fsm_lastMask;
  reg                 fsm_isInActivateState;
  reg        [9:0]    fsm_currentColAddr;
  reg        [4:0]    fsm_basePage;
  reg        [5:0]    fsm_serialCmdCount;
  reg        [5:0]    fsm_burstCountLimit;
  reg        [6:0]    fsm_bubbleNopCounter;
  reg                 fsm_afterBurstStop;
  reg                 fsm_tPpdCounter_willIncrement;
  reg                 fsm_tPpdCounter_willClear;
  reg        [2:0]    fsm_tPpdCounter_valueNext;
  reg        [2:0]    fsm_tPpdCounter_value;
  wire                fsm_tPpdCounter_willOverflowIfInc;
  wire                fsm_tPpdCounter_willOverflow;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                when_RpcDramPhy_l440;
  wire                when_RpcDramPhy_l451;
  wire                when_RpcDramPhy_l455;
  wire                _zz_1;
  wire                when_RpcDramPhy_l462;
  reg        [15:0]   _zz_fsm_packetBuffer;
  reg        [31:0]   _zz_fsm_packetBuffer_1;
  wire       [15:0]   _zz_dbWritePhases_0;
  wire                when_RpcDramPhy_l508;
  wire                when_RpcDramPhy_l536;
  wire                when_RpcDramPhy_l524;
  wire                when_RpcDramPhy_l520;
  wire                when_RpcDramPhy_l550;
  wire                when_RpcDramPhy_l574;
  wire                when_RpcDramPhy_l600;
  wire                when_RpcDramPhy_l585;
  wire                when_RpcDramPhy_l612;
  wire                when_RpcDramPhy_l616;
  wire                when_RpcDramPhy_l635;
  wire                when_RpcDramPhy_l657;
  wire                when_RpcDramPhy_l669;
  wire                when_RpcDramPhy_l703;
  wire                when_RpcDramPhy_l708;
  wire       [31:0]   _zz_dbWritePhases_0_1;
  wire       [1:0]    _zz_dbWritePhases_0_2;
  wire       [15:0]   _zz_dbWritePhases_0_3;
  wire                when_RpcDramPhy_l754;
  wire                when_RpcDramPhy_l787;
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_sIdle;
  wire                fsm_onExit_sStbPrep;
  wire                fsm_onExit_sDrivePacket;
  wire                fsm_onExit_sSerialPacket;
  wire                fsm_onExit_sSerialNop;
  wire                fsm_onExit_sBubbleNop;
  wire                fsm_onExit_sMaskTransfer;
  wire                fsm_onExit_sDataTransfer;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_sIdle;
  wire                fsm_onEntry_sStbPrep;
  wire                fsm_onEntry_sDrivePacket;
  wire                fsm_onEntry_sSerialPacket;
  wire                fsm_onEntry_sSerialNop;
  wire                fsm_onEntry_sBubbleNop;
  wire                fsm_onEntry_sMaskTransfer;
  wire                fsm_onEntry_sDataTransfer;
  `ifndef SYNTHESIS
  reg [103:0] fsm_stateReg_string;
  reg [103:0] fsm_stateNext_string;
  `endif


  assign _zz_delayCalib_tapCounter_valueNext_1 = delayCalib_tapCounter_willIncrement;
  assign _zz_delayCalib_tapCounter_valueNext = {7'd0, _zz_delayCalib_tapCounter_valueNext_1};
  assign _zz_fsm_cycleCounter_valueNext_1 = fsm_cycleCounter_willIncrement;
  assign _zz_fsm_cycleCounter_valueNext = {3'd0, _zz_fsm_cycleCounter_valueNext_1};
  assign _zz_fsm_stbCounter_valueNext_1 = fsm_stbCounter_willIncrement;
  assign _zz_fsm_stbCounter_valueNext = {1'd0, _zz_fsm_stbCounter_valueNext_1};
  assign _zz_fsm_dataCounter_valueNext_1 = fsm_dataCounter_willIncrement;
  assign _zz_fsm_dataCounter_valueNext = {2'd0, _zz_fsm_dataCounter_valueNext_1};
  assign _zz_fsm_burstCounter_valueNext_1 = fsm_burstCounter_willIncrement;
  assign _zz_fsm_burstCounter_valueNext = {5'd0, _zz_fsm_burstCounter_valueNext_1};
  assign _zz_fsm_tPpdCounter_valueNext_1 = fsm_tPpdCounter_willIncrement;
  assign _zz_fsm_tPpdCounter_valueNext = {2'd0, _zz_fsm_tPpdCounter_valueNext_1};
  assign _zz__zz_1 = 1'b1;
  assign _zz_when_RpcDramPhy_l462_1 = 5'h0;
  assign _zz_when_RpcDramPhy_l462 = {1'd0, _zz_when_RpcDramPhy_l462_1};
  assign _zz__zz_fsm_packetBuffer = cmdBuffer_payload_colAddr;
  assign _zz__zz_fsm_packetBuffer_1_1 = cmdBuffer_payload_burstCount;
  assign _zz__zz_fsm_packetBuffer_1 = _zz__zz_fsm_packetBuffer_1_1[1:0];
  assign _zz__zz_dbWritePhases_0_1 = fsm_cycleCounter_value[0:0];
  assign _zz_when_RpcDramPhy_l536_1 = 5'h03;
  assign _zz_when_RpcDramPhy_l536 = {1'd0, _zz_when_RpcDramPhy_l536_1};
  assign _zz_when_RpcDramPhy_l524_1 = 5'h02;
  assign _zz_when_RpcDramPhy_l524 = {1'd0, _zz_when_RpcDramPhy_l524_1};
  assign _zz_when_RpcDramPhy_l600_1 = 5'h03;
  assign _zz_when_RpcDramPhy_l600 = {1'd0, _zz_when_RpcDramPhy_l600_1};
  assign _zz_when_RpcDramPhy_l600_3 = 5'h07;
  assign _zz_when_RpcDramPhy_l600_2 = {1'd0, _zz_when_RpcDramPhy_l600_3};
  assign _zz_when_RpcDramPhy_l585_1 = 5'h02;
  assign _zz_when_RpcDramPhy_l585 = {1'd0, _zz_when_RpcDramPhy_l585_1};
  assign _zz_when_RpcDramPhy_l585_3 = 5'h06;
  assign _zz_when_RpcDramPhy_l585_2 = {1'd0, _zz_when_RpcDramPhy_l585_3};
  assign _zz_when_RpcDramPhy_l612_1 = 5'h06;
  assign _zz_when_RpcDramPhy_l612 = {1'd0, _zz_when_RpcDramPhy_l612_1};
  assign _zz_when_RpcDramPhy_l612_3 = 5'h07;
  assign _zz_when_RpcDramPhy_l612_2 = {1'd0, _zz_when_RpcDramPhy_l612_3};
  assign _zz_when_RpcDramPhy_l616_1 = 5'h08;
  assign _zz_when_RpcDramPhy_l616 = {1'd0, _zz_when_RpcDramPhy_l616_1};
  assign _zz_when_RpcDramPhy_l703_1 = 5'h03;
  assign _zz_when_RpcDramPhy_l703 = {1'd0, _zz_when_RpcDramPhy_l703_1};
  assign _zz_when_RpcDramPhy_l703_3 = 5'h07;
  assign _zz_when_RpcDramPhy_l703_2 = {1'd0, _zz_when_RpcDramPhy_l703_3};
  assign _zz__zz_dbWritePhases_0_1_1 = (cmdBuffer_payload_burstCount - 6'h01);
  assign _zz__zz_dbWritePhases_0_2_1 = {1'd0, fsm_dataCounter_value};
  assign _zz__zz_dbWritePhases_0_3_1 = {1'd0, fsm_dataCounter_value};
  assign _zz_fsm_currentColAddr = (fsm_currentColAddr + 10'h020);
  assign _zz_when_RpcDramPhy_l754 = (cmdBuffer_payload_burstCount - 6'h01);
  assign _zz_readDataOutBuffer_payload_fragment = {dbReadPhases_0,dbReadPhases_1};
  assign _zz_fsm_currentColAddr_1 = (fsm_currentColAddr + 10'h020);
  assign _zz_when_RpcDramPhy_l787 = (cmdBuffer_payload_burstCount - 6'h01);
  assign _zz_io_db_1 = (_zz_io_db ? dbWritePhases_1 : dbWritePhases_0);
  assign _zz_io_dqs_1 = (_zz_io_dqs ? dqsWritePhases_1 : dqsWritePhases_0);
  assign _zz_io_dqs1_1 = (_zz_io_dqs1 ? dqs1WritePhases_1 : dqs1WritePhases_0);
  (* keep_hierarchy = "TRUE" *) BufferCC reset_asyncAssertSyncDeassert_buffercc (
    .io_dataIn  (reset_asyncAssertSyncDeassert                    ), //i
    .io_dataOut (reset_asyncAssertSyncDeassert_buffercc_io_dataOut), //o
    .clk        (clk                                              ), //i
    .reset      (reset                                            )  //i
  );
  (* keep_hierarchy = "TRUE" *) BufferCC_1 reset_asyncAssertSyncDeassert_buffercc_1 (
    .io_dataIn  (reset_asyncAssertSyncDeassert_1                    ), //i
    .io_dataOut (reset_asyncAssertSyncDeassert_buffercc_1_io_dataOut), //o
    .clk        (clk                                                ), //i
    .reset      (reset                                              )  //i
  );
  assign io_db = 1'b1 ? _zz_io_db_1[15 : 0] : 16'bzzzzzzzzzzzzzzzz;
  assign io_dqs = 1'b1 ? _zz_io_dqs_1[1 : 0] : 2'bzz;
  assign io_dqs1 = 1'b1 ? _zz_io_dqs1_1[1 : 0] : 2'bzz;
  always @(*) begin
    case(_zz__zz_dbWritePhases_0_1)
      1'b0 : _zz__zz_dbWritePhases_0 = fsm_packetBuffer[15 : 0];
      default : _zz__zz_dbWritePhases_0 = fsm_packetBuffer[31 : 16];
    endcase
  end

  always @(*) begin
    case(_zz__zz_dbWritePhases_0_2_1)
      4'b0000 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[1 : 0];
      4'b0001 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[3 : 2];
      4'b0010 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[5 : 4];
      4'b0011 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[7 : 6];
      4'b0100 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[9 : 8];
      4'b0101 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[11 : 10];
      4'b0110 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[13 : 12];
      4'b0111 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[15 : 14];
      4'b1000 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[17 : 16];
      4'b1001 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[19 : 18];
      4'b1010 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[21 : 20];
      4'b1011 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[23 : 22];
      4'b1100 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[25 : 24];
      4'b1101 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[27 : 26];
      4'b1110 : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[29 : 28];
      default : _zz__zz_dbWritePhases_0_2 = _zz_dbWritePhases_0_1[31 : 30];
    endcase
  end

  always @(*) begin
    case(_zz__zz_dbWritePhases_0_3_1)
      4'b0000 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[15 : 0];
      4'b0001 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[31 : 16];
      4'b0010 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[47 : 32];
      4'b0011 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[63 : 48];
      4'b0100 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[79 : 64];
      4'b0101 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[95 : 80];
      4'b0110 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[111 : 96];
      4'b0111 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[127 : 112];
      4'b1000 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[143 : 128];
      4'b1001 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[159 : 144];
      4'b1010 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[175 : 160];
      4'b1011 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[191 : 176];
      4'b1100 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[207 : 192];
      4'b1101 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[223 : 208];
      4'b1110 : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[239 : 224];
      default : _zz__zz_dbWritePhases_0_3 = fsm_wordBuffer[255 : 240];
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_3_BOOT : fsm_stateReg_string = "BOOT         ";
      fsm_3_sIdle : fsm_stateReg_string = "sIdle        ";
      fsm_3_sStbPrep : fsm_stateReg_string = "sStbPrep     ";
      fsm_3_sDrivePacket : fsm_stateReg_string = "sDrivePacket ";
      fsm_3_sSerialPacket : fsm_stateReg_string = "sSerialPacket";
      fsm_3_sSerialNop : fsm_stateReg_string = "sSerialNop   ";
      fsm_3_sBubbleNop : fsm_stateReg_string = "sBubbleNop   ";
      fsm_3_sMaskTransfer : fsm_stateReg_string = "sMaskTransfer";
      fsm_3_sDataTransfer : fsm_stateReg_string = "sDataTransfer";
      default : fsm_stateReg_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_3_BOOT : fsm_stateNext_string = "BOOT         ";
      fsm_3_sIdle : fsm_stateNext_string = "sIdle        ";
      fsm_3_sStbPrep : fsm_stateNext_string = "sStbPrep     ";
      fsm_3_sDrivePacket : fsm_stateNext_string = "sDrivePacket ";
      fsm_3_sSerialPacket : fsm_stateNext_string = "sSerialPacket";
      fsm_3_sSerialNop : fsm_stateNext_string = "sSerialNop   ";
      fsm_3_sBubbleNop : fsm_stateNext_string = "sBubbleNop   ";
      fsm_3_sMaskTransfer : fsm_stateNext_string = "sMaskTransfer";
      fsm_3_sDataTransfer : fsm_stateNext_string = "sDataTransfer";
      default : fsm_stateNext_string = "?????????????";
    endcase
  end
  `endif

  assign io_cmdIn_ready = io_cmdIn_rValidN;
  assign cmdBuffer_valid = (io_cmdIn_valid || (! io_cmdIn_rValidN));
  assign cmdBuffer_payload_isSerial = (io_cmdIn_rValidN ? io_cmdIn_payload_isSerial : io_cmdIn_rData_isSerial);
  assign cmdBuffer_payload_opcode = (io_cmdIn_rValidN ? io_cmdIn_payload_opcode : io_cmdIn_rData_opcode);
  assign cmdBuffer_payload_bank = (io_cmdIn_rValidN ? io_cmdIn_payload_bank : io_cmdIn_rData_bank);
  assign cmdBuffer_payload_rowAddr = (io_cmdIn_rValidN ? io_cmdIn_payload_rowAddr : io_cmdIn_rData_rowAddr);
  assign cmdBuffer_payload_colAddr = (io_cmdIn_rValidN ? io_cmdIn_payload_colAddr : io_cmdIn_rData_colAddr);
  assign cmdBuffer_payload_burstCount = (io_cmdIn_rValidN ? io_cmdIn_payload_burstCount : io_cmdIn_rData_burstCount);
  assign cmdBuffer_payload_writeMask = (io_cmdIn_rValidN ? io_cmdIn_payload_writeMask : io_cmdIn_rData_writeMask);
  assign cmdBuffer_payload_odt = (io_cmdIn_rValidN ? io_cmdIn_payload_odt : io_cmdIn_rData_odt);
  assign io_writeDataIn_ready = io_writeDataIn_rValidN;
  assign writeDataBuffer_valid = (io_writeDataIn_valid || (! io_writeDataIn_rValidN));
  assign writeDataBuffer_payload_last = (io_writeDataIn_rValidN ? io_writeDataIn_payload_last : io_writeDataIn_rData_last);
  assign writeDataBuffer_payload_fragment = (io_writeDataIn_rValidN ? io_writeDataIn_payload_fragment : io_writeDataIn_rData_fragment);
  always @(*) begin
    readDataOutBuffer_ready = readDataOutBuffer_m2sPipe_ready;
    if(when_Stream_l399) begin
      readDataOutBuffer_ready = 1'b1;
    end
  end

  assign when_Stream_l399 = (! readDataOutBuffer_m2sPipe_valid);
  assign readDataOutBuffer_m2sPipe_valid = readDataOutBuffer_rValid;
  assign readDataOutBuffer_m2sPipe_payload_last = readDataOutBuffer_rData_last;
  assign readDataOutBuffer_m2sPipe_payload_fragment = readDataOutBuffer_rData_fragment;
  assign io_readDataOut_valid = readDataOutBuffer_m2sPipe_valid;
  assign readDataOutBuffer_m2sPipe_ready = io_readDataOut_ready;
  assign io_readDataOut_payload_last = readDataOutBuffer_m2sPipe_payload_last;
  assign io_readDataOut_payload_fragment = readDataOutBuffer_m2sPipe_payload_fragment;
  assign reset_asyncAssertSyncDeassert = (1'b0 ^ 1'b0);
  assign clkGen_clk270Rst = reset_asyncAssertSyncDeassert_buffercc_io_dataOut;
  assign reset_asyncAssertSyncDeassert_1 = (1'b0 ^ 1'b0);
  assign clkGen_clk90Rst = reset_asyncAssertSyncDeassert_buffercc_1_io_dataOut;
  assign io_dram_clkP = clk;
  assign io_dram_clkN = (! clk);
  assign io_phaseStatus = {{{clk,clk},clk},(! clk)};
  always @(*) begin
    delayCalib_tapCounter_willIncrement = 1'b0;
    if((delayCalib_state == delayCalib_sIdle)) begin
    end else if((delayCalib_state == delayCalib_sPrep)) begin
    end else if((delayCalib_state == delayCalib_sSweep)) begin
        delayCalib_tapCounter_willIncrement = 1'b1;
    end else if((delayCalib_state == delayCalib_sAnalyze)) begin
    end else if((delayCalib_state == delayCalib_sComplete)) begin
    end
  end

  always @(*) begin
    delayCalib_tapCounter_willClear = 1'b0;
    if((delayCalib_state == delayCalib_sIdle)) begin
        if(when_RpcDramPhy_l289) begin
          delayCalib_tapCounter_willClear = 1'b1;
        end
    end else if((delayCalib_state == delayCalib_sPrep)) begin
    end else if((delayCalib_state == delayCalib_sSweep)) begin
    end else if((delayCalib_state == delayCalib_sAnalyze)) begin
    end else if((delayCalib_state == delayCalib_sComplete)) begin
    end
  end

  assign delayCalib_tapCounter_willOverflowIfInc = (delayCalib_tapCounter_value == 8'hff);
  assign delayCalib_tapCounter_willOverflow = (delayCalib_tapCounter_willOverflowIfInc && delayCalib_tapCounter_willIncrement);
  always @(*) begin
    delayCalib_tapCounter_valueNext = (delayCalib_tapCounter_value + _zz_delayCalib_tapCounter_valueNext);
    if(delayCalib_tapCounter_willClear) begin
      delayCalib_tapCounter_valueNext = 8'h0;
    end
  end

  assign delayCalib_sampleValid = 1'b0;
  assign delayCalib_sIdle = 3'b000;
  assign delayCalib_sPrep = 3'b001;
  assign delayCalib_sSweep = 3'b010;
  assign delayCalib_sAnalyze = 3'b011;
  assign delayCalib_sComplete = 3'b100;
  assign when_RpcDramPhy_l289 = (! 1'b0);
  assign when_RpcDramPhy_l317 = ((delayCalib_sampleHistory == 8'hff) && ((8'h64 <= delayCalib_tapCounter_value) && (delayCalib_tapCounter_value <= 8'hc8)));
  assign when_RpcDramPhy_l328 = ((8'h64 <= delayCalib_bestDelay) && (delayCalib_bestDelay <= 8'hc8));
  assign io_calibDone = delayCalib_done;
  assign io_calibDelay = delayCalib_bestDelay;
  always @(*) begin
    io_dram_csN_0 = 1'b1;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l455) begin
          io_dram_csN_0 = 1'b1;
          if(_zz_1) begin
            io_dram_csN_0 = 1'b0;
          end
        end
      end
      fsm_3_sStbPrep : begin
        io_dram_csN_0 = 1'b1;
        if(_zz_1) begin
          io_dram_csN_0 = 1'b0;
        end
      end
      fsm_3_sDrivePacket : begin
        io_dram_csN_0 = 1'b1;
        if(_zz_1) begin
          io_dram_csN_0 = 1'b0;
        end
      end
      fsm_3_sSerialPacket : begin
        io_dram_csN_0 = 1'b1;
        if(_zz_1) begin
          io_dram_csN_0 = 1'b0;
        end
      end
      fsm_3_sSerialNop : begin
        io_dram_csN_0 = 1'b1;
        if(_zz_1) begin
          io_dram_csN_0 = 1'b0;
        end
      end
      fsm_3_sBubbleNop : begin
        io_dram_csN_0 = 1'b1;
        if(_zz_1) begin
          io_dram_csN_0 = 1'b0;
        end
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign io_dram_resetN = 1'b1;
  always @(*) begin
    io_dram_odt = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        io_dram_odt = cmdBuffer_payload_odt;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        io_dram_odt = 1'b1;
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          io_dram_odt = cmdBuffer_payload_odt;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dbWritePhases_0 = 16'h0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dbWritePhases_0 = _zz_dbWritePhases_0;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        if(when_RpcDramPhy_l669) begin
          dbWritePhases_0 = cmdBuffer_payload_writeMask[15 : 0];
        end else begin
          dbWritePhases_0 = cmdBuffer_payload_writeMask[31 : 16];
        end
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dbWritePhases_0 = _zz_dbWritePhases_0_3;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dbWritePhases_1 = 16'h0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dbWritePhases_1 = _zz_dbWritePhases_0;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        if(when_RpcDramPhy_l669) begin
          dbWritePhases_1 = cmdBuffer_payload_writeMask[15 : 0];
        end else begin
          dbWritePhases_1 = cmdBuffer_payload_writeMask[31 : 16];
        end
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dbWritePhases_1 = _zz_dbWritePhases_0_3;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dqsWritePhases_0 = 2'b00;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dqsWritePhases_0 = 2'b01;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        dqsWritePhases_0 = 2'b01;
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dqsWritePhases_0 = 2'b01;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dqsWritePhases_1 = 2'b00;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dqsWritePhases_1 = 2'b10;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        dqsWritePhases_1 = 2'b10;
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dqsWritePhases_1 = 2'b10;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dqs1WritePhases_0 = 2'b00;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dqs1WritePhases_0 = 2'b01;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        dqs1WritePhases_0 = 2'b01;
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dqs1WritePhases_0 = 2'b01;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    dqs1WritePhases_1 = 2'b00;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        dqs1WritePhases_1 = 2'b10;
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        dqs1WritePhases_1 = 2'b10;
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          dqs1WritePhases_1 = 2'b10;
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    if(when_RpcDramPhy_l171) begin
      dbReadPhases_0 = io_db;
    end else begin
      dbReadPhases_0 = io_db_regNext_1;
    end
  end

  always @(*) begin
    if(when_RpcDramPhy_l171) begin
      dbReadPhases_1 = io_db_regNext;
    end else begin
      dbReadPhases_1 = io_db;
    end
  end

  always @(*) begin
    if(when_RpcDramPhy_l171_1) begin
      dqsReadPhases_0 = io_dqs;
    end else begin
      dqsReadPhases_0 = io_dqs_regNext_1;
    end
  end

  always @(*) begin
    if(when_RpcDramPhy_l171_1) begin
      dqsReadPhases_1 = io_dqs_regNext;
    end else begin
      dqsReadPhases_1 = io_dqs;
    end
  end

  always @(*) begin
    if(when_RpcDramPhy_l171_2) begin
      dqs1ReadPhases_0 = io_dqs1;
    end else begin
      dqs1ReadPhases_0 = io_dqs1_regNext_1;
    end
  end

  always @(*) begin
    if(when_RpcDramPhy_l171_2) begin
      dqs1ReadPhases_1 = io_dqs1_regNext;
    end else begin
      dqs1ReadPhases_1 = io_dqs1;
    end
  end

  assign io_dram_stb = stbArea_stbSignal;
  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  always @(*) begin
    fsm_cycleCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        fsm_cycleCounter_willIncrement = 1'b1;
      end
      fsm_3_sSerialPacket : begin
        fsm_cycleCounter_willIncrement = 1'b1;
      end
      fsm_3_sSerialNop : begin
        fsm_cycleCounter_willIncrement = 1'b1;
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_cycleCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l455) begin
          if(cmdBuffer_payload_isSerial) begin
            if(when_RpcDramPhy_l462) begin
              fsm_cycleCounter_willClear = 1'b1;
            end
          end
        end
      end
      fsm_3_sStbPrep : begin
        if(fsm_stbCounter_willOverflow) begin
          fsm_cycleCounter_willClear = 1'b1;
        end
      end
      fsm_3_sDrivePacket : begin
        if(when_RpcDramPhy_l508) begin
          fsm_cycleCounter_willClear = 1'b1;
        end
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          fsm_cycleCounter_willClear = 1'b1;
        end
      end
      fsm_3_sSerialNop : begin
        if(when_RpcDramPhy_l635) begin
          fsm_cycleCounter_willClear = 1'b1;
        end
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_cycleCounter_willOverflowIfInc = (fsm_cycleCounter_value == 4'b1111);
  assign fsm_cycleCounter_willOverflow = (fsm_cycleCounter_willOverflowIfInc && fsm_cycleCounter_willIncrement);
  always @(*) begin
    fsm_cycleCounter_valueNext = (fsm_cycleCounter_value + _zz_fsm_cycleCounter_valueNext);
    if(fsm_cycleCounter_willClear) begin
      fsm_cycleCounter_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    fsm_stbCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
        fsm_stbCounter_willIncrement = 1'b1;
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_stbCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l455) begin
          if(!cmdBuffer_payload_isSerial) begin
            fsm_stbCounter_willClear = 1'b1;
          end
        end
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_stbCounter_willOverflowIfInc = (fsm_stbCounter_value == 2'b10);
  assign fsm_stbCounter_willOverflow = (fsm_stbCounter_willOverflowIfInc && fsm_stbCounter_willIncrement);
  always @(*) begin
    if(fsm_stbCounter_willOverflow) begin
      fsm_stbCounter_valueNext = 2'b00;
    end else begin
      fsm_stbCounter_valueNext = (fsm_stbCounter_value + _zz_fsm_stbCounter_valueNext);
    end
    if(fsm_stbCounter_willClear) begin
      fsm_stbCounter_valueNext = 2'b00;
    end
  end

  always @(*) begin
    fsm_maskCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        fsm_maskCounter_willIncrement = 1'b1;
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_maskCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        if(when_RpcDramPhy_l508) begin
          if(when_RpcDramPhy_l524) begin
            if(when_RpcDramPhy_l536) begin
              fsm_maskCounter_willClear = 1'b1;
            end
          end
        end
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          if(when_RpcDramPhy_l585) begin
            if(when_RpcDramPhy_l600) begin
              fsm_maskCounter_willClear = 1'b1;
            end
          end
        end
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_maskCounter_willOverflowIfInc = (fsm_maskCounter_value == 1'b1);
  assign fsm_maskCounter_willOverflow = (fsm_maskCounter_willOverflowIfInc && fsm_maskCounter_willIncrement);
  always @(*) begin
    fsm_maskCounter_valueNext = (fsm_maskCounter_value + fsm_maskCounter_willIncrement);
    if(fsm_maskCounter_willClear) begin
      fsm_maskCounter_valueNext = 1'b0;
    end
  end

  always @(*) begin
    fsm_dataCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        fsm_dataCounter_willIncrement = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_dataCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        if(when_RpcDramPhy_l508) begin
          if(when_RpcDramPhy_l524) begin
            fsm_dataCounter_willClear = 1'b1;
          end
        end
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          if(when_RpcDramPhy_l585) begin
            fsm_dataCounter_willClear = 1'b1;
          end
        end
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        if(fsm_maskCounter_willOverflow) begin
          fsm_dataCounter_willClear = 1'b1;
        end
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            if(!when_RpcDramPhy_l754) begin
              fsm_dataCounter_willClear = 1'b1;
            end
          end
        end else begin
          if(fsm_dataCounter_willOverflow) begin
            if(!when_RpcDramPhy_l787) begin
              fsm_dataCounter_willClear = 1'b1;
            end
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign fsm_dataCounter_willOverflowIfInc = (fsm_dataCounter_value == 3'b111);
  assign fsm_dataCounter_willOverflow = (fsm_dataCounter_willOverflowIfInc && fsm_dataCounter_willIncrement);
  always @(*) begin
    fsm_dataCounter_valueNext = (fsm_dataCounter_value + _zz_fsm_dataCounter_valueNext);
    if(fsm_dataCounter_willClear) begin
      fsm_dataCounter_valueNext = 3'b000;
    end
  end

  always @(*) begin
    fsm_burstCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            fsm_burstCounter_willIncrement = 1'b1;
          end
        end else begin
          if(fsm_dataCounter_willOverflow) begin
            fsm_burstCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_burstCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
        if(when_RpcDramPhy_l508) begin
          if(when_RpcDramPhy_l524) begin
            fsm_burstCounter_willClear = 1'b1;
          end
        end
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          if(when_RpcDramPhy_l585) begin
            fsm_burstCounter_willClear = 1'b1;
          end
        end
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
        if(fsm_maskCounter_willOverflow) begin
          fsm_burstCounter_willClear = 1'b1;
        end
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_burstCounter_willOverflowIfInc = (fsm_burstCounter_value == 6'h3f);
  assign fsm_burstCounter_willOverflow = (fsm_burstCounter_willOverflowIfInc && fsm_burstCounter_willIncrement);
  always @(*) begin
    fsm_burstCounter_valueNext = (fsm_burstCounter_value + _zz_fsm_burstCounter_valueNext);
    if(fsm_burstCounter_willClear) begin
      fsm_burstCounter_valueNext = 6'h0;
    end
  end

  always @(*) begin
    fsm_tPpdCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l440) begin
          fsm_tPpdCounter_willIncrement = 1'b1;
        end
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_tPpdCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          if(!when_RpcDramPhy_l585) begin
            if(!when_RpcDramPhy_l612) begin
              if(when_RpcDramPhy_l616) begin
                fsm_tPpdCounter_willClear = 1'b1;
              end
            end
          end
        end
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_tPpdCounter_willOverflowIfInc = (fsm_tPpdCounter_value == 3'b111);
  assign fsm_tPpdCounter_willOverflow = (fsm_tPpdCounter_willOverflowIfInc && fsm_tPpdCounter_willIncrement);
  always @(*) begin
    fsm_tPpdCounter_valueNext = (fsm_tPpdCounter_value + _zz_fsm_tPpdCounter_valueNext);
    if(fsm_tPpdCounter_willClear) begin
      fsm_tPpdCounter_valueNext = 3'b000;
    end
  end

  always @(*) begin
    cmdBuffer_ready = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l451) begin
          cmdBuffer_ready = 1'b1;
        end
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    writeDataBuffer_ready = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          if(when_RpcDramPhy_l708) begin
            writeDataBuffer_ready = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    readDataOutBuffer_valid = 1'b0;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        if(!when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            readDataOutBuffer_valid = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    readDataOutBuffer_payload_last = 1'bx;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        if(!when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            readDataOutBuffer_payload_last = when_RpcDramPhy_l787;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    readDataOutBuffer_payload_fragment = 256'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
      end
      fsm_3_sStbPrep : begin
      end
      fsm_3_sDrivePacket : begin
      end
      fsm_3_sSerialPacket : begin
      end
      fsm_3_sSerialNop : begin
      end
      fsm_3_sBubbleNop : begin
      end
      fsm_3_sMaskTransfer : begin
      end
      fsm_3_sDataTransfer : begin
        if(!when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            readDataOutBuffer_payload_fragment = {224'd0, _zz_readDataOutBuffer_payload_fragment};
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_3_sIdle : begin
        if(when_RpcDramPhy_l455) begin
          if(cmdBuffer_payload_isSerial) begin
            if(when_RpcDramPhy_l462) begin
              fsm_stateNext = fsm_3_sSerialNop;
            end else begin
              fsm_stateNext = fsm_3_sSerialPacket;
            end
          end else begin
            fsm_stateNext = fsm_3_sStbPrep;
          end
        end
      end
      fsm_3_sStbPrep : begin
        if(fsm_stbCounter_willOverflow) begin
          fsm_stateNext = fsm_3_sDrivePacket;
        end
      end
      fsm_3_sDrivePacket : begin
        if(when_RpcDramPhy_l508) begin
          if(when_RpcDramPhy_l524) begin
            if(when_RpcDramPhy_l536) begin
              fsm_stateNext = fsm_3_sMaskTransfer;
            end else begin
              fsm_stateNext = fsm_3_sDataTransfer;
            end
          end else begin
            fsm_stateNext = fsm_3_sIdle;
          end
        end
      end
      fsm_3_sSerialPacket : begin
        if(when_RpcDramPhy_l574) begin
          if(when_RpcDramPhy_l585) begin
            if(when_RpcDramPhy_l600) begin
              fsm_stateNext = fsm_3_sMaskTransfer;
            end else begin
              fsm_stateNext = fsm_3_sDataTransfer;
            end
          end else begin
            if(when_RpcDramPhy_l612) begin
              fsm_stateNext = fsm_3_sBubbleNop;
            end else begin
              if(when_RpcDramPhy_l616) begin
                fsm_stateNext = fsm_3_sIdle;
              end else begin
                fsm_stateNext = fsm_3_sIdle;
              end
            end
          end
        end
      end
      fsm_3_sSerialNop : begin
        if(when_RpcDramPhy_l635) begin
          fsm_stateNext = fsm_3_sIdle;
        end
      end
      fsm_3_sBubbleNop : begin
        if(when_RpcDramPhy_l657) begin
          fsm_stateNext = fsm_3_sIdle;
        end
      end
      fsm_3_sMaskTransfer : begin
        if(fsm_maskCounter_willOverflow) begin
          fsm_stateNext = fsm_3_sDataTransfer;
        end
      end
      fsm_3_sDataTransfer : begin
        if(when_RpcDramPhy_l703) begin
          if(fsm_dataCounter_willOverflow) begin
            if(when_RpcDramPhy_l754) begin
              fsm_stateNext = fsm_3_sIdle;
            end
          end
        end else begin
          if(fsm_dataCounter_willOverflow) begin
            if(when_RpcDramPhy_l787) begin
              fsm_stateNext = fsm_3_sIdle;
            end
          end
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_3_sIdle;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_3_BOOT;
    end
  end

  assign when_RpcDramPhy_l440 = (fsm_afterBurstStop && fsm_isInActivateState);
  assign when_RpcDramPhy_l451 = (delayCalib_done && (((! fsm_afterBurstStop) || fsm_tPpdCounter_willOverflow) || (! fsm_isInActivateState)));
  assign when_RpcDramPhy_l455 = (cmdBuffer_valid && cmdBuffer_ready);
  assign _zz_1 = _zz__zz_1[0];
  assign when_RpcDramPhy_l462 = (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l462);
  always @(*) begin
    if(cmdBuffer_payload_isSerial) begin
      _zz_fsm_packetBuffer = {{cmdBuffer_payload_opcode[4 : 0],cmdBuffer_payload_bank},_zz__zz_fsm_packetBuffer[8 : 0]};
    end else begin
      _zz_fsm_packetBuffer = 16'h0;
    end
  end

  always @(*) begin
    if(cmdBuffer_payload_isSerial) begin
      _zz_fsm_packetBuffer_1 = 32'h0;
    end else begin
      _zz_fsm_packetBuffer_1 = {{{{_zz__zz_fsm_packetBuffer_1,cmdBuffer_payload_colAddr},cmdBuffer_payload_rowAddr},cmdBuffer_payload_bank},cmdBuffer_payload_opcode[5 : 0]};
    end
  end

  assign _zz_dbWritePhases_0 = _zz__zz_dbWritePhases_0;
  assign when_RpcDramPhy_l508 = (fsm_cycleCounter_value == 4'b0001);
  assign when_RpcDramPhy_l536 = ((cmdBuffer_payload_opcode == 6'h03) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l536));
  assign when_RpcDramPhy_l524 = (when_RpcDramPhy_l536 || ((cmdBuffer_payload_opcode == 6'h02) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l524)));
  assign when_RpcDramPhy_l520 = ((cmdBuffer_payload_opcode == 6'h01) || when_RpcDramPhy_l524);
  assign when_RpcDramPhy_l550 = (cmdBuffer_payload_opcode == 6'h05);
  assign when_RpcDramPhy_l574 = (fsm_cycleCounter_value == 4'b1111);
  assign when_RpcDramPhy_l600 = ((cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l600) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l600_2));
  assign when_RpcDramPhy_l585 = (when_RpcDramPhy_l600 || ((cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l585) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l585_2)));
  assign when_RpcDramPhy_l612 = ((cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l612) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l612_2));
  assign when_RpcDramPhy_l616 = (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l616);
  assign when_RpcDramPhy_l635 = (fsm_cycleCounter_value == 4'b0111);
  assign when_RpcDramPhy_l657 = (io_cmdIn_valid || (fsm_bubbleNopCounter == 7'h50));
  assign when_RpcDramPhy_l669 = (fsm_maskCounter_value == 1'b0);
  assign when_RpcDramPhy_l703 = (((cmdBuffer_payload_opcode == 6'h03) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l703)) || (cmdBuffer_payload_opcode == _zz_when_RpcDramPhy_l703_2));
  assign when_RpcDramPhy_l708 = (fsm_dataCounter_value == 3'b000);
  assign _zz_dbWritePhases_0_1 = ((fsm_burstCounter_value == 6'h0) ? fsm_firstMask : ((fsm_burstCounter_value == _zz__zz_dbWritePhases_0_1_1) ? fsm_lastMask : 32'h0));
  assign _zz_dbWritePhases_0_2 = _zz__zz_dbWritePhases_0_2;
  assign _zz_dbWritePhases_0_3 = (_zz__zz_dbWritePhases_0_3 & {(_zz_dbWritePhases_0_2[1] ? 8'hff : 8'h0),(_zz_dbWritePhases_0_2[0] ? 8'hff : 8'h0)});
  assign when_RpcDramPhy_l754 = ((fsm_burstCounter_value == _zz_when_RpcDramPhy_l754) && writeDataBuffer_payload_last);
  assign when_RpcDramPhy_l787 = (fsm_burstCounter_value == _zz_when_RpcDramPhy_l787);
  assign fsm_onExit_BOOT = ((fsm_stateNext != fsm_3_BOOT) && (fsm_stateReg == fsm_3_BOOT));
  assign fsm_onExit_sIdle = ((fsm_stateNext != fsm_3_sIdle) && (fsm_stateReg == fsm_3_sIdle));
  assign fsm_onExit_sStbPrep = ((fsm_stateNext != fsm_3_sStbPrep) && (fsm_stateReg == fsm_3_sStbPrep));
  assign fsm_onExit_sDrivePacket = ((fsm_stateNext != fsm_3_sDrivePacket) && (fsm_stateReg == fsm_3_sDrivePacket));
  assign fsm_onExit_sSerialPacket = ((fsm_stateNext != fsm_3_sSerialPacket) && (fsm_stateReg == fsm_3_sSerialPacket));
  assign fsm_onExit_sSerialNop = ((fsm_stateNext != fsm_3_sSerialNop) && (fsm_stateReg == fsm_3_sSerialNop));
  assign fsm_onExit_sBubbleNop = ((fsm_stateNext != fsm_3_sBubbleNop) && (fsm_stateReg == fsm_3_sBubbleNop));
  assign fsm_onExit_sMaskTransfer = ((fsm_stateNext != fsm_3_sMaskTransfer) && (fsm_stateReg == fsm_3_sMaskTransfer));
  assign fsm_onExit_sDataTransfer = ((fsm_stateNext != fsm_3_sDataTransfer) && (fsm_stateReg == fsm_3_sDataTransfer));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == fsm_3_BOOT) && (fsm_stateReg != fsm_3_BOOT));
  assign fsm_onEntry_sIdle = ((fsm_stateNext == fsm_3_sIdle) && (fsm_stateReg != fsm_3_sIdle));
  assign fsm_onEntry_sStbPrep = ((fsm_stateNext == fsm_3_sStbPrep) && (fsm_stateReg != fsm_3_sStbPrep));
  assign fsm_onEntry_sDrivePacket = ((fsm_stateNext == fsm_3_sDrivePacket) && (fsm_stateReg != fsm_3_sDrivePacket));
  assign fsm_onEntry_sSerialPacket = ((fsm_stateNext == fsm_3_sSerialPacket) && (fsm_stateReg != fsm_3_sSerialPacket));
  assign fsm_onEntry_sSerialNop = ((fsm_stateNext == fsm_3_sSerialNop) && (fsm_stateReg != fsm_3_sSerialNop));
  assign fsm_onEntry_sBubbleNop = ((fsm_stateNext == fsm_3_sBubbleNop) && (fsm_stateReg != fsm_3_sBubbleNop));
  assign fsm_onEntry_sMaskTransfer = ((fsm_stateNext == fsm_3_sMaskTransfer) && (fsm_stateReg != fsm_3_sMaskTransfer));
  assign fsm_onEntry_sDataTransfer = ((fsm_stateNext == fsm_3_sDataTransfer) && (fsm_stateReg != fsm_3_sDataTransfer));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_cmdIn_rValidN <= 1'b1;
      io_writeDataIn_rValidN <= 1'b1;
      readDataOutBuffer_rValid <= 1'b0;
      delayCalib_tapCounter_value <= 8'h0;
      delayCalib_bestDelay <= 8'h0;
      delayCalib_sampleHistory <= 8'h0;
      delayCalib_done <= 1'b0;
      delayCalib_state <= 3'b000;
      when_RpcDramPhy_l171 <= 1'b0;
      _zz_io_db <= 1'b0;
      when_RpcDramPhy_l171_1 <= 1'b0;
      when_RpcDramPhy_l171_2 <= 1'b0;
      fsm_cycleCounter_value <= 4'b0000;
      fsm_stbCounter_value <= 2'b00;
      fsm_maskCounter_value <= 1'b0;
      fsm_dataCounter_value <= 3'b000;
      fsm_burstCounter_value <= 6'h0;
      fsm_packetBuffer <= 32'h0;
      fsm_wordBuffer <= 256'h0;
      fsm_firstMask <= 32'h0;
      fsm_lastMask <= 32'h0;
      fsm_isInActivateState <= 1'b0;
      fsm_currentColAddr <= 10'h0;
      fsm_basePage <= 5'h0;
      fsm_serialCmdCount <= 6'h0;
      fsm_burstCountLimit <= 6'h0;
      fsm_bubbleNopCounter <= 7'h0;
      fsm_afterBurstStop <= 1'b0;
      fsm_tPpdCounter_value <= 3'b000;
      fsm_stateReg <= fsm_3_BOOT;
    end else begin
      if(io_cmdIn_valid) begin
        io_cmdIn_rValidN <= 1'b0;
      end
      if(cmdBuffer_ready) begin
        io_cmdIn_rValidN <= 1'b1;
      end
      if(io_writeDataIn_valid) begin
        io_writeDataIn_rValidN <= 1'b0;
      end
      if(writeDataBuffer_ready) begin
        io_writeDataIn_rValidN <= 1'b1;
      end
      if(readDataOutBuffer_ready) begin
        readDataOutBuffer_rValid <= readDataOutBuffer_valid;
      end
      delayCalib_tapCounter_value <= delayCalib_tapCounter_valueNext;
      if((delayCalib_state == delayCalib_sIdle)) begin
          if(when_RpcDramPhy_l289) begin
            delayCalib_done <= 1'b0;
            delayCalib_state <= delayCalib_sPrep;
          end else begin
            delayCalib_done <= 1'b1;
            delayCalib_bestDelay <= 8'h64;
            delayCalib_state <= delayCalib_sComplete;
          end
      end else if((delayCalib_state == delayCalib_sPrep)) begin
          delayCalib_sampleHistory <= 8'h0;
          delayCalib_state <= delayCalib_sSweep;
      end else if((delayCalib_state == delayCalib_sSweep)) begin
          delayCalib_sampleHistory <= {delayCalib_sampleHistory[6 : 0],1'b1};
          if(when_RpcDramPhy_l317) begin
            delayCalib_bestDelay <= delayCalib_tapCounter_value;
          end
          if(delayCalib_tapCounter_willOverflow) begin
            delayCalib_state <= delayCalib_sAnalyze;
          end
      end else if((delayCalib_state == delayCalib_sAnalyze)) begin
          if(when_RpcDramPhy_l328) begin
            delayCalib_done <= 1'b1;
            delayCalib_state <= delayCalib_sComplete;
          end else begin
            delayCalib_bestDelay <= 8'h96;
            delayCalib_done <= 1'b1;
            delayCalib_state <= delayCalib_sComplete;
          end
      end else if((delayCalib_state == delayCalib_sComplete)) begin
          delayCalib_done <= 1'b1;
      end
      when_RpcDramPhy_l171 <= (! when_RpcDramPhy_l171);
      _zz_io_db <= (! _zz_io_db);
      when_RpcDramPhy_l171_1 <= (! when_RpcDramPhy_l171_1);
      when_RpcDramPhy_l171_2 <= (! when_RpcDramPhy_l171_2);
      fsm_cycleCounter_value <= fsm_cycleCounter_valueNext;
      fsm_stbCounter_value <= fsm_stbCounter_valueNext;
      fsm_maskCounter_value <= fsm_maskCounter_valueNext;
      fsm_dataCounter_value <= fsm_dataCounter_valueNext;
      fsm_burstCounter_value <= fsm_burstCounter_valueNext;
      fsm_tPpdCounter_value <= fsm_tPpdCounter_valueNext;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_3_sIdle : begin
          if(when_RpcDramPhy_l440) begin
            if(fsm_tPpdCounter_willOverflow) begin
              fsm_afterBurstStop <= 1'b0;
            end
          end
          if(when_RpcDramPhy_l455) begin
            if(cmdBuffer_payload_isSerial) begin
              if(!when_RpcDramPhy_l462) begin
                fsm_packetBuffer <= {16'd0, _zz_fsm_packetBuffer};
              end
            end else begin
              fsm_packetBuffer <= _zz_fsm_packetBuffer_1;
            end
          end
        end
        fsm_3_sStbPrep : begin
        end
        fsm_3_sDrivePacket : begin
          if(when_RpcDramPhy_l508) begin
            if(when_RpcDramPhy_l520) begin
              fsm_isInActivateState <= 1'b1;
            end
            if(when_RpcDramPhy_l524) begin
              fsm_wordBuffer <= 256'h0;
              fsm_firstMask <= 32'h0;
              fsm_lastMask <= 32'h0;
              fsm_currentColAddr <= cmdBuffer_payload_colAddr;
              fsm_basePage <= cmdBuffer_payload_colAddr[9 : 5];
              fsm_burstCountLimit <= cmdBuffer_payload_burstCount;
              fsm_serialCmdCount <= 6'h0;
            end else begin
              if(when_RpcDramPhy_l550) begin
                fsm_isInActivateState <= 1'b0;
              end
            end
          end
        end
        fsm_3_sSerialPacket : begin
          if(when_RpcDramPhy_l574) begin
            if(when_RpcDramPhy_l585) begin
              fsm_wordBuffer <= 256'h0;
              fsm_firstMask <= 32'h0;
              fsm_lastMask <= 32'h0;
              fsm_currentColAddr <= cmdBuffer_payload_colAddr;
              fsm_basePage <= cmdBuffer_payload_colAddr[9 : 5];
              fsm_serialCmdCount <= (fsm_serialCmdCount + 6'h01);
              `ifndef SYNTHESIS
                `ifdef FORMAL
                  assert((fsm_serialCmdCount <= fsm_burstCountLimit)); // RpcDramPhy.scala:L597
                `else
                  if(!(fsm_serialCmdCount <= fsm_burstCountLimit)) begin
                    $display("FAILURE Serial command count exceeds burst limit (Notes 3, 4)"); // RpcDramPhy.scala:L597
                    $finish;
                  end
                `endif
              `endif
            end else begin
              if(when_RpcDramPhy_l612) begin
                fsm_bubbleNopCounter <= 7'h0;
              end else begin
                if(when_RpcDramPhy_l616) begin
                  fsm_afterBurstStop <= 1'b1;
                end
              end
            end
          end
        end
        fsm_3_sSerialNop : begin
        end
        fsm_3_sBubbleNop : begin
          fsm_bubbleNopCounter <= (fsm_bubbleNopCounter + 7'h01);
          `ifndef SYNTHESIS
            `ifdef FORMAL
              assert((fsm_bubbleNopCounter <= 7'h50)); // RpcDramPhy.scala:L654
            `else
              if(!(fsm_bubbleNopCounter <= 7'h50)) begin
                $display("FAILURE Bubble NOP count exceeds 80 cycles (Note 9.1)"); // RpcDramPhy.scala:L654
                $finish;
              end
            `endif
          `endif
          if(when_RpcDramPhy_l657) begin
            fsm_bubbleNopCounter <= 7'h0;
          end
        end
        fsm_3_sMaskTransfer : begin
          if(when_RpcDramPhy_l669) begin
            fsm_firstMask <= cmdBuffer_payload_writeMask[31 : 0];
          end else begin
            fsm_lastMask <= cmdBuffer_payload_writeMask[31 : 0];
          end
          if(fsm_maskCounter_willOverflow) begin
            fsm_wordBuffer <= 256'h0;
          end
        end
        fsm_3_sDataTransfer : begin
          if(when_RpcDramPhy_l703) begin
            if(when_RpcDramPhy_l708) begin
              fsm_wordBuffer <= writeDataBuffer_payload_fragment;
            end
            if(fsm_dataCounter_willOverflow) begin
              fsm_currentColAddr <= {fsm_basePage,_zz_fsm_currentColAddr[4 : 0]};
              if(when_RpcDramPhy_l754) begin
                fsm_isInActivateState <= 1'b0;
              end
            end
          end else begin
            if(fsm_dataCounter_willOverflow) begin
              fsm_currentColAddr <= {fsm_basePage,_zz_fsm_currentColAddr_1[4 : 0]};
              if(when_RpcDramPhy_l787) begin
                fsm_isInActivateState <= 1'b0;
              end
            end
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    if(io_cmdIn_ready) begin
      io_cmdIn_rData_isSerial <= io_cmdIn_payload_isSerial;
      io_cmdIn_rData_opcode <= io_cmdIn_payload_opcode;
      io_cmdIn_rData_bank <= io_cmdIn_payload_bank;
      io_cmdIn_rData_rowAddr <= io_cmdIn_payload_rowAddr;
      io_cmdIn_rData_colAddr <= io_cmdIn_payload_colAddr;
      io_cmdIn_rData_burstCount <= io_cmdIn_payload_burstCount;
      io_cmdIn_rData_writeMask <= io_cmdIn_payload_writeMask;
      io_cmdIn_rData_odt <= io_cmdIn_payload_odt;
    end
    if(io_writeDataIn_ready) begin
      io_writeDataIn_rData_last <= io_writeDataIn_payload_last;
      io_writeDataIn_rData_fragment <= io_writeDataIn_payload_fragment;
    end
    if(readDataOutBuffer_ready) begin
      readDataOutBuffer_rData_last <= readDataOutBuffer_payload_last;
      readDataOutBuffer_rData_fragment <= readDataOutBuffer_payload_fragment;
    end
  end

  always @(posedge clk) begin
    io_db_regNext <= io_db;
  end

  always @(posedge clk) begin
    io_db_regNext_1 <= io_db;
  end

  always @(posedge clk) begin
    io_dqs_regNext <= io_dqs;
  end

  always @(posedge clk) begin
    io_dqs_regNext_1 <= io_dqs;
  end

  always @(posedge clk or posedge clkGen_clk270Rst) begin
    if(clkGen_clk270Rst) begin
      _zz_io_dqs <= 1'b0;
      _zz_io_dqs1 <= 1'b0;
    end else begin
      _zz_io_dqs <= (! _zz_io_dqs);
      _zz_io_dqs1 <= (! _zz_io_dqs1);
    end
  end

  always @(posedge clk) begin
    io_dqs1_regNext <= io_dqs1;
  end

  always @(posedge clk) begin
    io_dqs1_regNext_1 <= io_dqs1;
  end

  always @(negedge clk or posedge clkGen_clk90Rst) begin
    if(clkGen_clk90Rst) begin
      stbArea_stbSignal <= 1'b1;
      stbArea_stbControl <= 1'b1;
    end else begin
      stbArea_stbSignal <= stbArea_stbControl;
      case(fsm_stateReg)
        fsm_3_sIdle : begin
          stbArea_stbControl <= 1'b1;
        end
        fsm_3_sStbPrep : begin
          stbArea_stbControl <= 1'b0;
        end
        fsm_3_sDrivePacket : begin
          stbArea_stbControl <= 1'b1;
        end
        fsm_3_sSerialPacket : begin
          stbArea_stbControl <= (! fsm_packetBuffer[fsm_cycleCounter_value]);
        end
        fsm_3_sSerialNop : begin
          stbArea_stbControl <= 1'b1;
        end
        fsm_3_sBubbleNop : begin
          stbArea_stbControl <= 1'b1;
        end
        fsm_3_sMaskTransfer : begin
        end
        fsm_3_sDataTransfer : begin
        end
        default : begin
        end
      endcase
    end
  end


endmodule

module PowerManager (
  input  wire          io_ctrl_enterPd,
  input  wire          io_ctrl_exitPd,
  input  wire          io_ctrl_enterDpd,
  output wire          io_ctrl_reInitRequired,
  input  wire [19:0]   io_timing_tCke,
  input  wire [19:0]   io_timing_tDpd,
  input  wire [7:0]    io_timing_tRcd,
  input  wire [7:0]    io_timing_tRp,
  input  wire [7:0]    io_timing_tWr,
  input  wire [7:0]    io_timing_tRas,
  input  wire [7:0]    io_timing_tRrd,
  input  wire [7:0]    io_timing_tPpd,
  input  wire [11:0]   io_timing_tZqInit,
  input  wire [7:0]    io_timing_tFaw,
  input  wire [7:0]    io_timing_tRfc,
  input  wire [7:0]    io_timing_tPhyWrLat,
  input  wire [7:0]    io_timing_tPhyRdLat,
  input  wire [7:0]    io_timing_tPhyWrData,
  input  wire [7:0]    io_timing_tRddataEn,
  output reg           io_cmdOut_valid,
  input  wire          io_cmdOut_ready,
  output reg           io_cmdOut_payload_isSerial,
  output reg  [5:0]    io_cmdOut_payload_opcode,
  output wire [1:0]    io_cmdOut_payload_bank,
  output wire [11:0]   io_cmdOut_payload_rowAddr,
  output wire [9:0]    io_cmdOut_payload_colAddr,
  output wire [5:0]    io_cmdOut_payload_burstCount,
  output wire [255:0]  io_cmdOut_payload_writeMask,
  output reg           io_cmdOut_payload_odt,
  input  wire          io_isIdle,
  output reg           io_inPowerDown,
  output reg           io_reInitRequired,
  input  wire          clk,
  input  wire          reset
);
  localparam fsm_2_BOOT = 3'd0;
  localparam fsm_2_sIdle = 3'd1;
  localparam fsm_2_sPdEntry = 3'd2;
  localparam fsm_2_sPowerDown = 3'd3;
  localparam fsm_2_sDpdEntry = 3'd4;
  localparam fsm_2_sDeepPowerDown = 3'd5;

  wire       [1:0]    _zz_fsm_ckeCounter_valueNext;
  wire       [0:0]    _zz_fsm_ckeCounter_valueNext_1;
  wire       [18:0]   _zz_fsm_dpdCounter_valueNext;
  wire       [0:0]    _zz_fsm_dpdCounter_valueNext_1;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg                 fsm_ckeCounter_willIncrement;
  reg                 fsm_ckeCounter_willClear;
  reg        [1:0]    fsm_ckeCounter_valueNext;
  reg        [1:0]    fsm_ckeCounter_value;
  wire                fsm_ckeCounter_willOverflowIfInc;
  wire                fsm_ckeCounter_willOverflow;
  reg                 fsm_dpdCounter_willIncrement;
  reg                 fsm_dpdCounter_willClear;
  reg        [18:0]   fsm_dpdCounter_valueNext;
  reg        [18:0]   fsm_dpdCounter_value;
  wire                fsm_dpdCounter_willOverflowIfInc;
  wire                fsm_dpdCounter_willOverflow;
  reg        [2:0]    fsm_stateReg;
  reg        [2:0]    fsm_stateNext;
  wire                when_PowerManager_l35;
  wire                when_PowerManager_l38;
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_sIdle;
  wire                fsm_onExit_sPdEntry;
  wire                fsm_onExit_sPowerDown;
  wire                fsm_onExit_sDpdEntry;
  wire                fsm_onExit_sDeepPowerDown;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_sIdle;
  wire                fsm_onEntry_sPdEntry;
  wire                fsm_onEntry_sPowerDown;
  wire                fsm_onEntry_sDpdEntry;
  wire                fsm_onEntry_sDeepPowerDown;
  `ifndef SYNTHESIS
  reg [111:0] fsm_stateReg_string;
  reg [111:0] fsm_stateNext_string;
  `endif


  assign _zz_fsm_ckeCounter_valueNext_1 = fsm_ckeCounter_willIncrement;
  assign _zz_fsm_ckeCounter_valueNext = {1'd0, _zz_fsm_ckeCounter_valueNext_1};
  assign _zz_fsm_dpdCounter_valueNext_1 = fsm_dpdCounter_willIncrement;
  assign _zz_fsm_dpdCounter_valueNext = {18'd0, _zz_fsm_dpdCounter_valueNext_1};
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_2_BOOT : fsm_stateReg_string = "BOOT          ";
      fsm_2_sIdle : fsm_stateReg_string = "sIdle         ";
      fsm_2_sPdEntry : fsm_stateReg_string = "sPdEntry      ";
      fsm_2_sPowerDown : fsm_stateReg_string = "sPowerDown    ";
      fsm_2_sDpdEntry : fsm_stateReg_string = "sDpdEntry     ";
      fsm_2_sDeepPowerDown : fsm_stateReg_string = "sDeepPowerDown";
      default : fsm_stateReg_string = "??????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_2_BOOT : fsm_stateNext_string = "BOOT          ";
      fsm_2_sIdle : fsm_stateNext_string = "sIdle         ";
      fsm_2_sPdEntry : fsm_stateNext_string = "sPdEntry      ";
      fsm_2_sPowerDown : fsm_stateNext_string = "sPowerDown    ";
      fsm_2_sDpdEntry : fsm_stateNext_string = "sDpdEntry     ";
      fsm_2_sDeepPowerDown : fsm_stateNext_string = "sDeepPowerDown";
      default : fsm_stateNext_string = "??????????????";
    endcase
  end
  `endif

  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  always @(*) begin
    fsm_ckeCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
        if(io_cmdOut_ready) begin
          fsm_ckeCounter_willIncrement = 1'b1;
        end
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_ckeCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
        if(when_PowerManager_l35) begin
          fsm_ckeCounter_willClear = 1'b1;
        end
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_ckeCounter_willOverflowIfInc = (fsm_ckeCounter_value == 2'b10);
  assign fsm_ckeCounter_willOverflow = (fsm_ckeCounter_willOverflowIfInc && fsm_ckeCounter_willIncrement);
  always @(*) begin
    if(fsm_ckeCounter_willOverflow) begin
      fsm_ckeCounter_valueNext = 2'b00;
    end else begin
      fsm_ckeCounter_valueNext = (fsm_ckeCounter_value + _zz_fsm_ckeCounter_valueNext);
    end
    if(fsm_ckeCounter_willClear) begin
      fsm_ckeCounter_valueNext = 2'b00;
    end
  end

  always @(*) begin
    fsm_dpdCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
        if(io_cmdOut_ready) begin
          fsm_dpdCounter_willIncrement = 1'b1;
        end
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_dpdCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
        if(!when_PowerManager_l35) begin
          if(when_PowerManager_l38) begin
            fsm_dpdCounter_willClear = 1'b1;
          end
        end
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_dpdCounter_willOverflowIfInc = (fsm_dpdCounter_value == 19'h61a7f);
  assign fsm_dpdCounter_willOverflow = (fsm_dpdCounter_willOverflowIfInc && fsm_dpdCounter_willIncrement);
  always @(*) begin
    if(fsm_dpdCounter_willOverflow) begin
      fsm_dpdCounter_valueNext = 19'h0;
    end else begin
      fsm_dpdCounter_valueNext = (fsm_dpdCounter_value + _zz_fsm_dpdCounter_valueNext);
    end
    if(fsm_dpdCounter_willClear) begin
      fsm_dpdCounter_valueNext = 19'h0;
    end
  end

  always @(*) begin
    io_cmdOut_valid = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_isSerial = 1'bx;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
        io_cmdOut_payload_isSerial = 1'b0;
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
        io_cmdOut_payload_isSerial = 1'b0;
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_opcode = 6'bxxxxxx;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
        io_cmdOut_payload_opcode = 6'h0;
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
        io_cmdOut_payload_opcode = 6'h0;
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  assign io_cmdOut_payload_bank = 2'bxx;
  assign io_cmdOut_payload_rowAddr = 12'bxxxxxxxxxxxx;
  assign io_cmdOut_payload_colAddr = 10'bxxxxxxxxxx;
  assign io_cmdOut_payload_burstCount = 6'bxxxxxx;
  assign io_cmdOut_payload_writeMask = 256'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
  always @(*) begin
    io_cmdOut_payload_odt = 1'bx;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
        io_cmdOut_payload_odt = 1'b0;
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
        io_cmdOut_payload_odt = 1'b0;
      end
      fsm_2_sDeepPowerDown : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_inPowerDown = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
        io_inPowerDown = 1'b1;
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
        io_inPowerDown = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_reInitRequired = 1'b0;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
      end
      fsm_2_sPdEntry : begin
      end
      fsm_2_sPowerDown : begin
      end
      fsm_2_sDpdEntry : begin
      end
      fsm_2_sDeepPowerDown : begin
        io_reInitRequired = 1'b1;
      end
      default : begin
      end
    endcase
  end

  assign io_ctrl_reInitRequired = io_reInitRequired;
  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_2_sIdle : begin
        if(when_PowerManager_l35) begin
          fsm_stateNext = fsm_2_sPdEntry;
        end else begin
          if(when_PowerManager_l38) begin
            fsm_stateNext = fsm_2_sDpdEntry;
          end
        end
      end
      fsm_2_sPdEntry : begin
        if(io_cmdOut_ready) begin
          if(fsm_ckeCounter_willOverflow) begin
            fsm_stateNext = fsm_2_sPowerDown;
          end
        end
      end
      fsm_2_sPowerDown : begin
        if(io_ctrl_exitPd) begin
          fsm_stateNext = fsm_2_sIdle;
        end
      end
      fsm_2_sDpdEntry : begin
        if(io_cmdOut_ready) begin
          if(fsm_dpdCounter_willOverflow) begin
            fsm_stateNext = fsm_2_sDeepPowerDown;
          end
        end
      end
      fsm_2_sDeepPowerDown : begin
        if(io_ctrl_exitPd) begin
          fsm_stateNext = fsm_2_sIdle;
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_2_sIdle;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_2_BOOT;
    end
  end

  assign when_PowerManager_l35 = (io_ctrl_enterPd && io_isIdle);
  assign when_PowerManager_l38 = (io_ctrl_enterDpd && io_isIdle);
  assign fsm_onExit_BOOT = ((fsm_stateNext != fsm_2_BOOT) && (fsm_stateReg == fsm_2_BOOT));
  assign fsm_onExit_sIdle = ((fsm_stateNext != fsm_2_sIdle) && (fsm_stateReg == fsm_2_sIdle));
  assign fsm_onExit_sPdEntry = ((fsm_stateNext != fsm_2_sPdEntry) && (fsm_stateReg == fsm_2_sPdEntry));
  assign fsm_onExit_sPowerDown = ((fsm_stateNext != fsm_2_sPowerDown) && (fsm_stateReg == fsm_2_sPowerDown));
  assign fsm_onExit_sDpdEntry = ((fsm_stateNext != fsm_2_sDpdEntry) && (fsm_stateReg == fsm_2_sDpdEntry));
  assign fsm_onExit_sDeepPowerDown = ((fsm_stateNext != fsm_2_sDeepPowerDown) && (fsm_stateReg == fsm_2_sDeepPowerDown));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == fsm_2_BOOT) && (fsm_stateReg != fsm_2_BOOT));
  assign fsm_onEntry_sIdle = ((fsm_stateNext == fsm_2_sIdle) && (fsm_stateReg != fsm_2_sIdle));
  assign fsm_onEntry_sPdEntry = ((fsm_stateNext == fsm_2_sPdEntry) && (fsm_stateReg != fsm_2_sPdEntry));
  assign fsm_onEntry_sPowerDown = ((fsm_stateNext == fsm_2_sPowerDown) && (fsm_stateReg != fsm_2_sPowerDown));
  assign fsm_onEntry_sDpdEntry = ((fsm_stateNext == fsm_2_sDpdEntry) && (fsm_stateReg != fsm_2_sDpdEntry));
  assign fsm_onEntry_sDeepPowerDown = ((fsm_stateNext == fsm_2_sDeepPowerDown) && (fsm_stateReg != fsm_2_sDeepPowerDown));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      fsm_ckeCounter_value <= 2'b00;
      fsm_dpdCounter_value <= 19'h0;
      fsm_stateReg <= fsm_2_BOOT;
    end else begin
      fsm_ckeCounter_value <= fsm_ckeCounter_valueNext;
      fsm_dpdCounter_value <= fsm_dpdCounter_valueNext;
      fsm_stateReg <= fsm_stateNext;
    end
  end


endmodule

module RefreshManager (
  input  wire [19:0]   io_timing_tCke,
  input  wire [19:0]   io_timing_tDpd,
  input  wire [7:0]    io_timing_tRcd,
  input  wire [7:0]    io_timing_tRp,
  input  wire [7:0]    io_timing_tWr,
  input  wire [7:0]    io_timing_tRas,
  input  wire [7:0]    io_timing_tRrd,
  input  wire [7:0]    io_timing_tPpd,
  input  wire [11:0]   io_timing_tZqInit,
  input  wire [7:0]    io_timing_tFaw,
  input  wire [7:0]    io_timing_tRfc,
  input  wire [7:0]    io_timing_tPhyWrLat,
  input  wire [7:0]    io_timing_tPhyRdLat,
  input  wire [7:0]    io_timing_tPhyWrData,
  input  wire [7:0]    io_timing_tRddataEn,
  output wire          io_toScheduler_valid,
  input  wire          io_toScheduler_ready,
  output wire          io_toScheduler_payload_isSerial,
  output wire [5:0]    io_toScheduler_payload_opcode,
  output wire [1:0]    io_toScheduler_payload_bank,
  output wire [11:0]   io_toScheduler_payload_rowAddr,
  output wire [9:0]    io_toScheduler_payload_colAddr,
  output wire [5:0]    io_toScheduler_payload_burstCount,
  output wire [255:0]  io_toScheduler_payload_writeMask,
  output wire          io_toScheduler_payload_odt,
  input  wire          io_autoRefresh,
  input  wire          clk,
  input  wire          reset
);

  reg        [25:0]   refreshCounter;
  wire                refreshHit;
  wire                when_RefreshManager_l28;
  reg                 refreshPending;
  wire                when_RefreshManager_l36;
  wire                cmdGen_cmd_isSerial;
  wire       [5:0]    cmdGen_cmd_opcode;
  wire       [1:0]    cmdGen_cmd_bank;
  wire       [11:0]   cmdGen_cmd_rowAddr;
  wire       [9:0]    cmdGen_cmd_colAddr;
  wire       [5:0]    cmdGen_cmd_burstCount;
  wire       [255:0]  cmdGen_cmd_writeMask;
  wire                cmdGen_cmd_odt;

  assign refreshHit = (refreshCounter == 26'h0);
  assign when_RefreshManager_l28 = (refreshHit || (! io_autoRefresh));
  assign when_RefreshManager_l36 = (! io_autoRefresh);
  assign cmdGen_cmd_isSerial = 1'b0;
  assign cmdGen_cmd_opcode = 6'h06;
  assign cmdGen_cmd_bank = 2'b00;
  assign cmdGen_cmd_rowAddr = 12'h0;
  assign cmdGen_cmd_colAddr = 10'h0;
  assign cmdGen_cmd_burstCount = 6'h0;
  assign cmdGen_cmd_writeMask = 256'h0;
  assign cmdGen_cmd_odt = 1'b1;
  assign io_toScheduler_valid = refreshPending;
  assign io_toScheduler_payload_isSerial = cmdGen_cmd_isSerial;
  assign io_toScheduler_payload_opcode = cmdGen_cmd_opcode;
  assign io_toScheduler_payload_bank = cmdGen_cmd_bank;
  assign io_toScheduler_payload_rowAddr = cmdGen_cmd_rowAddr;
  assign io_toScheduler_payload_colAddr = cmdGen_cmd_colAddr;
  assign io_toScheduler_payload_burstCount = cmdGen_cmd_burstCount;
  assign io_toScheduler_payload_writeMask = cmdGen_cmd_writeMask;
  assign io_toScheduler_payload_odt = cmdGen_cmd_odt;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      refreshCounter <= 26'h0;
      refreshPending <= 1'b0;
    end else begin
      refreshCounter <= (refreshCounter - 26'h0000001);
      if(when_RefreshManager_l28) begin
        refreshCounter <= 26'h30d4000;
      end
      if(io_toScheduler_ready) begin
        refreshPending <= 1'b0;
      end
      if(refreshHit) begin
        refreshPending <= 1'b1;
      end
      if(when_RefreshManager_l36) begin
        refreshPending <= 1'b0;
      end
    end
  end


endmodule

module CmdScheduler (
  input  wire          io_user_cmd_valid,
  output reg           io_user_cmd_ready,
  input  wire          io_user_cmd_payload_isWrite,
  input  wire [31:0]   io_user_cmd_payload_address,
  input  wire [5:0]    io_user_cmd_payload_burstLen,
  input  wire [255:0]  io_user_cmd_payload_writeMask,
  input  wire          io_user_writeData_valid,
  output wire          io_user_writeData_ready,
  input  wire          io_user_writeData_payload_last,
  input  wire [255:0]  io_user_writeData_payload_fragment,
  output wire          io_user_readData_valid,
  input  wire          io_user_readData_ready,
  output wire          io_user_readData_payload_last,
  output wire [255:0]  io_user_readData_payload_fragment,
  input  wire          io_initCmd_valid,
  output reg           io_initCmd_ready,
  input  wire          io_initCmd_payload_isSerial,
  input  wire [5:0]    io_initCmd_payload_opcode,
  input  wire [1:0]    io_initCmd_payload_bank,
  input  wire [11:0]   io_initCmd_payload_rowAddr,
  input  wire [9:0]    io_initCmd_payload_colAddr,
  input  wire [5:0]    io_initCmd_payload_burstCount,
  input  wire [255:0]  io_initCmd_payload_writeMask,
  input  wire          io_initCmd_payload_odt,
  input  wire          io_refreshCmd_valid,
  output reg           io_refreshCmd_ready,
  input  wire          io_refreshCmd_payload_isSerial,
  input  wire [5:0]    io_refreshCmd_payload_opcode,
  input  wire [1:0]    io_refreshCmd_payload_bank,
  input  wire [11:0]   io_refreshCmd_payload_rowAddr,
  input  wire [9:0]    io_refreshCmd_payload_colAddr,
  input  wire [5:0]    io_refreshCmd_payload_burstCount,
  input  wire [255:0]  io_refreshCmd_payload_writeMask,
  input  wire          io_refreshCmd_payload_odt,
  input  wire          io_powerCmd_valid,
  output reg           io_powerCmd_ready,
  input  wire          io_powerCmd_payload_isSerial,
  input  wire [5:0]    io_powerCmd_payload_opcode,
  input  wire [1:0]    io_powerCmd_payload_bank,
  input  wire [11:0]   io_powerCmd_payload_rowAddr,
  input  wire [9:0]    io_powerCmd_payload_colAddr,
  input  wire [5:0]    io_powerCmd_payload_burstCount,
  input  wire [255:0]  io_powerCmd_payload_writeMask,
  input  wire          io_powerCmd_payload_odt,
  output reg           io_toPhy_valid,
  input  wire          io_toPhy_ready,
  output wire          io_toPhy_payload_isSerial,
  output wire [5:0]    io_toPhy_payload_opcode,
  output wire [1:0]    io_toPhy_payload_bank,
  output wire [11:0]   io_toPhy_payload_rowAddr,
  output wire [9:0]    io_toPhy_payload_colAddr,
  output wire [5:0]    io_toPhy_payload_burstCount,
  output wire [255:0]  io_toPhy_payload_writeMask,
  output wire          io_toPhy_payload_odt,
  output reg           io_toBankTracker_activate_valid,
  input  wire          io_toBankTracker_activate_ready,
  output reg  [1:0]    io_toBankTracker_activate_payload_bank,
  output reg  [11:0]   io_toBankTracker_activate_payload_rowAddr,
  output reg           io_toBankTracker_precharge_valid,
  input  wire          io_toBankTracker_precharge_ready,
  output reg  [1:0]    io_toBankTracker_precharge_payload,
  input  wire [1:0]    io_fromBankTracker_bankStates_0,
  input  wire [1:0]    io_fromBankTracker_bankStates_1,
  input  wire [1:0]    io_fromBankTracker_bankStates_2,
  input  wire [1:0]    io_fromBankTracker_bankStates_3,
  input  wire [11:0]   io_fromBankTracker_openRow_0,
  input  wire [11:0]   io_fromBankTracker_openRow_1,
  input  wire [11:0]   io_fromBankTracker_openRow_2,
  input  wire [11:0]   io_fromBankTracker_openRow_3,
  input  wire          io_fromPhy_valid,
  output wire          io_fromPhy_ready,
  input  wire          io_fromPhy_payload,
  input  wire          io_initDone,
  input  wire [19:0]   io_currentTiming_tCke,
  input  wire [19:0]   io_currentTiming_tDpd,
  input  wire [7:0]    io_currentTiming_tRcd,
  input  wire [7:0]    io_currentTiming_tRp,
  input  wire [7:0]    io_currentTiming_tWr,
  input  wire [7:0]    io_currentTiming_tRas,
  input  wire [7:0]    io_currentTiming_tRrd,
  input  wire [7:0]    io_currentTiming_tPpd,
  input  wire [11:0]   io_currentTiming_tZqInit,
  input  wire [7:0]    io_currentTiming_tFaw,
  input  wire [7:0]    io_currentTiming_tRfc,
  input  wire [7:0]    io_currentTiming_tPhyWrLat,
  input  wire [7:0]    io_currentTiming_tPhyRdLat,
  input  wire [7:0]    io_currentTiming_tPhyWrData,
  input  wire [7:0]    io_currentTiming_tRddataEn,
  output wire [3:0]    io_debugInfo_currentState,
  output wire          io_debugInfo_timingViolation,
  output reg           io_debugInfo_illegalTransition,
  output reg           io_debugInfo_burstCountExceeded,
  output wire [2:0]    io_debugInfo_cmdSource,
  output wire [5:0]    io_debugInfo_pendingOpcode,
  output wire          io_debugInfo_validationLegal,
  output wire          io_debugInfo_validationDone,
  output wire          io_debugInfo_bubbleNopActive,
  output reg           io_debugInfo_serialCmdLimitViolated,
  output wire [31:0]   io_debugInfo_totalCommands,
  output wire [15:0]   io_debugInfo_timingViolations,
  output wire [15:0]   io_debugInfo_illegalTransitions,
  output wire [15:0]   io_debugInfo_burstLimitViolations,
  input  wire          clk,
  input  wire          reset
);
  localparam BankState_IDLE = 2'd0;
  localparam BankState_ACTIVATING = 2'd1;
  localparam BankState_ACTIVE = 2'd2;
  localparam BankState_PRECHARGING = 2'd3;
  localparam fsm_1_BOOT = 2'd0;
  localparam fsm_1_idlePhase = 2'd1;
  localparam fsm_1_commandPhase = 2'd2;
  localparam fsm_1_waitPhase = 2'd3;

  reg        [1:0]    _zz__zz_addrDecodeArea_needsActivate;
  reg        [11:0]   _zz_addrDecodeArea_needsActivate_1;
  wire       [7:0]    _zz_timingCounters_tRcdCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tRcdCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tRpCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tRpCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tRasCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tRasCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tRrdCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tRrdCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tPpdCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tPpdCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tRfcCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tRfcCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tFawCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tFawCounter_valueNext_1;
  wire       [7:0]    _zz_timingCounters_tWrCounter_valueNext;
  wire       [0:0]    _zz_timingCounters_tWrCounter_valueNext_1;
  wire       [2:0]    _zz_timingCounters_activateCount;
  wire       [1:0]    _zz_timingCounters_activateCount_1;
  wire       [2:0]    _zz_timingCounters_activateCount_2;
  wire       [1:0]    _zz_timingCounters_activateCount_3;
  wire       [3:0]    _zz_timingCounters_activateCount_4;
  wire       [1:0]    _zz_timingCounters_activateCount_5;
  wire       [5:0]    _zz_cmdValidationArea_burstCountValid;
  wire       [4:0]    _zz_cmdValidationArea_burstCountValid_1;
  wire       [5:0]    _zz_cmdValidationArea_burstCountValid_2;
  wire       [4:0]    _zz_cmdValidationArea_burstCountValid_3;
  wire       [5:0]    _zz_when_CmdScheduler_l665;
  wire       [4:0]    _zz_when_CmdScheduler_l665_1;
  wire       [5:0]    _zz_when_CmdScheduler_l665_2;
  wire       [4:0]    _zz_when_CmdScheduler_l665_3;
  wire       [5:0]    _zz_when_CmdScheduler_l669;
  wire       [4:0]    _zz_when_CmdScheduler_l669_1;
  wire       [5:0]    _zz_when_CmdScheduler_l675;
  wire       [4:0]    _zz_when_CmdScheduler_l675_1;
  wire       [5:0]    _zz_when_CmdScheduler_l675_2;
  wire       [4:0]    _zz_when_CmdScheduler_l675_3;
  reg        [1:0]    addrDecodeArea_bank;
  reg        [11:0]   addrDecodeArea_rowAddr;
  reg        [9:0]    addrDecodeArea_colAddr;
  reg                 addrDecodeArea_needsActivate;
  reg                 addrDecodeArea_addrValid;
  reg                 addrDecodeArea_userCmdBuffered;
  wire                when_CmdScheduler_l110;
  wire                when_CmdScheduler_l130;
  wire       [1:0]    _zz_addrDecodeArea_needsActivate;
  wire                when_CmdScheduler_l139;
  reg                 cmdValidationArea_isLegal;
  reg                 cmdValidationArea_validationDone;
  reg                 cmdValidationArea_burstCountValid;
  reg                 cmdValidationArea_lastValidatedCmd_isSerial;
  reg        [5:0]    cmdValidationArea_lastValidatedCmd_opcode;
  reg        [1:0]    cmdValidationArea_lastValidatedCmd_bank;
  reg        [11:0]   cmdValidationArea_lastValidatedCmd_rowAddr;
  reg        [9:0]    cmdValidationArea_lastValidatedCmd_colAddr;
  reg        [5:0]    cmdValidationArea_lastValidatedCmd_burstCount;
  reg        [255:0]  cmdValidationArea_lastValidatedCmd_writeMask;
  reg                 cmdValidationArea_lastValidatedCmd_odt;
  reg        [5:0]    cmdTracker_lastCmd;
  reg        [1:0]    cmdTracker_lastBank;
  reg                 cmdTracker_isSerial;
  reg        [5:0]    cmdTracker_burstCount;
  reg        [5:0]    cmdTracker_serialCmdCount;
  reg                 cmdTracker_inBurst;
  reg                 cmdTracker_afterBurstStop;
  reg                 cmdTracker_afterToggle;
  reg        [6:0]    cmdTracker_bubbleNopCounter;
  reg                 cmdTracker_inBubbleNop;
  reg        [31:0]   perfCounters_totalCommands;
  reg        [15:0]   perfCounters_timingViolations;
  reg        [15:0]   perfCounters_illegalTransitions;
  reg        [15:0]   perfCounters_burstLimitViolations;
  wire       [15:0]   perfCounters_refreshCycles;
  reg                 timingCounters_tRcdCounter_willIncrement;
  reg                 timingCounters_tRcdCounter_willClear;
  reg        [7:0]    timingCounters_tRcdCounter_valueNext;
  reg        [7:0]    timingCounters_tRcdCounter_value;
  wire                timingCounters_tRcdCounter_willOverflowIfInc;
  wire                timingCounters_tRcdCounter_willOverflow;
  reg                 timingCounters_tRpCounter_willIncrement;
  reg                 timingCounters_tRpCounter_willClear;
  reg        [7:0]    timingCounters_tRpCounter_valueNext;
  reg        [7:0]    timingCounters_tRpCounter_value;
  wire                timingCounters_tRpCounter_willOverflowIfInc;
  wire                timingCounters_tRpCounter_willOverflow;
  reg                 timingCounters_tRasCounter_willIncrement;
  reg                 timingCounters_tRasCounter_willClear;
  reg        [7:0]    timingCounters_tRasCounter_valueNext;
  reg        [7:0]    timingCounters_tRasCounter_value;
  wire                timingCounters_tRasCounter_willOverflowIfInc;
  wire                timingCounters_tRasCounter_willOverflow;
  reg                 timingCounters_tRrdCounter_willIncrement;
  wire                timingCounters_tRrdCounter_willClear;
  reg        [7:0]    timingCounters_tRrdCounter_valueNext;
  reg        [7:0]    timingCounters_tRrdCounter_value;
  wire                timingCounters_tRrdCounter_willOverflowIfInc;
  wire                timingCounters_tRrdCounter_willOverflow;
  reg                 timingCounters_tPpdCounter_willIncrement;
  reg                 timingCounters_tPpdCounter_willClear;
  reg        [7:0]    timingCounters_tPpdCounter_valueNext;
  reg        [7:0]    timingCounters_tPpdCounter_value;
  wire                timingCounters_tPpdCounter_willOverflowIfInc;
  wire                timingCounters_tPpdCounter_willOverflow;
  reg                 timingCounters_tRfcCounter_willIncrement;
  reg                 timingCounters_tRfcCounter_willClear;
  reg        [7:0]    timingCounters_tRfcCounter_valueNext;
  reg        [7:0]    timingCounters_tRfcCounter_value;
  wire                timingCounters_tRfcCounter_willOverflowIfInc;
  wire                timingCounters_tRfcCounter_willOverflow;
  reg                 timingCounters_tFawCounter_willIncrement;
  wire                timingCounters_tFawCounter_willClear;
  reg        [7:0]    timingCounters_tFawCounter_valueNext;
  reg        [7:0]    timingCounters_tFawCounter_value;
  wire                timingCounters_tFawCounter_willOverflowIfInc;
  wire                timingCounters_tFawCounter_willOverflow;
  reg                 timingCounters_tWrCounter_willIncrement;
  reg                 timingCounters_tWrCounter_willClear;
  reg        [7:0]    timingCounters_tWrCounter_valueNext;
  reg        [7:0]    timingCounters_tWrCounter_value;
  wire                timingCounters_tWrCounter_willOverflowIfInc;
  wire                timingCounters_tWrCounter_willOverflow;
  reg        [7:0]    timingCounters_currentTRcd_dup_0;
  reg        [7:0]    timingCounters_currentTRcd_dup_1;
  reg        [7:0]    timingCounters_currentTRcd_dup_2;
  reg        [7:0]    timingCounters_currentTRcd_dup_3;
  reg        [7:0]    timingCounters_currentTRp_dup_0;
  reg        [7:0]    timingCounters_currentTRp_dup_1;
  reg        [7:0]    timingCounters_currentTRp_dup_2;
  reg        [7:0]    timingCounters_currentTRp_dup_3;
  reg        [7:0]    timingCounters_currentTRas_dup_0;
  reg        [7:0]    timingCounters_currentTRas_dup_1;
  reg        [7:0]    timingCounters_currentTRas_dup_2;
  reg        [7:0]    timingCounters_currentTRas_dup_3;
  reg        [7:0]    timingCounters_currentTRrd;
  reg        [7:0]    timingCounters_currentTPpd;
  reg        [7:0]    timingCounters_currentTRfc;
  reg        [7:0]    timingCounters_currentTFaw;
  reg        [7:0]    timingCounters_currentTWr;
  reg                 timingCounters_activateHistory_0;
  reg                 timingCounters_activateHistory_1;
  reg                 timingCounters_activateHistory_2;
  reg                 timingCounters_activateHistory_3;
  wire       [3:0]    timingCounters_activateCount;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg        [1:0]    fsm_phaseSubState;
  reg                 fsm_pendingCmd_isSerial;
  reg        [5:0]    fsm_pendingCmd_opcode;
  reg        [1:0]    fsm_pendingCmd_bank;
  reg        [11:0]   fsm_pendingCmd_rowAddr;
  reg        [9:0]    fsm_pendingCmd_colAddr;
  reg        [5:0]    fsm_pendingCmd_burstCount;
  reg        [255:0]  fsm_pendingCmd_writeMask;
  reg                 fsm_pendingCmd_odt;
  reg        [2:0]    fsm_cmdSource;
  wire                fsm_timingViolation;
  reg                 fsm_timingViolation_regNext;
  wire                when_CmdScheduler_l497;
  reg        [1:0]    fsm_stateReg;
  reg        [1:0]    fsm_stateNext;
  wire                _zz_when_CmdScheduler_l535;
  wire                when_CmdScheduler_l535;
  wire                when_CmdScheduler_l541;
  wire                when_CmdScheduler_l547;
  wire                when_CmdScheduler_l553;
  wire                when_CmdScheduler_l422;
  wire                when_CmdScheduler_l618;
  wire                when_CmdScheduler_l621;
  wire                when_CmdScheduler_l627;
  wire                when_CmdScheduler_l633;
  wire                when_CmdScheduler_l658;
  wire                when_CmdScheduler_l665;
  wire                when_CmdScheduler_l669;
  wire                when_CmdScheduler_l675;
  wire                when_CmdScheduler_l682;
  wire                when_CmdScheduler_l688;
  wire                when_CmdScheduler_l694;
  wire                when_CmdScheduler_l703;
  wire                when_CmdScheduler_l706;
  wire                when_CmdScheduler_l709;
  wire                when_CmdScheduler_l752;
  wire                when_CmdScheduler_l769;
  wire                when_CmdScheduler_l774;
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_idlePhase;
  wire                fsm_onExit_commandPhase;
  wire                fsm_onExit_waitPhase;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_idlePhase;
  wire                fsm_onEntry_commandPhase;
  wire                fsm_onEntry_waitPhase;
  `ifndef SYNTHESIS
  reg [87:0] io_fromBankTracker_bankStates_0_string;
  reg [87:0] io_fromBankTracker_bankStates_1_string;
  reg [87:0] io_fromBankTracker_bankStates_2_string;
  reg [87:0] io_fromBankTracker_bankStates_3_string;
  reg [87:0] _zz_addrDecodeArea_needsActivate_string;
  reg [95:0] fsm_stateReg_string;
  reg [95:0] fsm_stateNext_string;
  `endif


  assign _zz_timingCounters_tRcdCounter_valueNext_1 = timingCounters_tRcdCounter_willIncrement;
  assign _zz_timingCounters_tRcdCounter_valueNext = {7'd0, _zz_timingCounters_tRcdCounter_valueNext_1};
  assign _zz_timingCounters_tRpCounter_valueNext_1 = timingCounters_tRpCounter_willIncrement;
  assign _zz_timingCounters_tRpCounter_valueNext = {7'd0, _zz_timingCounters_tRpCounter_valueNext_1};
  assign _zz_timingCounters_tRasCounter_valueNext_1 = timingCounters_tRasCounter_willIncrement;
  assign _zz_timingCounters_tRasCounter_valueNext = {7'd0, _zz_timingCounters_tRasCounter_valueNext_1};
  assign _zz_timingCounters_tRrdCounter_valueNext_1 = timingCounters_tRrdCounter_willIncrement;
  assign _zz_timingCounters_tRrdCounter_valueNext = {7'd0, _zz_timingCounters_tRrdCounter_valueNext_1};
  assign _zz_timingCounters_tPpdCounter_valueNext_1 = timingCounters_tPpdCounter_willIncrement;
  assign _zz_timingCounters_tPpdCounter_valueNext = {7'd0, _zz_timingCounters_tPpdCounter_valueNext_1};
  assign _zz_timingCounters_tRfcCounter_valueNext_1 = timingCounters_tRfcCounter_willIncrement;
  assign _zz_timingCounters_tRfcCounter_valueNext = {7'd0, _zz_timingCounters_tRfcCounter_valueNext_1};
  assign _zz_timingCounters_tFawCounter_valueNext_1 = timingCounters_tFawCounter_willIncrement;
  assign _zz_timingCounters_tFawCounter_valueNext = {7'd0, _zz_timingCounters_tFawCounter_valueNext_1};
  assign _zz_timingCounters_tWrCounter_valueNext_1 = timingCounters_tWrCounter_willIncrement;
  assign _zz_timingCounters_tWrCounter_valueNext = {7'd0, _zz_timingCounters_tWrCounter_valueNext_1};
  assign _zz_timingCounters_activateCount = ({1'b0,_zz_timingCounters_activateCount_1} + _zz_timingCounters_activateCount_2);
  assign _zz_timingCounters_activateCount_1 = ({1'b0,timingCounters_activateHistory_0} + {1'b0,timingCounters_activateHistory_1});
  assign _zz_timingCounters_activateCount_3 = {1'b0,timingCounters_activateHistory_2};
  assign _zz_timingCounters_activateCount_2 = {1'd0, _zz_timingCounters_activateCount_3};
  assign _zz_timingCounters_activateCount_5 = {1'b0,timingCounters_activateHistory_3};
  assign _zz_timingCounters_activateCount_4 = {2'd0, _zz_timingCounters_activateCount_5};
  assign _zz_cmdValidationArea_burstCountValid_1 = 5'h02;
  assign _zz_cmdValidationArea_burstCountValid = {1'd0, _zz_cmdValidationArea_burstCountValid_1};
  assign _zz_cmdValidationArea_burstCountValid_3 = 5'h03;
  assign _zz_cmdValidationArea_burstCountValid_2 = {1'd0, _zz_cmdValidationArea_burstCountValid_3};
  assign _zz_when_CmdScheduler_l665_1 = 5'h02;
  assign _zz_when_CmdScheduler_l665 = {1'd0, _zz_when_CmdScheduler_l665_1};
  assign _zz_when_CmdScheduler_l665_3 = 5'h03;
  assign _zz_when_CmdScheduler_l665_2 = {1'd0, _zz_when_CmdScheduler_l665_3};
  assign _zz_when_CmdScheduler_l669_1 = 5'h08;
  assign _zz_when_CmdScheduler_l669 = {1'd0, _zz_when_CmdScheduler_l669_1};
  assign _zz_when_CmdScheduler_l675_1 = 5'h06;
  assign _zz_when_CmdScheduler_l675 = {1'd0, _zz_when_CmdScheduler_l675_1};
  assign _zz_when_CmdScheduler_l675_3 = 5'h07;
  assign _zz_when_CmdScheduler_l675_2 = {1'd0, _zz_when_CmdScheduler_l675_3};
  always @(*) begin
    case(addrDecodeArea_bank)
      2'b00 : begin
        _zz__zz_addrDecodeArea_needsActivate = io_fromBankTracker_bankStates_0;
        _zz_addrDecodeArea_needsActivate_1 = io_fromBankTracker_openRow_0;
      end
      2'b01 : begin
        _zz__zz_addrDecodeArea_needsActivate = io_fromBankTracker_bankStates_1;
        _zz_addrDecodeArea_needsActivate_1 = io_fromBankTracker_openRow_1;
      end
      2'b10 : begin
        _zz__zz_addrDecodeArea_needsActivate = io_fromBankTracker_bankStates_2;
        _zz_addrDecodeArea_needsActivate_1 = io_fromBankTracker_openRow_2;
      end
      default : begin
        _zz__zz_addrDecodeArea_needsActivate = io_fromBankTracker_bankStates_3;
        _zz_addrDecodeArea_needsActivate_1 = io_fromBankTracker_openRow_3;
      end
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(io_fromBankTracker_bankStates_0)
      BankState_IDLE : io_fromBankTracker_bankStates_0_string = "IDLE       ";
      BankState_ACTIVATING : io_fromBankTracker_bankStates_0_string = "ACTIVATING ";
      BankState_ACTIVE : io_fromBankTracker_bankStates_0_string = "ACTIVE     ";
      BankState_PRECHARGING : io_fromBankTracker_bankStates_0_string = "PRECHARGING";
      default : io_fromBankTracker_bankStates_0_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_fromBankTracker_bankStates_1)
      BankState_IDLE : io_fromBankTracker_bankStates_1_string = "IDLE       ";
      BankState_ACTIVATING : io_fromBankTracker_bankStates_1_string = "ACTIVATING ";
      BankState_ACTIVE : io_fromBankTracker_bankStates_1_string = "ACTIVE     ";
      BankState_PRECHARGING : io_fromBankTracker_bankStates_1_string = "PRECHARGING";
      default : io_fromBankTracker_bankStates_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_fromBankTracker_bankStates_2)
      BankState_IDLE : io_fromBankTracker_bankStates_2_string = "IDLE       ";
      BankState_ACTIVATING : io_fromBankTracker_bankStates_2_string = "ACTIVATING ";
      BankState_ACTIVE : io_fromBankTracker_bankStates_2_string = "ACTIVE     ";
      BankState_PRECHARGING : io_fromBankTracker_bankStates_2_string = "PRECHARGING";
      default : io_fromBankTracker_bankStates_2_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_fromBankTracker_bankStates_3)
      BankState_IDLE : io_fromBankTracker_bankStates_3_string = "IDLE       ";
      BankState_ACTIVATING : io_fromBankTracker_bankStates_3_string = "ACTIVATING ";
      BankState_ACTIVE : io_fromBankTracker_bankStates_3_string = "ACTIVE     ";
      BankState_PRECHARGING : io_fromBankTracker_bankStates_3_string = "PRECHARGING";
      default : io_fromBankTracker_bankStates_3_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_addrDecodeArea_needsActivate)
      BankState_IDLE : _zz_addrDecodeArea_needsActivate_string = "IDLE       ";
      BankState_ACTIVATING : _zz_addrDecodeArea_needsActivate_string = "ACTIVATING ";
      BankState_ACTIVE : _zz_addrDecodeArea_needsActivate_string = "ACTIVE     ";
      BankState_PRECHARGING : _zz_addrDecodeArea_needsActivate_string = "PRECHARGING";
      default : _zz_addrDecodeArea_needsActivate_string = "???????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateReg)
      fsm_1_BOOT : fsm_stateReg_string = "BOOT        ";
      fsm_1_idlePhase : fsm_stateReg_string = "idlePhase   ";
      fsm_1_commandPhase : fsm_stateReg_string = "commandPhase";
      fsm_1_waitPhase : fsm_stateReg_string = "waitPhase   ";
      default : fsm_stateReg_string = "????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_1_BOOT : fsm_stateNext_string = "BOOT        ";
      fsm_1_idlePhase : fsm_stateNext_string = "idlePhase   ";
      fsm_1_commandPhase : fsm_stateNext_string = "commandPhase";
      fsm_1_waitPhase : fsm_stateNext_string = "waitPhase   ";
      default : fsm_stateNext_string = "????????????";
    endcase
  end
  `endif

  assign when_CmdScheduler_l110 = (io_user_cmd_valid && (! addrDecodeArea_userCmdBuffered));
  assign when_CmdScheduler_l130 = (addrDecodeArea_userCmdBuffered && (! addrDecodeArea_addrValid));
  assign _zz_addrDecodeArea_needsActivate = _zz__zz_addrDecodeArea_needsActivate;
  assign when_CmdScheduler_l139 = ((addrDecodeArea_addrValid && io_user_cmd_valid) && io_user_cmd_ready);
  assign perfCounters_refreshCycles = 16'h0;
  always @(*) begin
    timingCounters_tRcdCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tRcdCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tRcdCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l694) begin
                timingCounters_tRcdCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tRcdCounter_willOverflowIfInc = (timingCounters_tRcdCounter_value == 8'hff);
  assign timingCounters_tRcdCounter_willOverflow = (timingCounters_tRcdCounter_willOverflowIfInc && timingCounters_tRcdCounter_willIncrement);
  always @(*) begin
    timingCounters_tRcdCounter_valueNext = (timingCounters_tRcdCounter_value + _zz_timingCounters_tRcdCounter_valueNext);
    if(timingCounters_tRcdCounter_willClear) begin
      timingCounters_tRcdCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tRpCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tRpCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tRpCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l703) begin
                timingCounters_tRpCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tRpCounter_willOverflowIfInc = (timingCounters_tRpCounter_value == 8'hff);
  assign timingCounters_tRpCounter_willOverflow = (timingCounters_tRpCounter_willOverflowIfInc && timingCounters_tRpCounter_willIncrement);
  always @(*) begin
    timingCounters_tRpCounter_valueNext = (timingCounters_tRpCounter_value + _zz_timingCounters_tRpCounter_valueNext);
    if(timingCounters_tRpCounter_willClear) begin
      timingCounters_tRpCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tRasCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tRasCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tRasCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l694) begin
                timingCounters_tRasCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tRasCounter_willOverflowIfInc = (timingCounters_tRasCounter_value == 8'hff);
  assign timingCounters_tRasCounter_willOverflow = (timingCounters_tRasCounter_willOverflowIfInc && timingCounters_tRasCounter_willIncrement);
  always @(*) begin
    timingCounters_tRasCounter_valueNext = (timingCounters_tRasCounter_value + _zz_timingCounters_tRasCounter_valueNext);
    if(timingCounters_tRasCounter_willClear) begin
      timingCounters_tRasCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tRrdCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tRrdCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tRrdCounter_willClear = 1'b0;
  assign timingCounters_tRrdCounter_willOverflowIfInc = (timingCounters_tRrdCounter_value == 8'hff);
  assign timingCounters_tRrdCounter_willOverflow = (timingCounters_tRrdCounter_willOverflowIfInc && timingCounters_tRrdCounter_willIncrement);
  always @(*) begin
    timingCounters_tRrdCounter_valueNext = (timingCounters_tRrdCounter_value + _zz_timingCounters_tRrdCounter_valueNext);
    if(timingCounters_tRrdCounter_willClear) begin
      timingCounters_tRrdCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tPpdCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tPpdCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tPpdCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l669) begin
                timingCounters_tPpdCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tPpdCounter_willOverflowIfInc = (timingCounters_tPpdCounter_value == 8'hff);
  assign timingCounters_tPpdCounter_willOverflow = (timingCounters_tPpdCounter_willOverflowIfInc && timingCounters_tPpdCounter_willIncrement);
  always @(*) begin
    timingCounters_tPpdCounter_valueNext = (timingCounters_tPpdCounter_value + _zz_timingCounters_tPpdCounter_valueNext);
    if(timingCounters_tPpdCounter_willClear) begin
      timingCounters_tPpdCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tRfcCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tRfcCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tRfcCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l706) begin
                timingCounters_tRfcCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tRfcCounter_willOverflowIfInc = (timingCounters_tRfcCounter_value == 8'hff);
  assign timingCounters_tRfcCounter_willOverflow = (timingCounters_tRfcCounter_willOverflowIfInc && timingCounters_tRfcCounter_willIncrement);
  always @(*) begin
    timingCounters_tRfcCounter_valueNext = (timingCounters_tRfcCounter_value + _zz_timingCounters_tRfcCounter_valueNext);
    if(timingCounters_tRfcCounter_willClear) begin
      timingCounters_tRfcCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tFawCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tFawCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tFawCounter_willClear = 1'b0;
  assign timingCounters_tFawCounter_willOverflowIfInc = (timingCounters_tFawCounter_value == 8'hff);
  assign timingCounters_tFawCounter_willOverflow = (timingCounters_tFawCounter_willOverflowIfInc && timingCounters_tFawCounter_willIncrement);
  always @(*) begin
    timingCounters_tFawCounter_valueNext = (timingCounters_tFawCounter_value + _zz_timingCounters_tFawCounter_valueNext);
    if(timingCounters_tFawCounter_willClear) begin
      timingCounters_tFawCounter_valueNext = 8'h0;
    end
  end

  always @(*) begin
    timingCounters_tWrCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
        if(!cmdTracker_inBurst) begin
          if(!cmdTracker_inBubbleNop) begin
            timingCounters_tWrCounter_willIncrement = 1'b1;
          end
        end
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    timingCounters_tWrCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l709) begin
                timingCounters_tWrCounter_willClear = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign timingCounters_tWrCounter_willOverflowIfInc = (timingCounters_tWrCounter_value == 8'hff);
  assign timingCounters_tWrCounter_willOverflow = (timingCounters_tWrCounter_willOverflowIfInc && timingCounters_tWrCounter_willIncrement);
  always @(*) begin
    timingCounters_tWrCounter_valueNext = (timingCounters_tWrCounter_value + _zz_timingCounters_tWrCounter_valueNext);
    if(timingCounters_tWrCounter_willClear) begin
      timingCounters_tWrCounter_valueNext = 8'h0;
    end
  end

  assign timingCounters_activateCount = ({1'b0,_zz_timingCounters_activateCount} + _zz_timingCounters_activateCount_4);
  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
      end
      fsm_1_waitPhase : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  assign io_debugInfo_currentState = {fsm_phaseSubState,2'b00};
  assign fsm_timingViolation = ((! (((((((timingCounters_currentTRcd_dup_0 <= timingCounters_tRcdCounter_value) && (timingCounters_currentTRp_dup_0 <= timingCounters_tRpCounter_value)) && (timingCounters_currentTRas_dup_0 <= timingCounters_tRasCounter_value)) && (timingCounters_currentTRrd <= timingCounters_tRrdCounter_value)) && (timingCounters_currentTPpd <= timingCounters_tPpdCounter_value)) && (timingCounters_currentTRfc <= timingCounters_tRfcCounter_value)) && (timingCounters_currentTWr <= timingCounters_tWrCounter_value))) && (cmdTracker_lastCmd != 6'h0));
  assign io_debugInfo_timingViolation = fsm_timingViolation;
  assign when_CmdScheduler_l497 = (fsm_timingViolation && (! fsm_timingViolation_regNext));
  always @(*) begin
    io_debugInfo_illegalTransition = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b10 : begin
            if(!when_CmdScheduler_l618) begin
              if(when_CmdScheduler_l621) begin
                io_debugInfo_illegalTransition = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_debugInfo_burstCountExceeded = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b10 : begin
            if(!when_CmdScheduler_l618) begin
              if(!when_CmdScheduler_l621) begin
                if(!when_CmdScheduler_l627) begin
                  if(when_CmdScheduler_l633) begin
                    io_debugInfo_burstCountExceeded = 1'b1;
                  end
                end
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign io_debugInfo_cmdSource = fsm_cmdSource;
  assign io_debugInfo_pendingOpcode = fsm_pendingCmd_opcode;
  assign io_debugInfo_validationLegal = cmdValidationArea_isLegal;
  assign io_debugInfo_validationDone = cmdValidationArea_validationDone;
  assign io_debugInfo_bubbleNopActive = cmdTracker_inBubbleNop;
  always @(*) begin
    io_debugInfo_serialCmdLimitViolated = (cmdTracker_burstCount < cmdTracker_serialCmdCount);
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b10 : begin
            if(!when_CmdScheduler_l618) begin
              if(!when_CmdScheduler_l621) begin
                if(when_CmdScheduler_l627) begin
                  io_debugInfo_serialCmdLimitViolated = 1'b1;
                end
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign io_debugInfo_totalCommands = perfCounters_totalCommands;
  assign io_debugInfo_timingViolations = perfCounters_timingViolations;
  assign io_debugInfo_illegalTransitions = perfCounters_illegalTransitions;
  assign io_debugInfo_burstLimitViolations = perfCounters_burstLimitViolations;
  always @(*) begin
    io_toPhy_valid = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            io_toPhy_valid = 1'b1;
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign io_toPhy_payload_isSerial = fsm_pendingCmd_isSerial;
  assign io_toPhy_payload_opcode = fsm_pendingCmd_opcode;
  assign io_toPhy_payload_bank = fsm_pendingCmd_bank;
  assign io_toPhy_payload_rowAddr = fsm_pendingCmd_rowAddr;
  assign io_toPhy_payload_colAddr = fsm_pendingCmd_colAddr;
  assign io_toPhy_payload_burstCount = fsm_pendingCmd_burstCount;
  assign io_toPhy_payload_writeMask = fsm_pendingCmd_writeMask;
  assign io_toPhy_payload_odt = fsm_pendingCmd_odt;
  always @(*) begin
    io_user_cmd_ready = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              case(fsm_cmdSource)
                3'b011 : begin
                  io_user_cmd_ready = 1'b1;
                end
                default : begin
                end
              endcase
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_initCmd_ready = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
        if(when_CmdScheduler_l535) begin
          io_initCmd_ready = 1'b1;
        end
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              case(fsm_cmdSource)
                3'b000 : begin
                  io_initCmd_ready = 1'b1;
                end
                default : begin
                end
              endcase
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_refreshCmd_ready = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
        if(!when_CmdScheduler_l535) begin
          if(when_CmdScheduler_l541) begin
            io_refreshCmd_ready = 1'b1;
          end
        end
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              case(fsm_cmdSource)
                3'b001 : begin
                  io_refreshCmd_ready = 1'b1;
                end
                default : begin
                end
              endcase
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_powerCmd_ready = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
        if(!when_CmdScheduler_l535) begin
          if(!when_CmdScheduler_l541) begin
            if(when_CmdScheduler_l547) begin
              io_powerCmd_ready = 1'b1;
            end
          end
        end
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              case(fsm_cmdSource)
                3'b010 : begin
                  io_powerCmd_ready = 1'b1;
                end
                default : begin
                end
              endcase
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  assign io_fromPhy_ready = 1'b1;
  always @(*) begin
    io_toBankTracker_activate_valid = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l682) begin
                io_toBankTracker_activate_valid = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_toBankTracker_activate_payload_bank = 2'b00;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l682) begin
                io_toBankTracker_activate_payload_bank = fsm_pendingCmd_bank;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_toBankTracker_activate_payload_rowAddr = 12'h0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l682) begin
                io_toBankTracker_activate_payload_rowAddr = fsm_pendingCmd_rowAddr;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_toBankTracker_precharge_valid = 1'b0;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l688) begin
                io_toBankTracker_precharge_valid = 1'b1;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_toBankTracker_precharge_payload = 2'b00;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(when_CmdScheduler_l688) begin
                io_toBankTracker_precharge_payload = fsm_pendingCmd_bank;
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_1_idlePhase : begin
        if(when_CmdScheduler_l535) begin
          fsm_stateNext = fsm_1_commandPhase;
        end else begin
          if(when_CmdScheduler_l541) begin
            fsm_stateNext = fsm_1_commandPhase;
          end else begin
            if(when_CmdScheduler_l547) begin
              fsm_stateNext = fsm_1_commandPhase;
            end else begin
              if(when_CmdScheduler_l553) begin
                fsm_stateNext = fsm_1_commandPhase;
              end
            end
          end
        end
      end
      fsm_1_commandPhase : begin
        case(fsm_phaseSubState)
          2'b10 : begin
            if(!when_CmdScheduler_l618) begin
              if(when_CmdScheduler_l621) begin
                fsm_stateNext = fsm_1_idlePhase;
              end else begin
                if(when_CmdScheduler_l627) begin
                  fsm_stateNext = fsm_1_idlePhase;
                end else begin
                  if(when_CmdScheduler_l633) begin
                    fsm_stateNext = fsm_1_idlePhase;
                  end
                end
              end
            end
          end
          2'b11 : begin
            if(io_toPhy_ready) begin
              if(cmdTracker_inBubbleNop) begin
                fsm_stateNext = fsm_1_waitPhase;
              end else begin
                if(cmdTracker_inBurst) begin
                  fsm_stateNext = fsm_1_waitPhase;
                end else begin
                  fsm_stateNext = fsm_1_waitPhase;
                end
              end
            end
          end
          default : begin
          end
        endcase
      end
      fsm_1_waitPhase : begin
        if(cmdTracker_inBurst) begin
          if(io_fromPhy_valid) begin
            fsm_stateNext = fsm_1_idlePhase;
          end
        end else begin
          if(cmdTracker_inBubbleNop) begin
            if(when_CmdScheduler_l752) begin
              fsm_stateNext = fsm_1_idlePhase;
            end
          end else begin
            if(when_CmdScheduler_l774) begin
              fsm_stateNext = fsm_1_idlePhase;
            end
          end
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_1_idlePhase;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_1_BOOT;
    end
  end

  assign _zz_when_CmdScheduler_l535 = (! cmdTracker_inBubbleNop);
  assign when_CmdScheduler_l535 = (io_initCmd_valid && _zz_when_CmdScheduler_l535);
  assign when_CmdScheduler_l541 = (io_refreshCmd_valid && _zz_when_CmdScheduler_l535);
  assign when_CmdScheduler_l547 = (io_powerCmd_valid && _zz_when_CmdScheduler_l535);
  assign when_CmdScheduler_l553 = (((io_user_cmd_valid && io_initDone) && addrDecodeArea_addrValid) && _zz_when_CmdScheduler_l535);
  assign when_CmdScheduler_l422 = (cmdTracker_lastCmd == 6'h0);
  assign when_CmdScheduler_l618 = (! cmdValidationArea_validationDone);
  assign when_CmdScheduler_l621 = (! cmdValidationArea_isLegal);
  assign when_CmdScheduler_l627 = (cmdTracker_burstCount < cmdTracker_serialCmdCount);
  assign when_CmdScheduler_l633 = (! cmdValidationArea_burstCountValid);
  assign when_CmdScheduler_l658 = ((fsm_pendingCmd_opcode == 6'h02) || (fsm_pendingCmd_opcode == 6'h03));
  assign when_CmdScheduler_l665 = (fsm_pendingCmd_isSerial && ((fsm_pendingCmd_opcode == _zz_when_CmdScheduler_l665) || (fsm_pendingCmd_opcode == _zz_when_CmdScheduler_l665_2)));
  assign when_CmdScheduler_l669 = (fsm_pendingCmd_opcode == _zz_when_CmdScheduler_l669);
  assign when_CmdScheduler_l675 = ((fsm_pendingCmd_opcode == _zz_when_CmdScheduler_l675) || (fsm_pendingCmd_opcode == _zz_when_CmdScheduler_l675_2));
  assign when_CmdScheduler_l682 = (fsm_pendingCmd_opcode == 6'h01);
  assign when_CmdScheduler_l688 = (fsm_pendingCmd_opcode == 6'h05);
  assign when_CmdScheduler_l694 = (fsm_pendingCmd_opcode == 6'h01);
  assign when_CmdScheduler_l703 = (fsm_pendingCmd_opcode == 6'h05);
  assign when_CmdScheduler_l706 = (fsm_pendingCmd_opcode == 6'h06);
  assign when_CmdScheduler_l709 = (fsm_pendingCmd_opcode == 6'h03);
  assign when_CmdScheduler_l752 = (7'h08 <= cmdTracker_bubbleNopCounter);
  assign when_CmdScheduler_l769 = (cmdTracker_afterBurstStop && (timingCounters_currentTPpd <= timingCounters_tPpdCounter_value));
  assign when_CmdScheduler_l774 = (((((((timingCounters_currentTRcd_dup_0 <= timingCounters_tRcdCounter_value) && (timingCounters_currentTRp_dup_0 <= timingCounters_tRpCounter_value)) && (timingCounters_currentTRas_dup_0 <= timingCounters_tRasCounter_value)) && (timingCounters_currentTRrd <= timingCounters_tRrdCounter_value)) && (timingCounters_currentTPpd <= timingCounters_tPpdCounter_value)) && (timingCounters_currentTRfc <= timingCounters_tRfcCounter_value)) && (timingCounters_currentTWr <= timingCounters_tWrCounter_value));
  assign fsm_onExit_BOOT = ((fsm_stateNext != fsm_1_BOOT) && (fsm_stateReg == fsm_1_BOOT));
  assign fsm_onExit_idlePhase = ((fsm_stateNext != fsm_1_idlePhase) && (fsm_stateReg == fsm_1_idlePhase));
  assign fsm_onExit_commandPhase = ((fsm_stateNext != fsm_1_commandPhase) && (fsm_stateReg == fsm_1_commandPhase));
  assign fsm_onExit_waitPhase = ((fsm_stateNext != fsm_1_waitPhase) && (fsm_stateReg == fsm_1_waitPhase));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == fsm_1_BOOT) && (fsm_stateReg != fsm_1_BOOT));
  assign fsm_onEntry_idlePhase = ((fsm_stateNext == fsm_1_idlePhase) && (fsm_stateReg != fsm_1_idlePhase));
  assign fsm_onEntry_commandPhase = ((fsm_stateNext == fsm_1_commandPhase) && (fsm_stateReg != fsm_1_commandPhase));
  assign fsm_onEntry_waitPhase = ((fsm_stateNext == fsm_1_waitPhase) && (fsm_stateReg != fsm_1_waitPhase));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      addrDecodeArea_bank <= 2'b00;
      addrDecodeArea_rowAddr <= 12'h0;
      addrDecodeArea_colAddr <= 10'h0;
      addrDecodeArea_needsActivate <= 1'b0;
      addrDecodeArea_addrValid <= 1'b0;
      addrDecodeArea_userCmdBuffered <= 1'b0;
      cmdValidationArea_isLegal <= 1'b1;
      cmdValidationArea_validationDone <= 1'b0;
      cmdValidationArea_burstCountValid <= 1'b1;
      cmdValidationArea_lastValidatedCmd_isSerial <= 1'b0;
      cmdValidationArea_lastValidatedCmd_opcode <= 6'h0;
      cmdValidationArea_lastValidatedCmd_bank <= 2'b00;
      cmdValidationArea_lastValidatedCmd_rowAddr <= 12'h0;
      cmdValidationArea_lastValidatedCmd_colAddr <= 10'h0;
      cmdValidationArea_lastValidatedCmd_burstCount <= 6'h0;
      cmdValidationArea_lastValidatedCmd_writeMask <= 256'h0;
      cmdValidationArea_lastValidatedCmd_odt <= 1'b0;
      cmdTracker_lastCmd <= 6'h0;
      cmdTracker_lastBank <= 2'b00;
      cmdTracker_isSerial <= 1'b0;
      cmdTracker_burstCount <= 6'h0;
      cmdTracker_serialCmdCount <= 6'h0;
      cmdTracker_inBurst <= 1'b0;
      cmdTracker_afterBurstStop <= 1'b0;
      cmdTracker_afterToggle <= 1'b0;
      cmdTracker_bubbleNopCounter <= 7'h0;
      cmdTracker_inBubbleNop <= 1'b0;
      perfCounters_totalCommands <= 32'h0;
      perfCounters_timingViolations <= 16'h0;
      perfCounters_illegalTransitions <= 16'h0;
      perfCounters_burstLimitViolations <= 16'h0;
      timingCounters_tRcdCounter_value <= 8'h0;
      timingCounters_tRpCounter_value <= 8'h0;
      timingCounters_tRasCounter_value <= 8'h0;
      timingCounters_tRrdCounter_value <= 8'h0;
      timingCounters_tPpdCounter_value <= 8'h0;
      timingCounters_tRfcCounter_value <= 8'h0;
      timingCounters_tFawCounter_value <= 8'h0;
      timingCounters_tWrCounter_value <= 8'h0;
      timingCounters_activateHistory_0 <= 1'b0;
      timingCounters_activateHistory_1 <= 1'b0;
      timingCounters_activateHistory_2 <= 1'b0;
      timingCounters_activateHistory_3 <= 1'b0;
      fsm_phaseSubState <= 2'b00;
      fsm_pendingCmd_isSerial <= 1'b0;
      fsm_pendingCmd_opcode <= 6'h0;
      fsm_pendingCmd_bank <= 2'b00;
      fsm_pendingCmd_rowAddr <= 12'h0;
      fsm_pendingCmd_colAddr <= 10'h0;
      fsm_pendingCmd_burstCount <= 6'h0;
      fsm_pendingCmd_writeMask <= 256'h0;
      fsm_pendingCmd_odt <= 1'b0;
      fsm_cmdSource <= 3'b000;
      fsm_stateReg <= fsm_1_BOOT;
    end else begin
      if(when_CmdScheduler_l110) begin
        addrDecodeArea_bank <= io_user_cmd_payload_address[13 : 12];
        addrDecodeArea_rowAddr <= io_user_cmd_payload_address[25 : 14];
        addrDecodeArea_colAddr <= io_user_cmd_payload_address[11 : 2];
        addrDecodeArea_userCmdBuffered <= 1'b1;
      end
      if(when_CmdScheduler_l130) begin
        addrDecodeArea_needsActivate <= ((_zz_addrDecodeArea_needsActivate != BankState_ACTIVE) || (_zz_addrDecodeArea_needsActivate_1 != addrDecodeArea_rowAddr));
        addrDecodeArea_addrValid <= 1'b1;
      end
      if(when_CmdScheduler_l139) begin
        addrDecodeArea_addrValid <= 1'b0;
        addrDecodeArea_userCmdBuffered <= 1'b0;
      end
      timingCounters_tRcdCounter_value <= timingCounters_tRcdCounter_valueNext;
      timingCounters_tRpCounter_value <= timingCounters_tRpCounter_valueNext;
      timingCounters_tRasCounter_value <= timingCounters_tRasCounter_valueNext;
      timingCounters_tRrdCounter_value <= timingCounters_tRrdCounter_valueNext;
      timingCounters_tPpdCounter_value <= timingCounters_tPpdCounter_valueNext;
      timingCounters_tRfcCounter_value <= timingCounters_tRfcCounter_valueNext;
      timingCounters_tFawCounter_value <= timingCounters_tFawCounter_valueNext;
      timingCounters_tWrCounter_value <= timingCounters_tWrCounter_valueNext;
      if(when_CmdScheduler_l497) begin
        perfCounters_timingViolations <= (perfCounters_timingViolations + 16'h0001);
      end
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        fsm_1_idlePhase : begin
          fsm_phaseSubState <= 2'b00;
          if(when_CmdScheduler_l535) begin
            fsm_pendingCmd_isSerial <= io_initCmd_payload_isSerial;
            fsm_pendingCmd_opcode <= io_initCmd_payload_opcode;
            fsm_pendingCmd_bank <= io_initCmd_payload_bank;
            fsm_pendingCmd_rowAddr <= io_initCmd_payload_rowAddr;
            fsm_pendingCmd_colAddr <= io_initCmd_payload_colAddr;
            fsm_pendingCmd_burstCount <= io_initCmd_payload_burstCount;
            fsm_pendingCmd_writeMask <= io_initCmd_payload_writeMask;
            fsm_pendingCmd_odt <= io_initCmd_payload_odt;
            fsm_cmdSource <= 3'b000;
            fsm_phaseSubState <= 2'b01;
          end else begin
            if(when_CmdScheduler_l541) begin
              fsm_pendingCmd_isSerial <= io_refreshCmd_payload_isSerial;
              fsm_pendingCmd_opcode <= io_refreshCmd_payload_opcode;
              fsm_pendingCmd_bank <= io_refreshCmd_payload_bank;
              fsm_pendingCmd_rowAddr <= io_refreshCmd_payload_rowAddr;
              fsm_pendingCmd_colAddr <= io_refreshCmd_payload_colAddr;
              fsm_pendingCmd_burstCount <= io_refreshCmd_payload_burstCount;
              fsm_pendingCmd_writeMask <= io_refreshCmd_payload_writeMask;
              fsm_pendingCmd_odt <= io_refreshCmd_payload_odt;
              fsm_cmdSource <= 3'b001;
              fsm_phaseSubState <= 2'b01;
            end else begin
              if(when_CmdScheduler_l547) begin
                fsm_pendingCmd_isSerial <= io_powerCmd_payload_isSerial;
                fsm_pendingCmd_opcode <= io_powerCmd_payload_opcode;
                fsm_pendingCmd_bank <= io_powerCmd_payload_bank;
                fsm_pendingCmd_rowAddr <= io_powerCmd_payload_rowAddr;
                fsm_pendingCmd_colAddr <= io_powerCmd_payload_colAddr;
                fsm_pendingCmd_burstCount <= io_powerCmd_payload_burstCount;
                fsm_pendingCmd_writeMask <= io_powerCmd_payload_writeMask;
                fsm_pendingCmd_odt <= io_powerCmd_payload_odt;
                fsm_cmdSource <= 3'b010;
                fsm_phaseSubState <= 2'b01;
              end else begin
                if(when_CmdScheduler_l553) begin
                  if(addrDecodeArea_needsActivate) begin
                    fsm_pendingCmd_isSerial <= 1'b0;
                    fsm_pendingCmd_opcode <= 6'h01;
                    fsm_pendingCmd_bank <= addrDecodeArea_bank;
                    fsm_pendingCmd_rowAddr <= addrDecodeArea_rowAddr;
                    fsm_pendingCmd_colAddr <= 10'h0;
                    fsm_pendingCmd_burstCount <= 6'h0;
                    fsm_pendingCmd_writeMask <= 256'h0;
                    fsm_pendingCmd_odt <= 1'b0;
                  end else begin
                    fsm_pendingCmd_isSerial <= 1'b0;
                    fsm_pendingCmd_opcode <= (io_user_cmd_payload_isWrite ? 6'h03 : 6'h02);
                    fsm_pendingCmd_bank <= addrDecodeArea_bank;
                    fsm_pendingCmd_rowAddr <= 12'h0;
                    fsm_pendingCmd_colAddr <= addrDecodeArea_colAddr;
                    fsm_pendingCmd_burstCount <= io_user_cmd_payload_burstLen;
                    fsm_pendingCmd_writeMask <= io_user_cmd_payload_writeMask;
                    fsm_pendingCmd_odt <= io_user_cmd_payload_isWrite;
                  end
                  fsm_cmdSource <= 3'b011;
                  fsm_phaseSubState <= 2'b01;
                end
              end
            end
          end
        end
        fsm_1_commandPhase : begin
          case(fsm_phaseSubState)
            2'b01 : begin
              if(when_CmdScheduler_l422) begin
                cmdValidationArea_isLegal <= 1'b1;
                cmdValidationArea_burstCountValid <= (! (((cmdTracker_inBurst && fsm_pendingCmd_isSerial) && ((fsm_pendingCmd_opcode == _zz_cmdValidationArea_burstCountValid) || (fsm_pendingCmd_opcode == _zz_cmdValidationArea_burstCountValid_2))) && (cmdTracker_burstCount <= cmdTracker_serialCmdCount)));
                cmdValidationArea_lastValidatedCmd_isSerial <= fsm_pendingCmd_isSerial;
                cmdValidationArea_lastValidatedCmd_opcode <= fsm_pendingCmd_opcode;
                cmdValidationArea_lastValidatedCmd_bank <= fsm_pendingCmd_bank;
                cmdValidationArea_lastValidatedCmd_rowAddr <= fsm_pendingCmd_rowAddr;
                cmdValidationArea_lastValidatedCmd_colAddr <= fsm_pendingCmd_colAddr;
                cmdValidationArea_lastValidatedCmd_burstCount <= fsm_pendingCmd_burstCount;
                cmdValidationArea_lastValidatedCmd_writeMask <= fsm_pendingCmd_writeMask;
                cmdValidationArea_lastValidatedCmd_odt <= fsm_pendingCmd_odt;
                cmdValidationArea_validationDone <= 1'b1;
                fsm_phaseSubState <= 2'b10;
              end
            end
            2'b10 : begin
              if(when_CmdScheduler_l618) begin
                fsm_phaseSubState <= 2'b01;
              end else begin
                if(when_CmdScheduler_l621) begin
                  perfCounters_illegalTransitions <= (perfCounters_illegalTransitions + 16'h0001);
                  cmdValidationArea_validationDone <= 1'b0;
                  fsm_phaseSubState <= 2'b00;
                end else begin
                  if(when_CmdScheduler_l627) begin
                    perfCounters_burstLimitViolations <= (perfCounters_burstLimitViolations + 16'h0001);
                    cmdValidationArea_validationDone <= 1'b0;
                    fsm_phaseSubState <= 2'b00;
                  end else begin
                    if(when_CmdScheduler_l633) begin
                      cmdValidationArea_validationDone <= 1'b0;
                      fsm_phaseSubState <= 2'b00;
                    end else begin
                      cmdValidationArea_validationDone <= 1'b0;
                      fsm_phaseSubState <= 2'b11;
                    end
                  end
                end
              end
            end
            2'b11 : begin
              if(io_toPhy_ready) begin
                perfCounters_totalCommands <= (perfCounters_totalCommands + 32'h00000001);
                cmdTracker_lastCmd <= fsm_pendingCmd_opcode;
                cmdTracker_lastBank <= fsm_pendingCmd_bank;
                cmdTracker_isSerial <= fsm_pendingCmd_isSerial;
                if(when_CmdScheduler_l658) begin
                  cmdTracker_inBurst <= 1'b1;
                  cmdTracker_burstCount <= fsm_pendingCmd_burstCount;
                  cmdTracker_serialCmdCount <= 6'h0;
                end
                if(when_CmdScheduler_l665) begin
                  cmdTracker_serialCmdCount <= (cmdTracker_serialCmdCount + 6'h01);
                end
                if(when_CmdScheduler_l669) begin
                  cmdTracker_inBurst <= 1'b0;
                  cmdTracker_afterBurstStop <= 1'b1;
                end
                if(when_CmdScheduler_l675) begin
                  cmdTracker_afterToggle <= 1'b1;
                  cmdTracker_inBubbleNop <= 1'b1;
                  cmdTracker_bubbleNopCounter <= 7'h0;
                end
                if(when_CmdScheduler_l694) begin
                  timingCounters_activateHistory_3 <= timingCounters_activateHistory_2;
                  timingCounters_activateHistory_2 <= timingCounters_activateHistory_1;
                  timingCounters_activateHistory_1 <= timingCounters_activateHistory_0;
                  timingCounters_activateHistory_0 <= 1'b1;
                end
              end
            end
            default : begin
            end
          endcase
        end
        fsm_1_waitPhase : begin
          if(cmdTracker_inBurst) begin
            if(io_fromPhy_valid) begin
              cmdTracker_inBurst <= 1'b0;
            end
          end else begin
            if(cmdTracker_inBubbleNop) begin
              cmdTracker_bubbleNopCounter <= (cmdTracker_bubbleNopCounter + 7'h01);
              `ifndef SYNTHESIS
                `ifdef FORMAL
                  assert((cmdTracker_bubbleNopCounter <= 7'h50)); // CmdScheduler.scala:L747
                `else
                  if(!(cmdTracker_bubbleNopCounter <= 7'h50)) begin
                    $display("FAILURE Bubble NOP count exceeds 80 cycles (Note 9.1)"); // CmdScheduler.scala:L747
                    $finish;
                  end
                `endif
              `endif
              if(when_CmdScheduler_l752) begin
                cmdTracker_inBubbleNop <= 1'b0;
                cmdTracker_bubbleNopCounter <= 7'h0;
              end
            end else begin
              if(when_CmdScheduler_l769) begin
                cmdTracker_afterBurstStop <= 1'b0;
              end
            end
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @(posedge clk) begin
    timingCounters_currentTRcd_dup_0 <= io_currentTiming_tRcd;
    timingCounters_currentTRcd_dup_1 <= io_currentTiming_tRcd;
    timingCounters_currentTRcd_dup_2 <= io_currentTiming_tRcd;
    timingCounters_currentTRcd_dup_3 <= io_currentTiming_tRcd;
    timingCounters_currentTRp_dup_0 <= io_currentTiming_tRp;
    timingCounters_currentTRp_dup_1 <= io_currentTiming_tRp;
    timingCounters_currentTRp_dup_2 <= io_currentTiming_tRp;
    timingCounters_currentTRp_dup_3 <= io_currentTiming_tRp;
    timingCounters_currentTRas_dup_0 <= io_currentTiming_tRas;
    timingCounters_currentTRas_dup_1 <= io_currentTiming_tRas;
    timingCounters_currentTRas_dup_2 <= io_currentTiming_tRas;
    timingCounters_currentTRas_dup_3 <= io_currentTiming_tRas;
    timingCounters_currentTRrd <= io_currentTiming_tRrd;
    timingCounters_currentTPpd <= io_currentTiming_tPpd;
    timingCounters_currentTRfc <= io_currentTiming_tRfc;
    timingCounters_currentTFaw <= io_currentTiming_tFaw;
    timingCounters_currentTWr <= io_currentTiming_tWr;
    fsm_timingViolation_regNext <= fsm_timingViolation;
  end


endmodule

module InitSequencer (
  input  wire          io_start,
  input  wire [19:0]   io_timing_tCke,
  input  wire [19:0]   io_timing_tDpd,
  input  wire [7:0]    io_timing_tRcd,
  input  wire [7:0]    io_timing_tRp,
  input  wire [7:0]    io_timing_tWr,
  input  wire [7:0]    io_timing_tRas,
  input  wire [7:0]    io_timing_tRrd,
  input  wire [7:0]    io_timing_tPpd,
  input  wire [11:0]   io_timing_tZqInit,
  input  wire [7:0]    io_timing_tFaw,
  input  wire [7:0]    io_timing_tRfc,
  input  wire [7:0]    io_timing_tPhyWrLat,
  input  wire [7:0]    io_timing_tPhyRdLat,
  input  wire [7:0]    io_timing_tPhyWrData,
  input  wire [7:0]    io_timing_tRddataEn,
  output reg           io_cmdOut_valid,
  input  wire          io_cmdOut_ready,
  output reg           io_cmdOut_payload_isSerial,
  output reg  [5:0]    io_cmdOut_payload_opcode,
  output reg  [1:0]    io_cmdOut_payload_bank,
  output reg  [11:0]   io_cmdOut_payload_rowAddr,
  output reg  [9:0]    io_cmdOut_payload_colAddr,
  output reg  [5:0]    io_cmdOut_payload_burstCount,
  output reg  [255:0]  io_cmdOut_payload_writeMask,
  output reg           io_cmdOut_payload_odt,
  output reg           io_initDone,
  input  wire          clk,
  input  wire          reset
);
  localparam fsm_BOOT = 4'd0;
  localparam fsm_sIdle = 4'd1;
  localparam fsm_sWait200us = 4'd2;
  localparam fsm_sReset = 4'd3;
  localparam fsm_sSerialReset1 = 4'd4;
  localparam fsm_sSerialReset2 = 4'd5;
  localparam fsm_sPrecharge = 4'd6;
  localparam fsm_sMrs = 4'd7;
  localparam fsm_sZqInit = 4'd8;
  localparam fsm_sDone = 4'd9;

  wire       [17:0]   _zz_fsm_waitCounter_valueNext;
  wire       [0:0]    _zz_fsm_waitCounter_valueNext_1;
  wire       [11:0]   _zz_fsm_resetCounter_valueNext;
  wire       [0:0]    _zz_fsm_resetCounter_valueNext_1;
  wire       [11:0]   _zz_fsm_zqCounter_valueNext;
  wire       [0:0]    _zz_fsm_zqCounter_valueNext_1;
  wire       [4:0]    _zz_io_cmdOut_payload_opcode;
  wire       [4:0]    _zz_io_cmdOut_payload_opcode_1;
  wire       [11:0]   _zz_when_InitSequencer_l122;
  wire                fsm_wantExit;
  reg                 fsm_wantStart;
  wire                fsm_wantKill;
  reg                 fsm_waitCounter_willIncrement;
  reg                 fsm_waitCounter_willClear;
  reg        [17:0]   fsm_waitCounter_valueNext;
  reg        [17:0]   fsm_waitCounter_value;
  wire                fsm_waitCounter_willOverflowIfInc;
  wire                fsm_waitCounter_willOverflow;
  reg                 fsm_resetCounter_willIncrement;
  reg                 fsm_resetCounter_willClear;
  reg        [11:0]   fsm_resetCounter_valueNext;
  reg        [11:0]   fsm_resetCounter_value;
  wire                fsm_resetCounter_willOverflowIfInc;
  wire                fsm_resetCounter_willOverflow;
  reg                 fsm_zqCounter_willIncrement;
  reg                 fsm_zqCounter_willClear;
  reg        [11:0]   fsm_zqCounter_valueNext;
  reg        [11:0]   fsm_zqCounter_value;
  wire                fsm_zqCounter_willOverflowIfInc;
  wire                fsm_zqCounter_willOverflow;
  reg        [3:0]    fsm_stateReg;
  reg        [3:0]    fsm_stateNext;
  wire                when_InitSequencer_l61;
  reg                 _zz_when_InitSequencer_l111;
  wire                when_InitSequencer_l111;
  wire                when_InitSequencer_l122;
  wire                when_InitSequencer_l131;
  wire                fsm_onExit_BOOT;
  wire                fsm_onExit_sIdle;
  wire                fsm_onExit_sWait200us;
  wire                fsm_onExit_sReset;
  wire                fsm_onExit_sSerialReset1;
  wire                fsm_onExit_sSerialReset2;
  wire                fsm_onExit_sPrecharge;
  wire                fsm_onExit_sMrs;
  wire                fsm_onExit_sZqInit;
  wire                fsm_onExit_sDone;
  wire                fsm_onEntry_BOOT;
  wire                fsm_onEntry_sIdle;
  wire                fsm_onEntry_sWait200us;
  wire                fsm_onEntry_sReset;
  wire                fsm_onEntry_sSerialReset1;
  wire                fsm_onEntry_sSerialReset2;
  wire                fsm_onEntry_sPrecharge;
  wire                fsm_onEntry_sMrs;
  wire                fsm_onEntry_sZqInit;
  wire                fsm_onEntry_sDone;
  `ifndef SYNTHESIS
  reg [103:0] fsm_stateReg_string;
  reg [103:0] fsm_stateNext_string;
  `endif


  assign _zz_fsm_waitCounter_valueNext_1 = fsm_waitCounter_willIncrement;
  assign _zz_fsm_waitCounter_valueNext = {17'd0, _zz_fsm_waitCounter_valueNext_1};
  assign _zz_fsm_resetCounter_valueNext_1 = fsm_resetCounter_willIncrement;
  assign _zz_fsm_resetCounter_valueNext = {11'd0, _zz_fsm_resetCounter_valueNext_1};
  assign _zz_fsm_zqCounter_valueNext_1 = fsm_zqCounter_willIncrement;
  assign _zz_fsm_zqCounter_valueNext = {11'd0, _zz_fsm_zqCounter_valueNext_1};
  assign _zz_io_cmdOut_payload_opcode = 5'h0;
  assign _zz_io_cmdOut_payload_opcode_1 = 5'h0;
  assign _zz_when_InitSequencer_l122 = (io_timing_tZqInit - 12'h001);
  `ifndef SYNTHESIS
  always @(*) begin
    case(fsm_stateReg)
      fsm_BOOT : fsm_stateReg_string = "BOOT         ";
      fsm_sIdle : fsm_stateReg_string = "sIdle        ";
      fsm_sWait200us : fsm_stateReg_string = "sWait200us   ";
      fsm_sReset : fsm_stateReg_string = "sReset       ";
      fsm_sSerialReset1 : fsm_stateReg_string = "sSerialReset1";
      fsm_sSerialReset2 : fsm_stateReg_string = "sSerialReset2";
      fsm_sPrecharge : fsm_stateReg_string = "sPrecharge   ";
      fsm_sMrs : fsm_stateReg_string = "sMrs         ";
      fsm_sZqInit : fsm_stateReg_string = "sZqInit      ";
      fsm_sDone : fsm_stateReg_string = "sDone        ";
      default : fsm_stateReg_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(fsm_stateNext)
      fsm_BOOT : fsm_stateNext_string = "BOOT         ";
      fsm_sIdle : fsm_stateNext_string = "sIdle        ";
      fsm_sWait200us : fsm_stateNext_string = "sWait200us   ";
      fsm_sReset : fsm_stateNext_string = "sReset       ";
      fsm_sSerialReset1 : fsm_stateNext_string = "sSerialReset1";
      fsm_sSerialReset2 : fsm_stateNext_string = "sSerialReset2";
      fsm_sPrecharge : fsm_stateNext_string = "sPrecharge   ";
      fsm_sMrs : fsm_stateNext_string = "sMrs         ";
      fsm_sZqInit : fsm_stateNext_string = "sZqInit      ";
      fsm_sDone : fsm_stateNext_string = "sDone        ";
      default : fsm_stateNext_string = "?????????????";
    endcase
  end
  `endif

  assign fsm_wantExit = 1'b0;
  always @(*) begin
    fsm_wantStart = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
        fsm_wantStart = 1'b1;
      end
    endcase
  end

  assign fsm_wantKill = 1'b0;
  always @(*) begin
    fsm_waitCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
        fsm_waitCounter_willIncrement = 1'b1;
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_waitCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
        if(io_start) begin
          fsm_waitCounter_willClear = 1'b1;
        end
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_waitCounter_willOverflowIfInc = (fsm_waitCounter_value == 18'h270ff);
  assign fsm_waitCounter_willOverflow = (fsm_waitCounter_willOverflowIfInc && fsm_waitCounter_willIncrement);
  always @(*) begin
    if(fsm_waitCounter_willOverflow) begin
      fsm_waitCounter_valueNext = 18'h0;
    end else begin
      fsm_waitCounter_valueNext = (fsm_waitCounter_value + _zz_fsm_waitCounter_valueNext);
    end
    if(fsm_waitCounter_willClear) begin
      fsm_waitCounter_valueNext = 18'h0;
    end
  end

  always @(*) begin
    fsm_resetCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        fsm_resetCounter_willIncrement = 1'b1;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_resetCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
        if(fsm_waitCounter_willOverflow) begin
          fsm_resetCounter_willClear = 1'b1;
        end
      end
      fsm_sReset : begin
        if(when_InitSequencer_l61) begin
          fsm_resetCounter_willClear = 1'b1;
        end
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_resetCounter_willOverflowIfInc = (fsm_resetCounter_value == 12'hf9f);
  assign fsm_resetCounter_willOverflow = (fsm_resetCounter_willOverflowIfInc && fsm_resetCounter_willIncrement);
  always @(*) begin
    if(fsm_resetCounter_willOverflow) begin
      fsm_resetCounter_valueNext = 12'h0;
    end else begin
      fsm_resetCounter_valueNext = (fsm_resetCounter_value + _zz_fsm_resetCounter_valueNext);
    end
    if(fsm_resetCounter_willClear) begin
      fsm_resetCounter_valueNext = 12'h0;
    end
  end

  always @(*) begin
    fsm_zqCounter_willIncrement = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
        if(!when_InitSequencer_l111) begin
          fsm_zqCounter_willIncrement = 1'b1;
        end
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_zqCounter_willClear = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
        if(io_cmdOut_ready) begin
          fsm_zqCounter_willClear = 1'b1;
        end
      end
      fsm_sZqInit : begin
        if(when_InitSequencer_l111) begin
          if(io_cmdOut_ready) begin
            fsm_zqCounter_willClear = 1'b1;
          end
        end
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  assign fsm_zqCounter_willOverflowIfInc = (fsm_zqCounter_value == 12'hfff);
  assign fsm_zqCounter_willOverflow = (fsm_zqCounter_willOverflowIfInc && fsm_zqCounter_willIncrement);
  always @(*) begin
    fsm_zqCounter_valueNext = (fsm_zqCounter_value + _zz_fsm_zqCounter_valueNext);
    if(fsm_zqCounter_willClear) begin
      fsm_zqCounter_valueNext = 12'h0;
    end
  end

  always @(*) begin
    io_cmdOut_valid = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_sSerialReset1 : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_sSerialReset2 : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_sPrecharge : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_sMrs : begin
        io_cmdOut_valid = 1'b1;
      end
      fsm_sZqInit : begin
        if(when_InitSequencer_l111) begin
          io_cmdOut_valid = 1'b1;
        end else begin
          io_cmdOut_valid = 1'b0;
        end
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_isSerial = 1'bx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_isSerial = 1'b0;
      end
      fsm_sSerialReset1 : begin
        io_cmdOut_payload_isSerial = 1'b1;
      end
      fsm_sSerialReset2 : begin
        io_cmdOut_payload_isSerial = 1'b1;
      end
      fsm_sPrecharge : begin
        io_cmdOut_payload_isSerial = 1'b0;
      end
      fsm_sMrs : begin
        io_cmdOut_payload_isSerial = 1'b0;
      end
      fsm_sZqInit : begin
        if(when_InitSequencer_l111) begin
          io_cmdOut_payload_isSerial = 1'b0;
        end
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_opcode = 6'bxxxxxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_opcode = 6'h0f;
      end
      fsm_sSerialReset1 : begin
        io_cmdOut_payload_opcode = {1'd0, _zz_io_cmdOut_payload_opcode};
      end
      fsm_sSerialReset2 : begin
        io_cmdOut_payload_opcode = {1'd0, _zz_io_cmdOut_payload_opcode_1};
      end
      fsm_sPrecharge : begin
        io_cmdOut_payload_opcode = 6'h05;
      end
      fsm_sMrs : begin
        io_cmdOut_payload_opcode = 6'h08;
      end
      fsm_sZqInit : begin
        if(when_InitSequencer_l111) begin
          io_cmdOut_payload_opcode = 6'h09;
        end
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_bank = 2'bxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_bank = 2'b00;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_rowAddr = 12'bxxxxxxxxxxxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_rowAddr = 12'h0;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
        io_cmdOut_payload_rowAddr = 12'h080;
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_colAddr = 10'bxxxxxxxxxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_colAddr = 10'h0;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_burstCount = 6'bxxxxxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_burstCount = 6'h0;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_writeMask = 256'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_writeMask = 256'h0;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_cmdOut_payload_odt = 1'bx;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
        io_cmdOut_payload_odt = 1'b0;
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
        io_cmdOut_payload_odt = 1'b1;
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    io_initDone = 1'b0;
    case(fsm_stateReg)
      fsm_sIdle : begin
      end
      fsm_sWait200us : begin
      end
      fsm_sReset : begin
      end
      fsm_sSerialReset1 : begin
      end
      fsm_sSerialReset2 : begin
      end
      fsm_sPrecharge : begin
      end
      fsm_sMrs : begin
      end
      fsm_sZqInit : begin
      end
      fsm_sDone : begin
        io_initDone = 1'b1;
      end
      default : begin
      end
    endcase
  end

  always @(*) begin
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      fsm_sIdle : begin
        if(io_start) begin
          fsm_stateNext = fsm_sWait200us;
        end
      end
      fsm_sWait200us : begin
        if(fsm_waitCounter_willOverflow) begin
          fsm_stateNext = fsm_sReset;
        end
      end
      fsm_sReset : begin
        if(when_InitSequencer_l61) begin
          fsm_stateNext = fsm_sSerialReset1;
        end
      end
      fsm_sSerialReset1 : begin
        if(io_cmdOut_ready) begin
          fsm_stateNext = fsm_sSerialReset2;
        end
      end
      fsm_sSerialReset2 : begin
        if(io_cmdOut_ready) begin
          fsm_stateNext = fsm_sPrecharge;
        end
      end
      fsm_sPrecharge : begin
        if(io_cmdOut_ready) begin
          fsm_stateNext = fsm_sMrs;
        end
      end
      fsm_sMrs : begin
        if(io_cmdOut_ready) begin
          fsm_stateNext = fsm_sZqInit;
        end
      end
      fsm_sZqInit : begin
        if(!when_InitSequencer_l111) begin
          if(when_InitSequencer_l122) begin
            fsm_stateNext = fsm_sDone;
          end
        end
      end
      fsm_sDone : begin
        if(when_InitSequencer_l131) begin
          fsm_stateNext = fsm_sIdle;
        end
      end
      default : begin
      end
    endcase
    if(fsm_wantStart) begin
      fsm_stateNext = fsm_sIdle;
    end
    if(fsm_wantKill) begin
      fsm_stateNext = fsm_BOOT;
    end
  end

  assign when_InitSequencer_l61 = (io_cmdOut_ready && fsm_resetCounter_willOverflow);
  assign when_InitSequencer_l111 = (! _zz_when_InitSequencer_l111);
  assign when_InitSequencer_l122 = (fsm_zqCounter_value == _zz_when_InitSequencer_l122);
  assign when_InitSequencer_l131 = (! io_start);
  assign fsm_onExit_BOOT = ((fsm_stateNext != fsm_BOOT) && (fsm_stateReg == fsm_BOOT));
  assign fsm_onExit_sIdle = ((fsm_stateNext != fsm_sIdle) && (fsm_stateReg == fsm_sIdle));
  assign fsm_onExit_sWait200us = ((fsm_stateNext != fsm_sWait200us) && (fsm_stateReg == fsm_sWait200us));
  assign fsm_onExit_sReset = ((fsm_stateNext != fsm_sReset) && (fsm_stateReg == fsm_sReset));
  assign fsm_onExit_sSerialReset1 = ((fsm_stateNext != fsm_sSerialReset1) && (fsm_stateReg == fsm_sSerialReset1));
  assign fsm_onExit_sSerialReset2 = ((fsm_stateNext != fsm_sSerialReset2) && (fsm_stateReg == fsm_sSerialReset2));
  assign fsm_onExit_sPrecharge = ((fsm_stateNext != fsm_sPrecharge) && (fsm_stateReg == fsm_sPrecharge));
  assign fsm_onExit_sMrs = ((fsm_stateNext != fsm_sMrs) && (fsm_stateReg == fsm_sMrs));
  assign fsm_onExit_sZqInit = ((fsm_stateNext != fsm_sZqInit) && (fsm_stateReg == fsm_sZqInit));
  assign fsm_onExit_sDone = ((fsm_stateNext != fsm_sDone) && (fsm_stateReg == fsm_sDone));
  assign fsm_onEntry_BOOT = ((fsm_stateNext == fsm_BOOT) && (fsm_stateReg != fsm_BOOT));
  assign fsm_onEntry_sIdle = ((fsm_stateNext == fsm_sIdle) && (fsm_stateReg != fsm_sIdle));
  assign fsm_onEntry_sWait200us = ((fsm_stateNext == fsm_sWait200us) && (fsm_stateReg != fsm_sWait200us));
  assign fsm_onEntry_sReset = ((fsm_stateNext == fsm_sReset) && (fsm_stateReg != fsm_sReset));
  assign fsm_onEntry_sSerialReset1 = ((fsm_stateNext == fsm_sSerialReset1) && (fsm_stateReg != fsm_sSerialReset1));
  assign fsm_onEntry_sSerialReset2 = ((fsm_stateNext == fsm_sSerialReset2) && (fsm_stateReg != fsm_sSerialReset2));
  assign fsm_onEntry_sPrecharge = ((fsm_stateNext == fsm_sPrecharge) && (fsm_stateReg != fsm_sPrecharge));
  assign fsm_onEntry_sMrs = ((fsm_stateNext == fsm_sMrs) && (fsm_stateReg != fsm_sMrs));
  assign fsm_onEntry_sZqInit = ((fsm_stateNext == fsm_sZqInit) && (fsm_stateReg != fsm_sZqInit));
  assign fsm_onEntry_sDone = ((fsm_stateNext == fsm_sDone) && (fsm_stateReg != fsm_sDone));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      fsm_waitCounter_value <= 18'h0;
      fsm_resetCounter_value <= 12'h0;
      fsm_zqCounter_value <= 12'h0;
      fsm_stateReg <= fsm_BOOT;
    end else begin
      fsm_waitCounter_value <= fsm_waitCounter_valueNext;
      fsm_resetCounter_value <= fsm_resetCounter_valueNext;
      fsm_zqCounter_value <= fsm_zqCounter_valueNext;
      fsm_stateReg <= fsm_stateNext;
    end
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      _zz_when_InitSequencer_l111 <= 1'b0;
    end else begin
      if(when_InitSequencer_l111) begin
        if(io_cmdOut_ready) begin
          _zz_when_InitSequencer_l111 <= 1'b1;
        end
      end else begin
        if(when_InitSequencer_l122) begin
          _zz_when_InitSequencer_l111 <= 1'b0;
        end
      end
    end
  end


endmodule

module BankTracker (
  input  wire          io_cmd_activate_valid,
  output wire          io_cmd_activate_ready,
  input  wire [1:0]    io_cmd_activate_payload_bank,
  input  wire [11:0]   io_cmd_activate_payload_rowAddr,
  input  wire          io_cmd_precharge_valid,
  output wire          io_cmd_precharge_ready,
  input  wire [1:0]    io_cmd_precharge_payload,
  output wire [1:0]    io_status_bankStates_0,
  output wire [1:0]    io_status_bankStates_1,
  output wire [1:0]    io_status_bankStates_2,
  output wire [1:0]    io_status_bankStates_3,
  output wire [11:0]   io_status_openRow_0,
  output wire [11:0]   io_status_openRow_1,
  output wire [11:0]   io_status_openRow_2,
  output wire [11:0]   io_status_openRow_3,
  input  wire          clk,
  input  wire          reset
);
  localparam BankState_IDLE = 2'd0;
  localparam BankState_ACTIVATING = 2'd1;
  localparam BankState_ACTIVE = 2'd2;
  localparam BankState_PRECHARGING = 2'd3;

  reg        [1:0]    states_0;
  reg        [1:0]    states_1;
  reg        [1:0]    states_2;
  reg        [1:0]    states_3;
  reg        [11:0]   openRows_0;
  reg        [11:0]   openRows_1;
  reg        [11:0]   openRows_2;
  reg        [11:0]   openRows_3;
  wire                io_cmd_activate_fire;
  wire       [3:0]    _zz_1;
  wire       [3:0]    _zz_2;
  wire                io_cmd_precharge_fire;
  wire       [3:0]    _zz_3;
  wire       [3:0]    _zz_4;
  `ifndef SYNTHESIS
  reg [87:0] io_status_bankStates_0_string;
  reg [87:0] io_status_bankStates_1_string;
  reg [87:0] io_status_bankStates_2_string;
  reg [87:0] io_status_bankStates_3_string;
  reg [87:0] states_0_string;
  reg [87:0] states_1_string;
  reg [87:0] states_2_string;
  reg [87:0] states_3_string;
  `endif


  `ifndef SYNTHESIS
  always @(*) begin
    case(io_status_bankStates_0)
      BankState_IDLE : io_status_bankStates_0_string = "IDLE       ";
      BankState_ACTIVATING : io_status_bankStates_0_string = "ACTIVATING ";
      BankState_ACTIVE : io_status_bankStates_0_string = "ACTIVE     ";
      BankState_PRECHARGING : io_status_bankStates_0_string = "PRECHARGING";
      default : io_status_bankStates_0_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_status_bankStates_1)
      BankState_IDLE : io_status_bankStates_1_string = "IDLE       ";
      BankState_ACTIVATING : io_status_bankStates_1_string = "ACTIVATING ";
      BankState_ACTIVE : io_status_bankStates_1_string = "ACTIVE     ";
      BankState_PRECHARGING : io_status_bankStates_1_string = "PRECHARGING";
      default : io_status_bankStates_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_status_bankStates_2)
      BankState_IDLE : io_status_bankStates_2_string = "IDLE       ";
      BankState_ACTIVATING : io_status_bankStates_2_string = "ACTIVATING ";
      BankState_ACTIVE : io_status_bankStates_2_string = "ACTIVE     ";
      BankState_PRECHARGING : io_status_bankStates_2_string = "PRECHARGING";
      default : io_status_bankStates_2_string = "???????????";
    endcase
  end
  always @(*) begin
    case(io_status_bankStates_3)
      BankState_IDLE : io_status_bankStates_3_string = "IDLE       ";
      BankState_ACTIVATING : io_status_bankStates_3_string = "ACTIVATING ";
      BankState_ACTIVE : io_status_bankStates_3_string = "ACTIVE     ";
      BankState_PRECHARGING : io_status_bankStates_3_string = "PRECHARGING";
      default : io_status_bankStates_3_string = "???????????";
    endcase
  end
  always @(*) begin
    case(states_0)
      BankState_IDLE : states_0_string = "IDLE       ";
      BankState_ACTIVATING : states_0_string = "ACTIVATING ";
      BankState_ACTIVE : states_0_string = "ACTIVE     ";
      BankState_PRECHARGING : states_0_string = "PRECHARGING";
      default : states_0_string = "???????????";
    endcase
  end
  always @(*) begin
    case(states_1)
      BankState_IDLE : states_1_string = "IDLE       ";
      BankState_ACTIVATING : states_1_string = "ACTIVATING ";
      BankState_ACTIVE : states_1_string = "ACTIVE     ";
      BankState_PRECHARGING : states_1_string = "PRECHARGING";
      default : states_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(states_2)
      BankState_IDLE : states_2_string = "IDLE       ";
      BankState_ACTIVATING : states_2_string = "ACTIVATING ";
      BankState_ACTIVE : states_2_string = "ACTIVE     ";
      BankState_PRECHARGING : states_2_string = "PRECHARGING";
      default : states_2_string = "???????????";
    endcase
  end
  always @(*) begin
    case(states_3)
      BankState_IDLE : states_3_string = "IDLE       ";
      BankState_ACTIVATING : states_3_string = "ACTIVATING ";
      BankState_ACTIVE : states_3_string = "ACTIVE     ";
      BankState_PRECHARGING : states_3_string = "PRECHARGING";
      default : states_3_string = "???????????";
    endcase
  end
  `endif

  assign io_cmd_activate_ready = 1'b1;
  assign io_cmd_precharge_ready = 1'b1;
  assign io_cmd_activate_fire = (io_cmd_activate_valid && io_cmd_activate_ready);
  assign _zz_1 = ({3'd0,1'b1} <<< io_cmd_activate_payload_bank);
  assign _zz_2 = ({3'd0,1'b1} <<< io_cmd_activate_payload_bank);
  assign io_cmd_precharge_fire = (io_cmd_precharge_valid && io_cmd_precharge_ready);
  assign _zz_3 = ({3'd0,1'b1} <<< io_cmd_precharge_payload);
  assign _zz_4 = ({3'd0,1'b1} <<< io_cmd_precharge_payload);
  assign io_status_bankStates_0 = states_0;
  assign io_status_bankStates_1 = states_1;
  assign io_status_bankStates_2 = states_2;
  assign io_status_bankStates_3 = states_3;
  assign io_status_openRow_0 = openRows_0;
  assign io_status_openRow_1 = openRows_1;
  assign io_status_openRow_2 = openRows_2;
  assign io_status_openRow_3 = openRows_3;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      states_0 <= BankState_IDLE;
      states_1 <= BankState_IDLE;
      states_2 <= BankState_IDLE;
      states_3 <= BankState_IDLE;
      openRows_0 <= 12'h0;
      openRows_1 <= 12'h0;
      openRows_2 <= 12'h0;
      openRows_3 <= 12'h0;
    end else begin
      if(io_cmd_activate_fire) begin
        if(_zz_1[0]) begin
          states_0 <= BankState_ACTIVE;
        end
        if(_zz_1[1]) begin
          states_1 <= BankState_ACTIVE;
        end
        if(_zz_1[2]) begin
          states_2 <= BankState_ACTIVE;
        end
        if(_zz_1[3]) begin
          states_3 <= BankState_ACTIVE;
        end
        if(_zz_2[0]) begin
          openRows_0 <= io_cmd_activate_payload_rowAddr;
        end
        if(_zz_2[1]) begin
          openRows_1 <= io_cmd_activate_payload_rowAddr;
        end
        if(_zz_2[2]) begin
          openRows_2 <= io_cmd_activate_payload_rowAddr;
        end
        if(_zz_2[3]) begin
          openRows_3 <= io_cmd_activate_payload_rowAddr;
        end
      end
      if(io_cmd_precharge_fire) begin
        if(_zz_3[0]) begin
          states_0 <= BankState_IDLE;
        end
        if(_zz_3[1]) begin
          states_1 <= BankState_IDLE;
        end
        if(_zz_3[2]) begin
          states_2 <= BankState_IDLE;
        end
        if(_zz_3[3]) begin
          states_3 <= BankState_IDLE;
        end
        if(_zz_4[0]) begin
          openRows_0 <= 12'h0;
        end
        if(_zz_4[1]) begin
          openRows_1 <= 12'h0;
        end
        if(_zz_4[2]) begin
          openRows_2 <= 12'h0;
        end
        if(_zz_4[3]) begin
          openRows_3 <= 12'h0;
        end
      end
    end
  end


endmodule

module TimingRegs (
  input  wire          io_update_valid,
  input  wire [19:0]   io_update_payload_tCke,
  input  wire [19:0]   io_update_payload_tDpd,
  input  wire [7:0]    io_update_payload_tRcd,
  input  wire [7:0]    io_update_payload_tRp,
  input  wire [7:0]    io_update_payload_tWr,
  input  wire [7:0]    io_update_payload_tRas,
  input  wire [7:0]    io_update_payload_tRrd,
  input  wire [7:0]    io_update_payload_tPpd,
  input  wire [11:0]   io_update_payload_tZqInit,
  input  wire [7:0]    io_update_payload_tFaw,
  input  wire [7:0]    io_update_payload_tRfc,
  input  wire [7:0]    io_update_payload_tPhyWrLat,
  input  wire [7:0]    io_update_payload_tPhyRdLat,
  input  wire [7:0]    io_update_payload_tPhyWrData,
  input  wire [7:0]    io_update_payload_tRddataEn,
  output wire [19:0]   io_current_tCke,
  output wire [19:0]   io_current_tDpd,
  output wire [7:0]    io_current_tRcd,
  output wire [7:0]    io_current_tRp,
  output wire [7:0]    io_current_tWr,
  output wire [7:0]    io_current_tRas,
  output wire [7:0]    io_current_tRrd,
  output wire [7:0]    io_current_tPpd,
  output wire [11:0]   io_current_tZqInit,
  output wire [7:0]    io_current_tFaw,
  output wire [7:0]    io_current_tRfc,
  output wire [7:0]    io_current_tPhyWrLat,
  output wire [7:0]    io_current_tPhyRdLat,
  output wire [7:0]    io_current_tPhyWrData,
  output wire [7:0]    io_current_tRddataEn,
  input  wire          clk,
  input  wire          reset
);

  reg        [19:0]   regs_tCke;
  reg        [19:0]   regs_tDpd;
  reg        [7:0]    regs_tRcd;
  reg        [7:0]    regs_tRp;
  reg        [7:0]    regs_tWr;
  reg        [7:0]    regs_tRas;
  reg        [7:0]    regs_tRrd;
  reg        [7:0]    regs_tPpd;
  reg        [11:0]   regs_tZqInit;
  reg        [7:0]    regs_tFaw;
  reg        [7:0]    regs_tRfc;
  reg        [7:0]    regs_tPhyWrLat;
  reg        [7:0]    regs_tPhyRdLat;
  reg        [7:0]    regs_tPhyWrData;
  reg        [7:0]    regs_tRddataEn;

  assign io_current_tCke = regs_tCke;
  assign io_current_tDpd = regs_tDpd;
  assign io_current_tRcd = regs_tRcd;
  assign io_current_tRp = regs_tRp;
  assign io_current_tWr = regs_tWr;
  assign io_current_tRas = regs_tRas;
  assign io_current_tRrd = regs_tRrd;
  assign io_current_tPpd = regs_tPpd;
  assign io_current_tZqInit = regs_tZqInit;
  assign io_current_tFaw = regs_tFaw;
  assign io_current_tRfc = regs_tRfc;
  assign io_current_tPhyWrLat = regs_tPhyWrLat;
  assign io_current_tPhyRdLat = regs_tPhyRdLat;
  assign io_current_tPhyWrData = regs_tPhyWrData;
  assign io_current_tRddataEn = regs_tRddataEn;
  always @(posedge clk) begin
    regs_tCke <= 20'h00003;
    regs_tDpd <= 20'h61a80;
    regs_tRcd <= 8'h0c;
    regs_tRp <= 8'h0c;
    regs_tWr <= 8'h0c;
    regs_tRas <= 8'h1e;
    regs_tRrd <= 8'h06;
    regs_tPpd <= 8'h08;
    regs_tZqInit <= 12'h640;
    regs_tFaw <= 8'h18;
    regs_tRfc <= 8'h58;
    regs_tPhyWrLat <= 8'h02;
    regs_tPhyRdLat <= 8'h05;
    regs_tPhyWrData <= 8'h01;
    regs_tRddataEn <= 8'h03;
    if(io_update_valid) begin
      regs_tCke <= io_update_payload_tCke;
      regs_tDpd <= io_update_payload_tDpd;
      regs_tRcd <= io_update_payload_tRcd;
      regs_tRp <= io_update_payload_tRp;
      regs_tWr <= io_update_payload_tWr;
      regs_tRas <= io_update_payload_tRas;
      regs_tRrd <= io_update_payload_tRrd;
      regs_tPpd <= io_update_payload_tPpd;
      regs_tZqInit <= io_update_payload_tZqInit;
      regs_tFaw <= io_update_payload_tFaw;
      regs_tRfc <= io_update_payload_tRfc;
      regs_tPhyWrLat <= io_update_payload_tPhyWrLat;
      regs_tPhyRdLat <= io_update_payload_tPhyRdLat;
      regs_tPhyWrData <= io_update_payload_tPhyWrData;
      regs_tRddataEn <= io_update_payload_tRddataEn;
    end
  end


endmodule

module BufferCC_1 (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          clk,
  input  wire          reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(negedge clk or posedge reset) begin
    if(reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule

module BufferCC (
  input  wire          io_dataIn,
  output wire          io_dataOut,
  input  wire          clk,
  input  wire          reset
);

  (* async_reg = "true" *) reg                 buffers_0;
  (* async_reg = "true" *) reg                 buffers_1;

  assign io_dataOut = buffers_1;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      buffers_0 <= 1'b1;
      buffers_1 <= 1'b1;
    end else begin
      buffers_0 <= io_dataIn;
      buffers_1 <= buffers_0;
    end
  end


endmodule
