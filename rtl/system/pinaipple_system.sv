module pinaipple_top #(
    parameter int GPI_Width = 8, 
    parameter int GPO_Width = 8,
    parameter int CLK_FREQ = 50_000_000,
    parameter int DATA_WIDTH = 32
    parameter SRAMInitFile = ""
)(
    input logic clk_sys_in, 
    input logic rst_sys_in,

    input logic [GPI_Width-1:0] gp_i,
    output logic [GPO_Width-1:0] gp_o,
    input logic uart_rx_i, 
    output logic uart_tx_o
 );
    
    localparam logic [31:0] MEM_SIZE      = 64 * 1024; // 64 KiB
    localparam logic [31:0] MEM_START     = 32'h00100000;
    localparam logic [31:0] MEM_MASK      = ~(MEM_SIZE-1);

    localparam logic [31:0] GPIO_SIZE     =  4 * 1024; //  4 KiB
    localparam logic [31:0] GPIO_START    = 32'h80000000;
    localparam logic [31:0] GPIO_MASK     = ~(GPIO_SIZE-1);

    localparam logic [31:0] UART_SIZE     =  4 * 1024; //  4 KiB
    localparam logic [31:0] UART_START    = 32'h80001000;
    localparam logic [31:0] UART_MASK     = ~(UART_SIZE-1);

    localparam logic [31:0] TIMER_SIZE    =  4 * 1024; //  4 KiB
    localparam logic [31:0] TIMER_START   = 32'h80002000;
    localparam logic [31:0] TIMER_MASK    = ~(TIMER_SIZE-1);

    typedef enum int { 
        CoreD
    } bus_host_e;

    typedef enum int { 
        Ram, 
        Gpio,
        Uart,
        Timer
    } bus_device_e;

    localparam int NbrDevices = 4 ; 
    localparam int NbrHosts = 1 ; 

    //interrupts 
    logic timer_irq ; 
    logic uart_irq ; 

    //instruction fetch signals

    logic core_instr_req; 
    logic [31:0] core_instr_addr;
    logic [31:0] core_instr_rdata;
    logic core_instr_gnt;
    logic core_instr_rvalid;

    logic mem_instr_req;
    logic [31:0] nnmem_instr_rdata;

    //interface fecth to mem (bypass the network)
    assign mem_instr_req = core_instr_req ; 
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
    logic [NbrHosts-1:0] Host_req_valid; // request valid 
    logic [NbrHosts-1:0] Host_req_ready; // network ready for req
    logic [NbrHosts-1:0] Host_gnt ; // NO IDEA
    logic [NbrHosts-1:0] [DATA_WIDTH-1:0] Host_tgt_addr ; // Host addr
    logic [NbrHosts-1:0] Host_we ; // host write enable
    logic [NbrHosts-1:0] [DATA_WIDTH/8 - 1 :0] Host_be  ; // byte enable 
    logic [NbrHosts-1:0] [DATA_WIDTH-1:0] Host_wdata ; // host write data
    // response network Hosts
    logic [NbrHosts-1:0] Host_resp_valid ;
    logic [NbrHosts-1:0] Host_resp_ready ; 
    logic [NbrHosts-1:0] [DATA_WIDTH-1:0] Host_resp_data ;  
    //request network Devices
    localparam int unsigned NbrHostsLog2 = (NbrHosts == 1) ? 1 : $clog2(NbrHosts)
    logic [NbrDevices-1:0] Device_req_valid ; // req net-> device valid  
    logic [NbrDevices-1:0] Device_req_ready ; // device ready 
    logic [NbrDevices-1:0] [NbrHostsLog2-1:0] Device_host_addr ; //address of the host of the request
    logic [NbrDevices-1:0] [11:0] Device_tgt_addr ;  // 4Ko on each target => not enough with accel 
    logic [NbrDevices-1:0] Device_wen ; // write enable from host
    logic [NbrDevices-1:0] [DATA_WIDTH-1:0] Device_wdata ; // data to write from host
    logic [NbrDevices-1:0] [DATA_WIDTH/8 -1 :0] Device_ben ; // byte enable from host
    //response network Devices
    logic [NbrDevices-1:0] Device_resp_valid ; // response valid  
    logic [NbrDevices-1:0] Device_resp_ready ; // ready for response
    logic [NbrDevices-1:0] [NbrHostsLog2-1:0] Device_resp_addr_host ; // address of the host for the response
    logic [NbrDevices-1:0] [DATA_WIDTH-1:0] Device_resp_data ; // response data

    variable_latency_interconnect #(
        .NumIn(NbrHosts),
        .NumOut(NbrDevices),
        .AddrWidth(DATA_WIDTH),
        .AddrMemWidth(12),
        .Topology(tcdm_interconnect_pkg::LIC)
    ) L1_interconnect (
        
        .clk_i(clk_sys_in),
        .rst_ni(rst_sys_in),

        //HostSide 
        .req_valid_i(Host_req_valid), // Request valid
        .req_ready_o(Host_req_ready), // 1 if network ready for request
        .req_tgt_addr_i(Host_tgt_addr), //Target Adress 
        .req_wen_i(Host_we), //Write enable
        .req_wdata_i(Host_wdata), //Write Data
        .req_be_i(Host_be). //Byte enable
        .resp_valid_o(Host_req_valid), //Response valid
        .resp_ready_i(Host_resp_ready), //Response ready
        .resp_rdata_o(Host_resp_data), //Data response
        
        //DeviceSide
        .req_valid_o(Device_req_valid), // Request valid
        .req_ready_i(Device_req_ready), //Request ready 
        .req_ini_addr_o(Device_host_addr), //Host address
        .req_tgt_addr_o(Device_tgt_addr), //Target adress
        .req_wen_o(Device_wen), //Write enable
        .req_wdata_o(Device_wdata), //Write data
        .req_be_o(Device_ben), //Byte enable
        .resp_valid_i(Device_resp_valid), //Response valid
        .resp_ready_o(Device_resp_ready), //Response ready
        .resp_ini_addr_i(Device_resp_addr_host), //Initiator adress
        .resp_rdata_i(Device_resp_data) //Data response
    ) ;


    // RISCV ibex instance rv32imc 
    ibex_top #(
     .RegFile         ( ibex_pkg::RegFileFPGA                   ), //use 
     .MHPMCounterNum  ( 10                                      ),
     .RV32M           ( ibex_pkg::RV32MSingleCycle              ),
     .RV32B           ( ibex_pkg::RV32BNone                     ),
     //.DbgTriggerEn    ( DbgTriggerEn                            ),
     //.DbgHwBreakNum   ( DbgHwBreakNum                           ),
     //.DmHaltAddr      ( DEBUG_START + dm::HaltAddress[31:0]     ),
     //.DmExceptionAddr ( DEBUG_START + dm::ExceptionAddress[31:0])
    )u_top (
     .clk_i (clk_sys_in),
     .rst_ni(rst_sys_in),

     .test_en_i  ('b0), //no idea
     .scan_rst_ni(1'b1), //no idea
     .ram_cfg_i  ('b0), //no idea

     .hart_id_i(),
     // First instruction executed is at 0x0 + 0x80
     .boot_addr_i(32'h00100000),

      .instr_req_o       (core_instr_req), // request instr data
      .instr_gnt_i       (core_instr_gnt), // 
      .instr_rvalid_i    (core_instr_rvalid), // instruction is valid
      .instr_addr_o      (core_instr_addr), // addr of instr
      .instr_rdata_i     (core_instr_rdata), // instr data
      .instr_rdata_intg_i('0), // no ECC 
      .instr_err_i       ('0), // don't know what this does

      .data_req_o       (Host_req_valid[CoreD]),
      .data_gnt_i       (),
      .data_rvalid_i    (Host_req_valid[CoreD]),
      .data_we_o        (Host_we[CoreD]),
      .data_be_o        (Host_be[CoreD]),
      .data_addr_o      (Host_tgt_addr[CoreD]),
      .data_wdata_o     (Host_wdata[CoreD]),
      .data_wdata_intg_o(),
      .data_rdata_i     (Host_resp_data),
      .data_rdata_intg_i('0),
      .data_err_i       (1'b0),// no erros by default (super safe dont worry)

     .irq_software_i(1'b0),
     .irq_timer_i   (timer_irq),
     .irq_external_i(1'b0),
     .irq_fast_i    ({14'b0, uart_irq}),
     .irq_nm_i      (1'b0),

     .scramble_key_valid_i('0),
     .scramble_key_i      ('0),
     .scramble_nonce_i    ('0),
     .scramble_req_o      (),

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

    //RAM 2 entries with control for interface with L1 bus

    assign Device_req_ready[Ram] = 1'b1 ; 
    // send host adress back after on clk 
    always @(posedge clk_sys_in) begin 
        if (Device_req_valid[Ram]) begin 
            Device_host_addr[Ram] <= Device_host_addr[Ram]; 
        end
    end
    // not waiting for response ready from the network (should but... lazy)  

    ram_2p #(
      .Depth       ( MEM_SIZE / 4 ),
      .MemInitFile ( SRAMInitFile )
    ) u_ram (
    .clk_i       (clk_sys_in),
    .rst_ni      (rst_sys_in),

    .a_req_i     (Device_req_valid[Ram]),
    .a_we_i      (Device_wen[Ram]),
    .a_be_i      (Device_ben[Ram]),
    .a_addr_i    (Device_tgt_addr[Ram]),
    .a_wdata_i   (Device_wdata[Ram]),
    .a_rvalid_o  (Device_resp_valid[Ram]),
    .a_rdata_o   (Device_resp_data[Ram]),

    .b_req_i     (mem_instr_req),
    .b_we_i      (1'b0),
    .b_be_i      (4'b0),
    .b_addr_i    (core_instr_addr),
    .b_wdata_i   (32'b0),
    .b_rvalid_o  (),
    .b_rdata_o   (mem_instr_rdata)
    );

    // GPIO

    

    gpio #(
    .GpiWidth ( GPI_Width ),
    .GpoWidth ( GPO_Width )
  ) u_gpio (
    .clk_i          (clk_sys_in),
    .rst_ni         (rst_sys_in),

    .device_req_i   (Device_req_valid[Gpio]),
    .device_addr_i  (Device_tgt_addr[Gpio]),
    .device_we_i    (Device_wen[Gpio]),
    .device_be_i    (Device_ben[Gpio]),
    .device_wdata_i (Device_wdata[Gpio]),
    .device_rvalid_o(Device_resp_valid[Gpio]),
    .device_rdata_o (Device_resp_data[Gpio]),

    .gp_i, // assigned to pins
    .gp_o  // assign to pins
  );

    // UART (fast irq)

    uart #(
    .ClockFrequency ( CLK_FREQ )
  ) u_uart (
    .clk_i          (clk_sys_in),
    .rst_ni         (rst_sys_in),

    .device_req_i   (),
    .device_addr_i  (),
    .device_we_i    (),
    .device_be_i    (),
    .device_wdata_i (),
    .device_rvalid_o(),
    .device_rdata_o (),

    .uart_rx_i, // assign to pin
    .uart_irq_o     (uart_irq),
    .uart_tx_o // assigned to pin
  );

    // TIMER (with irq)

    timer #(
    .DataWidth    ( 32 ),
    .AddressWidth ( 32 )
    ) u_timer (
    .clk_i         (clk_sys_in),
    .rst_ni        (rst_sys_in),

    .timer_req_i   (),
    .timer_we_i    (),
    .timer_be_i    (),
    .timer_addr_i  (),
    .timer_wdata_i (),
    .timer_rvalid_o(),
    .timer_rdata_o (),
    .timer_err_o   (),
    .timer_intr_o  (timer_irq)
    );

    //


endmodule