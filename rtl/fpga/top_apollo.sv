module top_apollo #(
    parameter int GPIWidth = 8,
    parameter int GPOWidth = 8
)(
    input logic clk, 
    input logic rst_sys_in,
    input logic uart_rx,
    input logic uart_tx,
    input logic [GPIWidth-1:0] gp_i,
    output logic [GPOWidth-1:0] gp_o
);

    pinaipple_system #(
        .GPIWidth(GPIWidth),
        .GPOWidth(GPOWidth)
    ) u_pinaipple_system (
        .clk_sys_in(clk),
        .rst_sys_in(rst_sys_in),
        .uart_rx_i(uart_rx),
        .uart_tx_o(uart_tx),
        .gp_i(),
        .gp_o()
    );
    
endmodule
