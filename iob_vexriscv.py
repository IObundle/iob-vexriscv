def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_vexriscv",
        "name": "iob_vexriscv",
        "version": "0.1",
        "confs": [
            {
                "name": "ADDR_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "DATA_W",
                "type": "P",
                "val": "32",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "E_BIT",
                "type": "P",
                "val": "67",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "P_BIT",
                "type": "P",
                "val": "66",
                "min": "1",
                "max": "?",
                "descr": "description here",
            },
            {
                "name": "USE_EXTMEM",
                "type": "P",
                "val": "0",
                "min": "0",
                "max": "1",
                "descr": "Select if configured for usage with external memory.",
            },
            {
                "name": "AXI_ID_W",
                "descr": "AXI ID bus width",
                "type": "P",
                "val": 0,
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_ADDR_W",
                "descr": "AXI address bus width",
                "type": "P",
                "val": 0,
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_DATA_W",
                "descr": "AXI data bus width",
                "type": "P",
                "val": 0,
                "min": "1",
                "max": "32",
            },
            {
                "name": "AXI_LEN_W",
                "descr": "AXI burst length width",
                "type": "P",
                "val": 0,
                "min": "1",
                "max": "4",
            },
        ],
        "ports": [
            {
                "name": "clk_en_rst",
                "descr": "Clock, clock enable and reset",
                "interface": {"type": "clk_en_rst", "subtype": "slave"},
            },
            {
                "name": "rst",
                "descr": "Synchronous reset",
                "signals": [
                    {
                        "name": "rst",
                        "descr": "CPU synchronous reset",
                        "direction": "input",
                        "width": "1",
                    },
                ],
            },
            {
                "name": "i_bus",
                "descr": "iob-picorv32 instruction bus",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": "ibus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
            {
                "name": "d_bus",
                "descr": "iob-picorv32 data bus",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": "dbus_",
                    "DATA_W": "DATA_W",
                    "ADDR_W": "ADDR_W",
                },
            },
            {
                "name": "clint_cbus",
                "descr": "CLINT CSRs bus",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": "clint_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
            {
                "name": "plic_cbus",
                "descr": "PLIC CSRs bus",
                "interface": {
                    "type": "axi",
                    "subtype": "slave",
                    "port_prefix": "plic_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
            {
                "name": "plic_interrupts",
                "descr": "PLIC interrupts",
                "signals": [
                    {
                        "name": "plic_interrupts",
                        "descr": "PLIC interrupts",
                        "direction": "input",
                        "width": "32",
                    },
                ],
            },
        ],
        "wires": [
            {
                "name": "cpu_reset",
                "descr": "cpu reset signal",
                "signals": [
                    {"name": "cpu_reset", "direction": "input", "width": "1"},
                ],
            },
            {
                "name": "ibus_int",
                "descr": "ibus internal signals",
                "signals": [
                    {"name": "iBus_axi_arregion", "width": "3"},
                    {"name": "iBus_axi_arlock", "width": "1"},
                ],
            },
            {
                "name": "dbus_int",
                "descr": "dbus internal signals",
                "signals": [
                    {"name": "dBus_axi_awregion", "width": "3"},
                    {"name": "dBus_axi_awlock", "width": "1"},
                    {"name": "dBus_axi_arregion", "width": "3"},
                    {"name": "dBus_axi_arlock", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
  // Instantiation of VexRiscv, Plic, and Clint
  VexRiscvAxi4LinuxPlicClint CPU (
      .clint_awvalid(clint_awvalid),
      .clint_awready(clint_awready),
      .clint_awaddr(clint_awaddr),
      .clint_awprot(clint_awprot),
      .clint_wvalid(clint_wvalid),
      .clint_wready(clint_wready),
      .clint_wdata(clint_wdata),
      .clint_wstrb(clint_wstrb),
      .clint_bvalid(clint_bvalid),
      .clint_bready(clint_bready),
      .clint_bresp(clint_bresp),
      .clint_arvalid(clint_arvalid),
      .clint_arready(clint_arready),
      .clint_araddr(clint_araddr),
      .clint_arprot(clint_arprot),
      .clint_rvalid(clint_rvalid),
      .clint_rready(clint_rready),
      .clint_rdata(clint_rdata),
      .clint_rresp(clint_rresp),
      .plic_awvalid(plic_awvalid),
      .plic_awready(plic_awready),
      .plic_awaddr(plic_awaddr),
      .plic_awprot(plic_awprot),
      .plic_wvalid(plic_wvalid),
      .plic_wready(plic_wready),
      .plic_wdata(plic_wdata),
      .plic_wstrb(plic_wstrb),
      .plic_bvalid(plic_bvalid),
      .plic_bready(plic_bready),
      .plic_bresp(plic_bresp),
      .plic_arvalid(plic_arvalid),
      .plic_arready(plic_arready),
      .plic_araddr(plic_araddr),
      .plic_arprot(plic_arprot),
      .plic_rvalid(plic_rvalid),
      .plic_rready(plic_rready),
      .plic_rdata(plic_rdata),
      .plic_rresp(plic_rresp),
      .plicInterrupts(plicInterrupts),
      .iBusAxi_arvalid(iBus_axi_arvalid_o),
      .iBusAxi_arready(iBus_axi_arready_i),
      .iBusAxi_araddr(iBus_axi_araddr_o),
      .iBusAxi_arid(iBus_axi_arid_o),
      .iBusAxi_arregion(iBus_axi_arregion),
      .iBusAxi_arlen(iBus_axi_arlen_o),
      .iBusAxi_arsize(iBus_axi_arsize_o),
      .iBusAxi_arburst(iBus_axi_arburst_o),
      .iBusAxi_arlock(iBus_axi_arlock),
      .iBusAxi_arcache(iBus_axi_arcache_o),
      .iBusAxi_arqos(iBus_axi_arqos_o),
      .iBusAxi_arprot(iBus_axi_arprot_o),
      .iBusAxi_rvalid(iBus_axi_rvalid_i),
      .iBusAxi_rready(iBus_axi_rready_o),
      .iBusAxi_rdata(iBus_axi_rdata_i),
      .iBusAxi_rid(iBus_axi_rid_i),
      .iBusAxi_rresp(iBus_axi_rresp_i),
      .iBusAxi_rlast(iBus_axi_rlast_i),
      .dBusAxi_awvalid(dBus_axi_awvalid_o),
      .dBusAxi_awready(dBus_axi_awready_i),
      .dBusAxi_awaddr(dBus_axi_awaddr_o),
      .dBusAxi_awid(dBus_axi_awid_o),
      .dBusAxi_awregion(dBus_axi_awregion),
      .dBusAxi_awlen(dBus_axi_awlen_o),
      .dBusAxi_awsize(dBus_axi_awsize_o),
      .dBusAxi_awburst(dBus_axi_awburst_o),
      .dBusAxi_awlock(dBus_axi_awlock),
      .dBusAxi_awcache(dBus_axi_awcache_o),
      .dBusAxi_awqos(dBus_axi_awqos_o),
      .dBusAxi_awprot(dBus_axi_awprot_o),
      .dBusAxi_wvalid(dBus_axi_wvalid_o),
      .dBusAxi_wready(dBus_axi_wready_i),
      .dBusAxi_wdata(dBus_axi_wdata_o),
      .dBusAxi_wstrb(dBus_axi_wstrb_o),
      .dBusAxi_wlast(dBus_axi_wlast_o),
      .dBusAxi_bvalid(dBus_axi_bvalid_i),
      .dBusAxi_bready(dBus_axi_bready_o),
      .dBusAxi_bid(dBus_axi_bid_i),
      .dBusAxi_bresp(dBus_axi_bresp_i),
      .dBusAxi_arvalid(dBus_axi_arvalid_o),
      .dBusAxi_arready(dBus_axi_arready_i),
      .dBusAxi_araddr(dBus_axi_araddr_o),
      .dBusAxi_arid(dBus_axi_arid_o),
      .dBusAxi_arregion(dBus_axi_arregion),
      .dBusAxi_arlen(dBus_axi_arlen_o),
      .dBusAxi_arsize(dBus_axi_arsize_o),
      .dBusAxi_arburst(dBus_axi_arburst_o),
      .dBusAxi_arlock(dBus_axi_arlock),
      .dBusAxi_arcache(dBus_axi_arcache_o),
      .dBusAxi_arqos(dBus_axi_arqos_o),
      .dBusAxi_arprot(dBus_axi_arprot_o),
      .dBusAxi_rvalid(dBus_axi_rvalid_i),
      .dBusAxi_rready(dBus_axi_rready_o),
      .dBusAxi_rdata(dBus_axi_rdata_i),
      .dBusAxi_rid(dBus_axi_rid_i),
      .dBusAxi_rresp(dBus_axi_rresp_i),
      .dBusAxi_rlast(dBus_axi_rlast_i),
      .clk(clk_i),
      .reset(cpu_reset)
  );



   assign cpu_reset = rst_i | arst_i;

   assign iBus_axi_awvalid_o = 1'b0;
   assign iBus_axi_awaddr_o = {ADDR_W{1'b0}};
   assign iBus_axi_awid_o = 1'b0;
   assign iBus_axi_awlen_o = {IBUS_AXI_LEN_W{1'b0}};
   assign iBus_axi_awsize_o = {3{1'b0}};
   assign iBus_axi_awburst_o = {2{1'b0}};
   assign iBus_axi_awlock_o = 1'b0;
   assign iBus_axi_awcache_o = {4{1'b0}};
   assign iBus_axi_awqos_o = {4{1'b0}};
   assign iBus_axi_awprot_o = {3{1'b0}};
   assign iBus_axi_wvalid_o = 1'b0;
   assign iBus_axi_wdata_o = {DATA_W{1'b0}};
   assign iBus_axi_wstrb_o = {DATA_W / 8{1'b0}};
   assign iBus_axi_wlast_o = 1'b0;
   assign iBus_axi_bready_o = 1'b0;
   assign iBus_axi_arlock_o = {1'b0, iBus_axi_arlock};

   assign dBus_axi_awlock_o = {1'b0, dBus_axi_awlock};
   assign dBus_axi_arlock_o = {1'b0, dBus_axi_arlock};
"""
            }
        ],
    }

    return attributes_dict
