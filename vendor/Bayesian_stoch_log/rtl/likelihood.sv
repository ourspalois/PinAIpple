//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 


// ******************** Likelihood Cell ******************************

module likelihood #(
    parameter Nword = 6,
    Nword_used = 3
) (
    input logic clk,
    input logic bit_prev,
    input logic [2**Nword_used-1:0] DATA_prev,
    input logic [Nword+3:0] reg_lcs,
    input logic CWL_in,
    input logic inference,
    load_seed,
    read_1,
    read_8,
    load_mem,
    stoch_log,
    read_out,
    input logic [Nword-1:0] adr_l,
    input logic selected_left,
    input logic [2**Nword_used-1:0] rnd,
    output logic bit_next,
    output logic [2**Nword_used-1:0] DATA_next
);

  logic [2**Nword-1:0] CBL, CBLEN, CSL, CWL;
  wire [2**Nword-1:0] DOUT, DIN, DINb;
  logic [2**(Nword-1)-1:0] CWLE, CWLO;
  logic CWL_in0, CBL_in0, CBLEN_in0, CSL_in0;
  logic adr_0;
  logic read;
  logic [2**Nword-1:0] DOUT0;

  assign read = ((read_1 | read_8) & adr_0);
  assign adr_0 = selected_left & reg_lcs[Nword+3];
  assign CWL_in0 = CWL_in & adr_0;
  assign CBL_in0 = reg_lcs[Nword+1] & adr_0;
  assign CBLEN_in0 = reg_lcs[Nword+2] & adr_0;
  assign CSL_in0 = reg_lcs[Nword] & adr_0;

  decoder_top #(Nword) DT (
      .adr(reg_lcs[Nword-1:0]),
      .CBLEN_in(CBLEN_in0),
      .CBL_in(CBL_in0),
      .CBLEN_out(CBLEN),
      .CBL_out(CBL)
  );
  decoder_bot #(Nword) DB (
      .adr(reg_lcs[Nword-1:0]),
      .read(read),
      .CSL_in(CSL_in0),
      .CSL_out(CSL)
  );
  decoder_right #(Nword - 1) DR (
      .adr(adr_l[Nword-1:1]),
      .adr_0(adr_l[0]),
      .CWLO_in(CWL_in0),
      .CWLO_out(CWLO)
  );
  decoder_left #(Nword - 1) DL (
      .adr(adr_l[Nword-1:1]),
      .adr_0(adr_l[0]),
      .CWLE_in(CWL_in0),
      .CWLE_out(CWLE)
  );

  assign DIN  = read ? 64'b1111111111111111111111111111111111111111111111111111111111111111 : 64'b0;
  assign DINb = 64'b0;

  MC_64x64_FULL_upd rram (
      .CBL  (CBL),
      .CBLEN(CBLEN),
      .CWLE (CWLE),
      .CWLO (CWLO),
      .DIN  (DIN),
      .DINb (DINb),
      .DOUT (DOUT),
      .CSL  (CSL)
  );

  assign DOUT0 = load_mem ? 64'b0 : DOUT >> 8 * reg_lcs[2:0];
  reg [2**Nword_used-1:0] reg_mem;
  always_ff @(posedge clk) begin
    if (load_mem) begin
      reg_mem <= 8'b0;
    end else if (read) reg_mem <= DOUT0[7:0];
    else reg_mem <= reg_mem;

  end
  wire [2**Nword_used-1:0] DATA_after_reg;
  assign DATA_after_reg = reg_mem;


  bot_logic #(8) BT (
      DATA_after_reg,
      rnd,
      reg_lcs[2:0],
      bit_prev,
      read_1,
      adr_0,
      stoch_log,
      DATA_prev,
      inference,
      DATA_next,
      bit_next
  );
  //bot_logic_log #(8) BTLog(clk, read_out, load_mem, read_8, adr_0, inference_en, stoch_log, DOUT0[7:0], DATA_prev, DATA_next);

endmodule
