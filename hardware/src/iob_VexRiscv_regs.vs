  
  // VexRiscv iob-regs instantiation
  // // INSTRUCTIONS BUS
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_i_avalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (ibus_ready),
      .en_i  (1'b1),
      .data_i(ibus_avalid),
      .data_o(ibus_avalid_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_i_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (ibus_avalid),
      .data_i(ibus_addr),
      .data_o(ibus_addr_r)
  );

  // // DATA BUS
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_d_avalid (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (dbus_ready),
      .en_i  (1'b1),
      .data_i(dbus_avalid),
      .data_o(dbus_avalid_r)
  );
  iob_reg_re #(
      .DATA_W (ADDR_W),
      .RST_VAL(0)
  ) iob_reg_d_addr (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_avalid),
      .data_i(dbus_addr),
      .data_o(dbus_addr_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W),
      .RST_VAL(0)
  ) iob_reg_d_data (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_avalid),
      .data_i(dbus_req_data),
      .data_o(dbus_req_data_r)
  );
  iob_reg_re #(
      .DATA_W (DATA_W / 8),
      .RST_VAL(0)
  ) iob_reg_d_strb (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (dbus_avalid),
      .data_i(dbus_strb),
      .data_o(dbus_strb_r)
  );
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_wack (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(dbus_wack),
      .data_o(dbus_wack_r)
  );
  iob_reg_re #(
      .DATA_W (1),
      .RST_VAL(0)
  ) iob_reg_d_last (
      .clk_i (clk_i),
      .arst_i(arst_i),
      .cke_i (cke_i),
      .rst_i (1'b0),
      .en_i  (1'b1),
      .data_i(dbus_req_last),
      .data_o(dbus_resp_last)
  );
