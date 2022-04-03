/*
 *  IOb-VexRiscv -- A VexRiscv Wrapper
 */


`timescale 1 ns / 1 ps
`include "system.vh"
`include "iob_intercon.vh"

//the look ahead interface is not working because mem_instr is unknown at request
//`define LA_IF

module iob_VexRiscv
  #(
    parameter ADDR_W=32,
    parameter DATA_W=32
    )
   (
    input               clk,
    input               rst,
    input               boot,
    output              trap,

    // instruction bus
    output [`REQ_W-1:0] ibus_req,
    input [`RESP_W-1:0] ibus_resp,

    // data bus
    output [`REQ_W-1:0] dbus_req,
    input [`RESP_W-1:0] dbus_resp
    );


    // INSTRUCTIONS BUS
    wire                  ibus_req_valid;
    wire              ibus_req_valid_int;
    wire                  ibus_req_ready;
    wire [`ADDR_W-1:0]  ibus_req_address;
    wire [`ADDR_W-1:0] ibus_req_addr_int;
    wire                 ibus_resp_ready;
    wire [`DATA_W-1:0]    ibus_resp_data;

    reg               ibus_req_valid_reg;
    reg  [`ADDR_W-1:0] ibus_req_addr_reg;

//modify addresses if DDR used according to boot status
`ifdef RUN_EXTMEM_USE_SRAM
    assign ibus_req = {ibus_req_valid_int, ~boot, ibus_req_addr_int[`ADDR_W-2:0], `DATA_W'h0, {`DATA_W/8{1'b0}}};
`else
    assign ibus_req = {ibus_req_valid_int, ibus_req_addr_int, `DATA_W'h0, {`DATA_W/8{1'b0}}};
`endif
    assign ibus_req_ready = (ibus_req_valid_reg&ibus_resp_ready)|(~ibus_req_valid_reg);
    assign ibus_req_valid_int = (ibus_req_ready|ibus_resp_ready)? ibus_req_valid : ibus_req_valid_reg;
    assign ibus_req_addr_int = (ibus_req_ready|ibus_resp_ready) ? ibus_req_address : ibus_req_addr_reg;
    assign ibus_resp_ready = ibus_resp[`ready(0)];
    assign ibus_resp_data = ibus_resp[`rdata(0)];

    // INSTRUCTIONS REGISTERS
    //compute if valid
    always  @(posedge clk, posedge rst)
      if(rst)
        ibus_req_valid_reg <= 1'b0;
      else if(ibus_req_ready|ibus_resp_ready)
        ibus_req_valid_reg <= ibus_req_valid;
    //compute address for interface
    always @(posedge clk, posedge rst)
      if(rst)
        ibus_req_addr_reg <= 1'b0;
      else if(ibus_req_ready|ibus_resp_ready)
        ibus_req_addr_reg <= ibus_req_address;


    // DATA BUS
    wire                    dbus_req_valid;
    wire                    dbus_req_ready;
    wire                dbus_req_valid_int;
    wire                       dbus_req_wr;
    wire [1:0]               dbus_req_size;
    wire [`ADDR_W-1:0]    dbus_req_address;
    wire [`ADDR_W-1:0]   dbus_req_addr_int;
    wire [`DATA_W-1:0]       dbus_req_data;
    wire [`DATA_W-1:0]   dbus_req_data_int;
    wire [`DATA_W/8-1:0]     dbus_req_strb;
    wire [`DATA_W/8-1:0] dbus_req_strb_int;
    wire [`DATA_W/8-1:0]     dbus_req_mask;
    wire [`DATA_W/8-1:0]    dbus_req_mask2;
    wire                   dbus_resp_ready;
    wire [`DATA_W-1:0]      dbus_resp_data;

    reg                 dbus_req_valid_reg;
    reg  [`ADDR_W-1:0]   dbus_req_addr_reg;
    reg  [`DATA_W-1:0]   dbus_req_data_reg;
    reg  [`DATA_W/8-1:0] dbus_req_strb_reg;

//modify addresses if DDR used according to boot status
`ifdef RUN_EXTMEM_USE_SRAM
    assign dbus_req = {dbus_req_valid_int, (dbus_req_addr_int[`E]^~boot)&~dbus_req_addr_int[`P], dbus_req_addr_int[ADDR_W-2:0], dbus_req_data_int, dbus_req_strb_int};
`else
    assign dbus_req = {dbus_req_valid_int, dbus_req_addr_int, dbus_req_data_int, dbus_req_strb_int};
`endif
    assign dbus_req_ready = (dbus_req_valid_reg&dbus_resp_ready)|(~dbus_req_valid_reg);
    assign dbus_req_valid_int = (dbus_req_ready|dbus_resp_ready)? dbus_req_valid : dbus_req_valid_reg;
    assign dbus_req_addr_int = (dbus_req_ready|dbus_resp_ready) ? dbus_req_address : dbus_req_addr_reg;
    assign dbus_req_data_int = (dbus_req_ready|dbus_resp_ready) ? dbus_req_data : dbus_req_data_reg;
    assign dbus_req_strb_int = (dbus_req_ready|dbus_resp_ready) ? dbus_req_strb : dbus_req_strb_reg;
    assign dbus_req_strb = dbus_req_wr ? dbus_req_mask : 4'h0;
    assign dbus_req_mask = dbus_req_mask2 << dbus_req_address[1:0];
    assign dbus_req_mask2 = dbus_req_size[1] ? {4'hF} : (dbus_req_size[0] ? {4'h3} : {4'h1});
    assign dbus_resp_ready = dbus_resp[`ready(0)];
    assign dbus_resp_data = dbus_resp[`rdata(0)];

    // DATA REGISTERS
    //compute if ready
    always  @(posedge clk, posedge rst)
      if(rst)
        dbus_req_valid_reg <= 1'b0;
      else if(dbus_req_ready|dbus_resp_ready)
        dbus_req_valid_reg <= dbus_req_valid;
    //compute address for interface
    always @(posedge clk, posedge rst)
      if(rst)
        dbus_req_addr_reg <= 1'b0;
      else if (dbus_req_ready|dbus_resp_ready)
        dbus_req_addr_reg <= dbus_req_address;
    //compute write data for interface
    always @(posedge clk, posedge rst)
      if(rst)
        dbus_req_data_reg <= 1'b0;
      else if (dbus_req_ready|dbus_resp_ready)
        dbus_req_data_reg <= dbus_req_data_int;
    //compute write strb for interface
    always @(posedge clk, posedge rst)
      if(rst)
        dbus_req_strb_reg <= 1'b0;
      else if(dbus_req_ready|dbus_resp_ready)
        dbus_req_strb_reg <= dbus_req_strb;


    // DEBUG BUS
    wire                     debug_valid;
    wire                     debug_ready;
    wire                        debug_wr;
    wire [`ADDR_W/4-1:0]    debug_address;
    wire [`DATA_W-1:0]         debug_data;
    wire [`DATA_W-1:0]    debug_data_resp;
    wire                  debug_resetOut;

    assign debug_valid = 1'b0;
    assign debug_wr = 1'b0;
    assign debug_address = 8'h0;
    assign debug_data = 32'h0;

    //assign trap = (ibus_req_address==32'h08000020);

   // VexRiscv instantiation
   VexRiscv VexRiscv_core(
     .iBus_cmd_valid                (ibus_req_valid),
     .iBus_cmd_ready                (ibus_req_ready),
     .iBus_cmd_payload_pc           (ibus_req_address),
     .iBus_rsp_valid                (ibus_resp_ready),
     .iBus_rsp_payload_error        (1'b0),
     .iBus_rsp_payload_inst         (ibus_resp_data),
     .timerInterrupt                (1'b0),
     .externalInterrupt             (1'b0),
     .softwareInterrupt             (1'b0),
     .externalInterruptS            (1'b0),
     .debug_bus_cmd_valid           (debug_valid),
     .debug_bus_cmd_ready           (debug_ready),
     .debug_bus_cmd_payload_wr      (debug_wr),
     .debug_bus_cmd_payload_address (debug_address),
     .debug_bus_cmd_payload_data    (debug_data),
     .debug_bus_rsp_data            (debug_data_resp),
     .debug_resetOut                (debug_resetOut),
     .dBus_cmd_valid                (dbus_req_valid),
     .dBus_cmd_ready                (dbus_req_ready),
     .dBus_cmd_payload_wr           (dbus_req_wr),
     .dBus_cmd_payload_address      (dbus_req_address),
     .dBus_cmd_payload_data         (dbus_req_data),
     .dBus_cmd_payload_size         (dbus_req_size),
     .dBus_rsp_ready                (dbus_resp_ready),
     .dBus_rsp_error                (1'b0),
     .dBus_rsp_data                 (dbus_resp_data),
     .clk                           (clk),
     .reset                         (rst),
     .debugReset                    (1'b0)
     );

endmodule
