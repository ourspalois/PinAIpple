module top_apollo #(
    parameter int GPIWidth = 8,
    parameter int GPOWidth = 8
)(
    input logic clk, 
    input logic rst_sys_in,
    input logic uart_rx,
    input logic uart_tx, 
    input logic [GPIWidth-1:0] gp_i, 
    output logic [GPOWidth-1:0] gp_o,
    //CHIP
    output logic clk_i, 
    output logic iO_clk_i,
	output logic CBL0, CBLEN0, CSL0, CWL0,
    output logic io_CBL0, io_CBLEN0, io_CSL0, io_CWL0,
	output logic [1:0] instructions_in,		// // "11" form and prog, "10" read_mem, "01" read_reg, "00" inference
    output logic [1:0] io_instructions_in,
	output logic [5-1:0] adr_full_col_in,		//adr for array_col + mem_col  
    output logic [5-1:0] io_adr_full_col_in,
	output logic [5-1:0] adr_full_row_in,		//adr for array_row + mem_row
    output logic [5-1:0] io_adr_full_row_in,
	//output logic [2**Nword-1:0] DATA_out [2**Narray-1:0] 		//data out
	input logic DATA_out [2**2-1:0], 
    output logic [2**2-1:0] io_DATA_out
);

    assign iO_clk_i = '0;
    assign io_CBL0 = '0;
    assign io_CBLEN0 = '0;
    assign io_CSL0 = '0;
    assign io_CWL0 = '0;
    assign io_instructions_in = '0;
    assign io_adr_full_col_in = '0;
    assign io_adr_full_row_in = '0;
    assign io_DATA_out = 4'b1111;

    assign clk_i = clk; 
    pinaipple_system #(
        .GPIWidth(GPIWidth),
        .GPOWidth(GPOWidth)
    ) u_pinaipple_system (
        .clk_sys_in(clk),
        .rst_sys_in(rst_sys_in),
        .uart_rx_i(uart_rx),
        .uart_tx_o(uart_tx),
        .gp_i(gp_i),
        .gp_o(gp_o),
        //accelerator
        .CBL(CBL0),
        .CBLEN(CBLEN0),
        .CSL(CSL0),
        .CWL(CWL0), 
        .instructions(instructions_in),

        .addr_col(adr_full_col_in), 
        .addr_row(adr_full_row_in),
        .bit_out(DATA_out)

    );
    
endmodule
