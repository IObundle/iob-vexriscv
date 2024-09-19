def setup(py_params_dict):
    attributes_dict = {
        "original_name": "iob_vexriscv",
        "name": "iob_vexriscv",
        "version": "0.1",
        "confs": [
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
                "name": "clk_en_rst_s",
                "descr": "Clock, clock enable and reset",
                "interface": {"type": "clk_en_rst", "subtype": "slave"},
            },
            {
                "name": "rst_i",
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
                "name": "i_bus_m",
                "descr": "iob-picorv32 instruction bus",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": "ibus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
            {
                "name": "d_bus_m",
                "descr": "iob-picorv32 data bus",
                "interface": {
                    "type": "axi",
                    "subtype": "master",
                    "port_prefix": "dbus_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "AXI_ADDR_W",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                    "LOCK_W": 1,
                },
            },
            {
                "name": "clint_cbus_s",
                "descr": "CLINT CSRs bus",
                "interface": {
                    "type": "axil",
                    "subtype": "slave",
                    "port_prefix": "clint_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "16",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
            {
                "name": "plic_cbus_s",
                "descr": "PLIC CSRs bus",
                "interface": {
                    "type": "axil",
                    "subtype": "slave",
                    "port_prefix": "plic_",
                    "ID_W": "AXI_ID_W",
                    "ADDR_W": "22",
                    "DATA_W": "AXI_DATA_W",
                    "LEN_W": "AXI_LEN_W",
                },
            },
            {
                "name": "plic_interrupts_i",
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
                    {"name": "ibus_axi_arregion_int", "width": "4"},
                    {"name": "ibus_axi_arlock_int", "width": "1"},
                ],
            },
            {
                "name": "dbus_int",
                "descr": "dbus internal signals",
                "signals": [
                    {"name": "dbus_axi_awregion_int", "width": "4"},
                    {"name": "dbus_axi_awlock_int", "width": "1"},
                    {"name": "dbus_axi_arregion_int", "width": "4"},
                    {"name": "dbus_axi_arlock_int", "width": "1"},
                ],
            },
        ],
        "snippets": [
            {
                "verilog_code": """
  // Instantiation of VexRiscv, Plic, and Clint
  VexRiscvAxi4LinuxPlicClint CPU (
      // CLINT
      .clint_awvalid(clint_axil_awvalid_i),
      .clint_awready(clint_axil_awready_o),
      .clint_awaddr(clint_axil_awaddr_i),
      .clint_awprot(clint_axil_awprot_i),
      .clint_wvalid(clint_axil_wvalid_i),
      .clint_wready(clint_axil_wready_o),
      .clint_wdata(clint_axil_wdata_i),
      .clint_wstrb(clint_axil_wstrb_i),
      .clint_bvalid(clint_axil_bvalid_o),
      .clint_bready(clint_axil_bready_i),
      .clint_bresp(clint_axil_bresp_o),
      .clint_arvalid(clint_axil_arvalid_i),
      .clint_arready(clint_axil_arready_o),
      .clint_araddr(clint_axil_araddr_i),
      .clint_arprot(clint_axil_arprot_i),
      .clint_rvalid(clint_axil_rvalid_o),
      .clint_rready(clint_axil_rready_i),
      .clint_rdata(clint_axil_rdata_o),
      .clint_rresp(clint_axil_rresp_o),
      // PLIC
      .plic_awvalid(plic_axil_awvalid_i),
      .plic_awready(plic_axil_awready_o),
      .plic_awaddr(plic_axil_awaddr_i),
      .plic_awprot(plic_axil_awprot_i),
      .plic_wvalid(plic_axil_wvalid_i),
      .plic_wready(plic_axil_wready_o),
      .plic_wdata(plic_axil_wdata_i),
      .plic_wstrb(plic_axil_wstrb_i),
      .plic_bvalid(plic_axil_bvalid_o),
      .plic_bready(plic_axil_bready_i),
      .plic_bresp(plic_axil_bresp_o),
      .plic_arvalid(plic_axil_arvalid_i),
      .plic_arready(plic_axil_arready_o),
      .plic_araddr(plic_axil_araddr_i),
      .plic_arprot(plic_axil_arprot_i),
      .plic_rvalid(plic_axil_rvalid_o),
      .plic_rready(plic_axil_rready_i),
      .plic_rdata(plic_axil_rdata_o),
      .plic_rresp(plic_axil_rresp_o),
      .plicInterrupts(plic_interrupts_i),
      // Instruction Bus
      .iBusAxi_arvalid(ibus_axi_arvalid_o),
      .iBusAxi_arready(ibus_axi_arready_i),
      .iBusAxi_araddr(ibus_axi_araddr_o),
      .iBusAxi_arid(ibus_axi_arid_o),
      .iBusAxi_arregion(ibus_axi_arregion_int),
      .iBusAxi_arlen(ibus_axi_arlen_o),
      .iBusAxi_arsize(ibus_axi_arsize_o),
      .iBusAxi_arburst(ibus_axi_arburst_o),
      .iBusAxi_arlock(ibus_axi_arlock_int),
      .iBusAxi_arcache(ibus_axi_arcache_o),
      .iBusAxi_arqos(ibus_axi_arqos_o),
      .iBusAxi_arprot(ibus_axi_arprot_o),
      .iBusAxi_rvalid(ibus_axi_rvalid_i),
      .iBusAxi_rready(ibus_axi_rready_o),
      .iBusAxi_rdata(ibus_axi_rdata_i),
      .iBusAxi_rid(ibus_axi_rid_i),
      .iBusAxi_rresp(ibus_axi_rresp_i),
      .iBusAxi_rlast(ibus_axi_rlast_i),
      // Data Bus
      .dBusAxi_awvalid(dbus_axi_awvalid_o),
      .dBusAxi_awready(dbus_axi_awready_i),
      .dBusAxi_awaddr(dbus_axi_awaddr_o),
      .dBusAxi_awid(dbus_axi_awid_o),
      .dBusAxi_awregion(dbus_axi_awregion_int),
      .dBusAxi_awlen(dbus_axi_awlen_o),
      .dBusAxi_awsize(dbus_axi_awsize_o),
      .dBusAxi_awburst(dbus_axi_awburst_o),
      .dBusAxi_awlock(dbus_axi_awlock_int),
      .dBusAxi_awcache(dbus_axi_awcache_o),
      .dBusAxi_awqos(dbus_axi_awqos_o),
      .dBusAxi_awprot(dbus_axi_awprot_o),
      .dBusAxi_wvalid(dbus_axi_wvalid_o),
      .dBusAxi_wready(dbus_axi_wready_i),
      .dBusAxi_wdata(dbus_axi_wdata_o),
      .dBusAxi_wstrb(dbus_axi_wstrb_o),
      .dBusAxi_wlast(dbus_axi_wlast_o),
      .dBusAxi_bvalid(dbus_axi_bvalid_i),
      .dBusAxi_bready(dbus_axi_bready_o),
      .dBusAxi_bid(dbus_axi_bid_i),
      .dBusAxi_bresp(dbus_axi_bresp_i),
      .dBusAxi_arvalid(dbus_axi_arvalid_o),
      .dBusAxi_arready(dbus_axi_arready_i),
      .dBusAxi_araddr(dbus_axi_araddr_o),
      .dBusAxi_arid(dbus_axi_arid_o),
      .dBusAxi_arregion(dbus_axi_arregion_int),
      .dBusAxi_arlen(dbus_axi_arlen_o),
      .dBusAxi_arsize(dbus_axi_arsize_o),
      .dBusAxi_arburst(dbus_axi_arburst_o),
      .dBusAxi_arlock(dbus_axi_arlock_int),
      .dBusAxi_arcache(dbus_axi_arcache_o),
      .dBusAxi_arqos(dbus_axi_arqos_o),
      .dBusAxi_arprot(dbus_axi_arprot_o),
      .dBusAxi_rvalid(dbus_axi_rvalid_i),
      .dBusAxi_rready(dbus_axi_rready_o),
      .dBusAxi_rdata(dbus_axi_rdata_i),
      .dBusAxi_rid(dbus_axi_rid_i),
      .dBusAxi_rresp(dbus_axi_rresp_i),
      .dBusAxi_rlast(dbus_axi_rlast_i),
      // Clock and Reset
      .clk(clk_i),
      .reset(cpu_reset)
  );



   assign cpu_reset = rst_i | arst_i;

   assign ibus_axi_awvalid_o = 1'b0;
   assign ibus_axi_awaddr_o = {AXI_ADDR_W{1'b0}};
   assign ibus_axi_awid_o = 1'b0;
   assign ibus_axi_awlen_o = {AXI_LEN_W{1'b0}};
   assign ibus_axi_awsize_o = {3{1'b0}};
   assign ibus_axi_awburst_o = {2{1'b0}};
   assign ibus_axi_awlock_o = 1'b0;
   assign ibus_axi_awcache_o = {4{1'b0}};
   assign ibus_axi_awqos_o = {4{1'b0}};
   assign ibus_axi_awprot_o = {3{1'b0}};
   assign ibus_axi_wvalid_o = 1'b0;
   assign ibus_axi_wdata_o = {AXI_DATA_W{1'b0}};
   assign ibus_axi_wstrb_o = {AXI_DATA_W / 8{1'b0}};
   assign ibus_axi_wlast_o = 1'b0;
   assign ibus_axi_bready_o = 1'b0;
   assign ibus_axi_arlock_o = {1'b0, ibus_axi_arlock_int};

   assign dbus_axi_awlock_o = {1'b0, dbus_axi_awlock_int};
   assign dbus_axi_arlock_o = {1'b0, dbus_axi_arlock_int};
"""
            }
        ],
    }

    return attributes_dict
