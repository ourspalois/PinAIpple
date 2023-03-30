module decoder_right #(
    parameter Nword = 5
) (
    input logic [Nword-1:0] adr,
    input logic adr_0,
    input logic CWLO_in,
    output logic [2**Nword-1:0] CWLO_out
);

  assign CWLO_out = ~adr_0 ? (CWLO_in ? 32'b1 << adr : 32'b0) : 32'b0;  // ??????????????

endmodule