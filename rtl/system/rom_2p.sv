// this is the arbiter to allow the data bus to read the rodata segment of the rom
// the bus has priority over the core


module rom_2p #(
    DATA_WIDTH = 32,
    ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_ni,
    // core side
    input logic core_instr_req_i, 
    input logic [ADDR_WIDTH-1:0] core_instr_addr_i,
    output logic core_gnt_o, 
    output logic core_instr_valid_o,
    output logic [DATA_WIDTH-1:0] core_instr_data_o,

    // bus side 
    input logic bus_req_i,
    input logic [ADDR_WIDTH-1:0] bus_addr_i,
    output logic [DATA_WIDTH-1:0] bus_resp_data_o,
    output logic bus_resp_valid_o,

    // rom side
    output logic mem_req_o,
    output logic [ADDR_WIDTH-1:0] mem_addr_o,
    input logic [DATA_WIDTH-1:0] mem_data_i
); 
    int sel_req ;
    int sel_resp ; 

    always_comb begin  // request network
        if(rst_ni == 0) begin
            mem_req_o = '0 ;
            core_gnt_o = '0 ;
            mem_addr_o = '0 ;
            sel_req = 0 ;
        end else begin
        if(bus_req_i) begin
            mem_req_o = bus_req_i ;
            mem_addr_o = bus_addr_i | 32'h00100000 ;
            core_gnt_o = '0 ;
            sel_req = 1 ;
        end else if(core_instr_req_i) begin
            mem_req_o = core_instr_req_i ;
            mem_addr_o = core_instr_addr_i ;
            core_gnt_o = '1 ;
            sel_req = 2 ;
        end else begin
            mem_req_o = '0 ;
            core_gnt_o = '0 ;
            mem_addr_o = '0 ;
            sel_req = 0 ;
        end
        end
    end

    always_ff @( posedge(clk_i) ) begin 
        sel_resp = sel_req ;
    end
    /* verilator lint_off LATCH */
    always_comb begin  // response network
        if(sel_resp == 1) begin
        bus_resp_data_o = mem_data_i ;
        bus_resp_valid_o = '1 ;
        core_instr_valid_o = '0 ;
        end else if(sel_resp == 2) begin
        core_instr_data_o = mem_data_i ;
        core_instr_valid_o = '1;
        bus_resp_valid_o = '0 ;
        end else begin
        bus_resp_data_o = '0 ;
        bus_resp_valid_o = '0 ;
        core_instr_valid_o = '0 ;
        end
    end
    
endmodule