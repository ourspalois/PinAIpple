
module decoder_top #(
    parameter Nword = 6
) (
    input logic [Nword-1:0] adr,
    input logic CBLEN_in,
    input logic CBL_in,
    output logic [2**Nword-1:0] CBLEN_out,
    output logic [2**Nword-1:0] CBL_out
);

  assign CBLEN_out = CBLEN_in ? 64'b1 << adr : 64'b0;  //???????????????????
  assign CBL_out   = CBL_in ? 64'b1 << adr : 64'b0;  //?????????????????

endmodule