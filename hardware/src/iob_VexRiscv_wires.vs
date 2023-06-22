
  // VexRiscv Wires
  // // INSTRUCTIONS BUS
  wire                ibus_avalid;
  wire                ibus_avalid_int;
  wire                ibus_rvalid;
  wire                ibus_ready;
  wire [  ADDR_W-1:0] ibus_addr;
  wire [  ADDR_W-1:0] ibus_addr_int;
  wire [         1:0] ibus_size;
  wire                ibus_ack;
  wire [  DATA_W-1:0] ibus_resp_data;
  wire                ibus_error;
  wire                ibus_avalid_r;
  wire [  ADDR_W-1:0] ibus_addr_r;
  wire                ibus_addr_msb;

  // // DATA BUS
  wire                dbus_avalid;
  wire                dbus_rvalid;
  wire                dbus_ready;
  wire                dbus_avalid_int;
  wire                dbus_we;
  wire                dbus_uncached;
  wire [         1:0] dbus_size;
  wire                dbus_req_last;
  wire [  ADDR_W-1:0] dbus_addr;
  wire [  ADDR_W-1:0] dbus_addr_int;
  wire [  DATA_W-1:0] dbus_req_data;
  wire [  DATA_W-1:0] dbus_req_data_int;
  wire [DATA_W/8-1:0] dbus_strb;
  wire [DATA_W/8-1:0] dbus_strb_int;
  wire [DATA_W/8-1:0] dbus_mask;
  wire                dbus_ack;
  wire                dbus_wack;
  wire                dbus_wack_r;
  wire                dbus_resp_last;
  wire [  DATA_W-1:0] dbus_resp_data;
  wire                dbus_error;
  wire                dbus_avalid_r;
  wire [  ADDR_W-1:0] dbus_addr_r;
  wire [  DATA_W-1:0] dbus_req_data_r;
  wire [DATA_W/8-1:0] dbus_strb_r;
