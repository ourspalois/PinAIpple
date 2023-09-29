module top_fpga #(
    parameter int GPIWidth = 4,
    parameter int GPOWidth = 4
)(
    input logic clk, 
    input logic rst_sys_in,
    input logic uart_rx,
    output logic uart_tx, 
    input logic [GPIWidth-1:0] gp_i, 
    output logic [GPOWidth-1:0] gp_o,
    //CHIP
    output logic clk_i, 
    //output logic io_out, 
    //output logic io_in, 
	output logic CBL0, CBLEN0, CSL0, CWL0, inference, read_8, load_mem, read_out, stoch_log,
	output logic [7:0] adr_full_col_in,		//adr for array_col + mem_col  
	output logic [7:0] adr_full_row_in,		//adr for array_row + mem_row
	input logic DATA_out [3:0]
);

    //assign io_out = '0;
    //assign io_in = '1;
    logic low_freq_clk ; 

    int counter = 0 ; 
    always_ff @( posedge(clk) ) begin : CLK_DIVISOR
        if (counter == 49) begin
            counter <= 0;
            low_freq_clk <= ~low_freq_clk;
        end else begin
            counter <= counter + 1;
        end
    end

    assign gp_o[3] = gp_i[3];
    logic uart_tx_1 ; 
    assign uart_tx = ~uart_tx_1 ;

    assign clk_i = low_freq_clk; 
    pinaipple_system #(
        .GPIWidth(GPIWidth),
        .GPOWidth(GPOWidth)
    ) u_pinaipple_system (
        .clk_sys_in(low_freq_clk),
        .rst_sys_in(~rst_sys_in), // active low reset
        .uart_rx_i(uart_rx),
        .uart_tx_o(uart_tx_1),
        .gp_i({ 1'b0, gp_i[2:0]}),
        .gp_o({ 1'b0, gp_o[2:0]}),
        //accelerator
        .CBL(CBL0),
        .CBLEN(CBLEN0),
        .SL_signal(CSL0),
        .WL_signal(CWL0), 
        .inference(inference), 
        .read_8(read_8), 
        .load_mem(load_mem),
        .read_out(read_out),
        .stoch_log(stoch_log),
        .addr_col(adr_full_col_in), 
        .addr_row(adr_full_row_in),
        .bit_out(DATA_out)

    );
    
endmodule
