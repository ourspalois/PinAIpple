module decoder_left #(
    parameter Nword = 5
) (
    input logic [Nword-1:0] adr,
    input logic adr_0,
    input logic CWLE_in,
    output logic [2**Nword-1:0] CWLE_out
);

  assign CWLE_out = adr_0 ? (CWLE_in ? 32'b1 << adr : 32'b0) : 32'b0;  //  ??????????,

endmodule