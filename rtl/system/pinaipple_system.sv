import tcdm_interconnect_pkg::topo_e;

module pinaipple_system #(
    parameter int GPIWidth = 8,
    parameter int GPOWidth = 8,
    parameter int CLK_FREQ = 50_000_000,
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_DEV_WIDTH = 20,
    parameter SRAMInitFile = ""
) (
    input logic clk_sys_in,
    input logic rst_sys_in,

    input logic [GPIWidth-1:0] gp_i,
    output logic [GPOWidth-1:0] gp_o,
    input logic uart_rx_i,
    output logic uart_tx_o
);

  parameter logic [31:0] SIMCTRLSIZE  = 1 * 1024; // 1kB
  parameter logic [31:0] SIMCTRLSTART = 32'h20000;
  parameter logic [31:0] SIMCTRLMASK  = ~(SIMCTRLSIZE-1);

  localparam logic [31:0] INSTR_MEMSIZE = 8 * 1024 ; 
  localparam logic [31:0] INSTR_MEMSTART = 32'h00100000;
  localparam logic [31:0] INSTR_MEMMASK = ~(INSTR_MEMSIZE - 1);

  localparam logic [31:0] DATA_MEMSIZE = 64 * 1024;  // 64 KiB
  localparam logic [31:0] DATA_MEMSTART = 32'h00200000;
  localparam logic [31:0] DATA_MEMMASK = ~(DATA_MEMSIZE - 1);

  localparam logic [31:0] GPIOSIZE = 4 * 1024;  //  4 KiB
  localparam logic [31:0] GPIOSTART = 32'h80000000;
  localparam logic [31:0] GPIOMASK = ~(GPIOSIZE - 1);

  localparam logic [31:0] UARTSIZE = 4 * 1024;  //  4 KiB
  localparam logic [31:0] UARTSTART = 32'h80001000;
  localparam logic [31:0] UARTMASK = ~(UARTSIZE - 1);

  localparam logic [31:0] TIMERSIZE = 4 * 1024;  //  4 KiB
  localparam logic [31:0] TIMERSTART = 32'h80002000;
  localparam logic [31:0] TIMERMASK = ~(TIMERSIZE - 1);

  localparam logic [31:0] FRAISESIZE = 4 * 1024 ; //array + registers for control and results
  localparam logic [31:0] FRAISESTART = 32'h70000000;
  localparam logic [31:0] FRAISEMASK = ~(FRAISESIZE - 1);

  typedef enum int {CoreD, Fraise_Host} bus_host_e;

  typedef enum int {
    Ram,
    Gpio,
    Uart,
    Timer,
    Fraise_Device,
    SimCtrl, 
    error
  } bus_device_e;

  localparam int NbrDevices = 6;
  localparam int NbrHosts = 2;

  //interrupts
  logic timer_irq;
  logic uart_irq;
  logic fraise_irq;

  //instruction fetch signals

  logic core_instr_req;
  logic [31:0] core_instr_addr;
  logic [31:0] core_instr_rdata;
  logic core_instr_gnt;
  logic core_instr_rvalid;

  logic mem_instr_req;
  logic [31:0] mem_instr_rdata;

  //interface fecth to mem (bypass the network)
  assign mem_instr_req = core_instr_req;
  assign core_instr_rdata = mem_instr_rdata;
  assign core_instr_gnt = mem_instr_req;

  always @(posedge clk_sys_in or negedge rst_sys_in) begin
    if (!rst_sys_in) begin
      core_instr_rvalid <= 1'b0;
    end else begin
      core_instr_rvalid <= core_instr_gnt;
    end
  end

  // signals and assigns for L1_bus
  // request network hosts
  logic [NbrHosts-1:0]                       Host_req_valid;  // request valid
  logic [NbrHosts-1:0]                       Host_req_ready;  // network ready for req
  logic [NbrHosts-1:0]                       Host_gnt;  // grant signal : arbitration beetwen hosts
  logic [NbrHosts-1:0][      DATA_WIDTH-1:0] Host_tgt_addr;  // Host addr
  logic [NbrHosts-1:0]                       Host_we;  // host write enable
  logic [NbrHosts-1:0][DATA_WIDTH/8 - 1 : 0] Host_be;  // byte enable
  logic [NbrHosts-1:0][      DATA_WIDTH-1:0] Host_wdata;  // host write data
  // response network Hosts
  logic [NbrHosts-1:0]                       Host_resp_valid;
  logic [NbrHosts-1:0]                       Host_resp_ready;
  logic [NbrHosts-1:0][      DATA_WIDTH-1:0] Host_resp_data;
  // assign value host side TODO : change
  assign Host_resp_ready[CoreD] = '1;  // always ready for response

  //request network Devices
  localparam int unsigned NbrHostsLog2 = (NbrHosts == 1) ? 1 : $clog2(NbrHosts);
  logic [NbrDevices-1:0] Device_req_valid;  // req net-> device valid
  logic [NbrDevices-1:0] Device_req_ready;  // device ready
  logic [NbrDevices-1:0] [NbrHostsLog2-1:0] Device_host_addr ; //address of the host of the request
  logic [NbrDevices-1:0][ADDR_DEV_WIDTH-1:0] Device_tgt_addr;  // 4Ko on each target => not enough with accel
  logic [NbrDevices-1:0] Device_wen;  // write enable from host
  logic [NbrDevices-1:0][DATA_WIDTH-1:0] Device_wdata;  // data to write from host
  logic [NbrDevices-1:0][DATA_WIDTH/8 -1 : 0] Device_ben;  // byte enable from host
  //response network Devices
  logic [NbrDevices-1:0] Device_resp_valid;  // response valid
  logic [NbrDevices-1:0] Device_resp_ready;  // ready for response
  logic [NbrDevices-1:0] [NbrHostsLog2-1:0] Device_resp_addr_host ; // address of the host for resp
  logic [NbrDevices-1:0][DATA_WIDTH-1:0] Device_resp_data;  // response data

  logic [DATA_WIDTH-1:0] ibex_data_addr_out ;
  bus_device_e ibex_tgt_addr_out ; 

  always_comb begin : select_tgt
    // switch staement to select the target   
    if(ibex_data_addr_out <= (SIMCTRLSTART + SIMCTRLSIZE)) begin // true if in adress space
      ibex_tgt_addr_out = SimCtrl;
    end else if(ibex_data_addr_out <= (INSTR_MEMSTART + INSTR_MEMSIZE)) begin
      ibex_tgt_addr_out = error;
    end else if(ibex_data_addr_out <= (DATA_MEMSTART + DATA_MEMSIZE)) begin
      ibex_tgt_addr_out = Ram;
    end else if(ibex_data_addr_out <= (FRAISESTART + FRAISESIZE)) begin
      ibex_tgt_addr_out = Fraise_Device;  
    end else if(ibex_data_addr_out <= (GPIOSTART + GPIOSIZE)) begin
      ibex_tgt_addr_out = Gpio;
    end else if(ibex_data_addr_out <= (UARTSTART + UARTSIZE)) begin
      ibex_tgt_addr_out = Uart;
    end else if(ibex_data_addr_out <= (TIMERSTART + TIMERSIZE)) begin
      ibex_tgt_addr_out = Timer;   
    end else begin
      ibex_tgt_addr_out = error;
      `ifdef VERILATOR 
        if (Host_req_valid[CoreD]) begin
          $display("ERROR : no target found for adress %h", ibex_data_addr_out);
        end
      `endif
    end

    end

  assign Host_tgt_addr[0] = {ibex_data_addr_out[DATA_WIDTH - 6:0], ibex_tgt_addr_out[2:0], 2'b0} ;

  variable_latency_interconnect #(
      .NumIn(NbrHosts),
      .NumOut(NbrDevices),
      .AddrWidth(DATA_WIDTH),
      .AddrMemWidth(ADDR_DEV_WIDTH),
      .Topology(tcdm_interconnect_pkg::LIC)
  ) L1_interconnect (

      .clk_i (clk_sys_in),
      .rst_ni(rst_sys_in),

      //HostSide
      .req_valid_i   (Host_req_valid),   // Request valid
      .req_ready_o   (Host_req_ready),   // 1 if network ready for request
      .req_tgt_addr_i(Host_tgt_addr),    //Target Adress = adress in memory & tgt & offwidth   
      .req_wen_i     (Host_we),          //Write enable
      .req_wdata_i   (Host_wdata),       //Write Data
      .req_be_i      (Host_be),          //Byte enable
      .resp_valid_o  (Host_resp_valid),  //Response valid
      .resp_ready_i  (Host_resp_ready),  //Response ready
      .resp_rdata_o  (Host_resp_data),   //Data response

      //DeviceSide
      .req_valid_o    (Device_req_valid),       // Request valid
      .req_ready_i    (Device_req_ready),       //Request ready
      .req_ini_addr_o (Device_host_addr),       //Host address
      .req_tgt_addr_o (Device_tgt_addr),        //Target adress
      .req_wen_o      (Device_wen),             //Write enable
      .req_wdata_o    (Device_wdata),           //Write data
      .req_be_o       (Device_ben),             //Byte enable
      .resp_valid_i   (Device_resp_valid),      //Response valid
      .resp_ready_o   (Device_resp_ready),      //Response ready
      .resp_ini_addr_i(Device_resp_addr_host),  //Initiator adress
      .resp_rdata_i   (Device_resp_data)        //Data response
  );


  // RISCV ibex instance rv32imc
  ibex_top #(
      .RegFile       (ibex_pkg::RegFileFPGA),       //use
      .MHPMCounterNum(10),
      .RV32M         (ibex_pkg::RV32MSingleCycle),
      .RV32B         (ibex_pkg::RV32BNone)
      //.DbgTriggerEn    ( DbgTriggerEn                            ),
      //.DbgHwBreakNum   ( DbgHwBreakNum                           ),
      //.DmHaltAddr      ( DEBUG_START + dm::HaltAddress[31:0]     ),
      //.DmExceptionAddr ( DEBUG_START + dm::ExceptionAddress[31:0])
  ) u_top (
      .clk_i (clk_sys_in),
      .rst_ni(rst_sys_in),

      .test_en_i  ('b0),   //no idea
      .scan_rst_ni(1'b1),  //no idea
      .ram_cfg_i  ('b0),   //no idea

      .hart_id_i  (),
      // First instruction executed is at 0x0 + 0x80
      .boot_addr_i(32'h00100000),

      .instr_req_o       (core_instr_req),     // request instr data
      .instr_gnt_i       (core_instr_gnt),     //
      .instr_rvalid_i    (core_instr_rvalid),  // instruction is valid
      .instr_addr_o      (core_instr_addr),    // addr of instr
      .instr_rdata_i     (core_instr_rdata),   // instr data
      .instr_rdata_intg_i('0),                 // no ECC
      .instr_err_i       ('0),                 // don't know what this does

      .data_req_o       (Host_req_valid[CoreD]),
      .data_gnt_i       (Host_gnt[CoreD]), // need to do real aswering of the nework 
      .data_rvalid_i    (Host_resp_valid[CoreD]),
      .data_we_o        (Host_we[CoreD]),
      .data_be_o        (Host_be[CoreD]),
      .data_addr_o      (ibex_data_addr_out),
      .data_wdata_o     (Host_wdata[CoreD]),
      .data_wdata_intg_o(),
      .data_rdata_i     (Host_resp_data[CoreD]),
      .data_rdata_intg_i('0),
      .data_err_i       ('0),                    // no erros by default (super safe dont worry)

      .irq_software_i(1'b0),
      .irq_timer_i   (timer_irq),
      .irq_external_i(1'b0),
      .irq_fast_i    ({13'b0, fraise_irq ,uart_irq}),
      .irq_nm_i      (1'b0),

      .scramble_key_valid_i('0),
      .scramble_key_i      ('0),
      .scramble_nonce_i    ('0),
      .scramble_req_o      (),

      .debug_req_i        (),
      .crash_dump_o       (),
      .double_fault_seen_o(),

      .fetch_enable_i        ('1),
      .alert_minor_o         (),
      .alert_major_internal_o(),
      .alert_major_bus_o     (),
      .core_sleep_o          ()
  );

  /////////////////
  // PERIPHERALS //
  /////////////////

  //2 RAM withh 1 entries/ram with control for interface with L1 bus

  assign Device_req_ready[Ram] = 1'b1;
  // send host adress back after one period of clk
  always @(posedge clk_sys_in) begin
    if (Device_req_valid[Ram] && !Device_wen[Ram]) begin
      Device_resp_addr_host[Ram] = Device_host_addr[Ram];
    end
  end
  // not waiting for response ready from the network (should but... lazy)

  ram_1p #( // instr ram (1 port) 
    .Depth(INSTR_MEMSIZE / 4),
    .MemInitFile(SRAMInitFile)
  ) instr_ram ( 
    .clk_i(clk_sys_in),
    .rst_ni(rst_sys_in),

    .req_i(mem_instr_req), 
    .we_i(1'b0), 
    .be_i(4'b0),
    .addr_i(core_instr_addr),
    .wdata_i(32'b0),
    .rvalid_o(),
    .rdata_o(mem_instr_rdata)
  ) ;

  ram_1p #( // data ram (1 port) 
    .Depth(DATA_MEMSIZE / 4),
    .MemInitFile()
  ) data_ram ( 
    .clk_i(clk_sys_in),
    .rst_ni(rst_sys_in),

    .req_i(Device_req_valid[Ram]), 
    .we_i(Device_wen[Ram]), 
    .be_i(Device_ben[Ram]),
    .addr_i({12'b0, Device_tgt_addr[Ram]}),
    .wdata_i(Device_wdata[Ram]),
    .rvalid_o(Device_resp_valid[Ram]),
    .rdata_o(Device_resp_data[Ram])
  ) ;

  // GPIO

  assign Device_req_ready[Gpio] = 1'b1;
  // send host adress back after one period of clk
  always @(posedge clk_sys_in) begin
    if (Device_req_valid[Gpio] && !Device_wen[Gpio]) begin
      Device_resp_addr_host[Gpio] = Device_host_addr[Gpio];
    end
  end

  gpio #(
      .GpiWidth(GPIWidth),
      .GpoWidth(GPOWidth)
  ) u_gpio (
      .clk_i (clk_sys_in),
      .rst_ni(rst_sys_in),

      .device_req_i   (Device_req_valid[Gpio]),
      .device_addr_i  ({12'b0,Device_tgt_addr[Gpio]}),
      .device_we_i    (Device_wen[Gpio]),
      .device_be_i    (Device_ben[Gpio]),
      .device_wdata_i (Device_wdata[Gpio]),
      .device_rvalid_o(Device_resp_valid[Gpio]),
      .device_rdata_o (Device_resp_data[Gpio]),

      .gp_i,  // assigned to pins
      .gp_o  // assign to pins
  );

  // UART (fast irq)

  assign Device_req_ready[Uart] = 1'b1;
  // send host adress back after one period of clk
  always @(posedge clk_sys_in) begin
    if (Device_req_valid[Uart]) begin
      Device_resp_addr_host[Uart] = Device_host_addr[Uart];
    end
  end

  uart #(
      .ClockFrequency(CLK_FREQ)
  ) u_uart (
      .clk_i (clk_sys_in),
      .rst_ni(rst_sys_in),

      .device_req_i   (Device_req_valid[Uart]),
      .device_addr_i  ({12'b0,Device_tgt_addr[Uart]}),
      .device_we_i    (Device_wen[Uart]),
      .device_be_i    (Device_ben[Uart]),
      .device_wdata_i (Device_wdata[Uart]),
      .device_rvalid_o(Device_resp_valid[Uart]),
      .device_rdata_o (Device_resp_data[Uart]),

      .uart_rx_i,  // assign to pin
      .uart_irq_o(uart_irq),
      .uart_tx_o  // assigned to pin
  );

  // TIMER (with irq)

  assign Device_req_ready[Timer] = 1'b1;
  // send host adress back after one period of clk
  always @(posedge clk_sys_in) begin
    if (Device_req_valid[Timer]) begin
      Device_resp_addr_host[Timer] = Device_host_addr[Timer];
    end
  end

  timer #(
      .DataWidth   (32),
      .AddressWidth(32)
  ) u_timer (
      .clk_i (clk_sys_in),
      .rst_ni(rst_sys_in),

      .timer_req_i   (Device_req_valid[Timer]),
      .timer_we_i    (Device_wen[Timer]),
      .timer_be_i    (Device_ben[Timer]),
      .timer_addr_i  ({12'b0,Device_tgt_addr[Timer]}),
      .timer_wdata_i (Device_wdata[Timer]),
      .timer_rvalid_o(Device_resp_valid[Timer]),
      .timer_rdata_o (Device_resp_data[Timer]),
      .timer_err_o   (),
      .timer_intr_o  (timer_irq)
  );
  
  fraise_top #(
    .DataWidth(32),
    .AddrWidth(32),
    .MatrixSize(4),
    .ArraySize(64),
    .Nword_used(3),
    .NbrHostsLog2(NbrHostsLog2)
  ) u_fraise_accel (
    .clk_i(clk_sys_in),
    .reset_n(rst_sys_in),

    .req_valid_i(Device_req_valid[Fraise_Device]),
    .ready_o(Device_req_ready[Fraise_Device]), 
    .req_host_addr_i(Device_host_addr[Fraise_Device]),
    .req_addr_i({12'b0,Device_tgt_addr[Fraise_Device]}),
    .req_wen_i(Device_wen[Fraise_Device]),
    .req_wdata_i(Device_wdata[Fraise_Device]),
    .req_ben_i(Device_ben[Fraise_Device]),

    .resp_valid_o(Device_resp_valid[Fraise_Device]),
    .resp_ready_i(Device_resp_ready[Fraise_Device]),
    .resp_data_o(Device_resp_data[Fraise_Device]),
    .resp_ini_addr_o(Device_resp_addr_host[Fraise_Device]),
    .irq_o(fraise_irq),

    .Host_req_valid_o(Host_req_valid[Fraise_Host]),
    .Host_req_ready_i(Host_req_ready[Fraise_Host]),
    .Host_gnt_i(Host_gnt[Fraise_Host]),
    .Host_tgt_addr_o(Host_tgt_addr[Fraise_Host]),
    .Host_wen_o(Host_we[Fraise_Host]),
    .Host_ben_o(Host_be[Fraise_Host]),
    .Host_wdata_o(Host_wdata[Fraise_Host]),
    .Host_resp_valid_i(Host_resp_valid[Fraise_Host]),
    .Host_resp_data_i(Host_resp_data[Fraise_Host]),
    .Host_resp_ready_o(Host_resp_ready[Fraise_Host])
    
    ) ; 

    // grant control to the network
    arbiter_l1 #(.NUMBER_HOSTS(2)) u_arbiter (
      .Host_req_valid_i(Host_req_valid), 
      .network_ready_i(Host_req_ready),
      .Host_grant_o(Host_gnt)
    ) ;
  
  `ifdef VERILATOR
    simulator_ctrl #(
      .LogName("pinaipple_system.log"),
      .FlushOnChar(0)
    ) u_simulator_ctrl (
      .clk_i (clk_sys_in),
      .rst_ni (rst_sys_in),

      .req_i     (Device_req_valid[SimCtrl]),
      .we_i      (Device_wen[SimCtrl]),
      .be_i      (Device_ben[SimCtrl]),
      .addr_i    ({12'b0,Device_tgt_addr[SimCtrl]}),
      .wdata_i   (Device_wdata[SimCtrl]),
      .rvalid_o  (Device_resp_valid[SimCtrl]),
      .rdata_o   (Device_resp_data[SimCtrl])
    ) ;
  `endif 

  `ifdef VERILATOR
    export "DPI-C" function mhpmcounter_get;

    function automatic longint unsigned mhpmcounter_get(int index);
      return u_top.u_ibex_core.cs_registers_i.mhpmcounter[index];
    endfunction
  `endif
endmodule
