//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 

// this code has no rram sv behavioral module (for synthesis and P&R purposes)
`timescale 1ns / 1ps
//`include "RRAM_array.sv"

module Bayesian_stoch_log #(
    parameter Narray = 2,
    Nword = 6,
    M = 2 ** Nword,
    N = Narray + Nword,
    Nword_used = 3
)  //Narray: 1D array adress size, Nword: storage adr size
(
    input logic clk,
    input logic CBL,
    CBLEN,
    CSL,
    CWL,  // Control signals for forming programming and reading
    input logic inference,
    load_seed,
    read_1,
    read_8,
    load_mem,
    read_out,
    input logic [N-1:0] adr_full_col,		// Narray bits to adress the array colomns, Nword bits to adress memories clomns
    input logic [N-1:0] adr_full_row,		// Narray bits to adress the array rows, Nword bits to adress memories rows
    input logic stoch_log,                          // choice between stochastic or logarithmic computing 0 : stoch / 1 : log
    input logic [2**Nword_used-1:0] seeds,  // seeds for LFSR
    output logic [2**Narray-1:0] bit_out  // data out
);

  logic [2**Narray-1:0] CBL_in;  // for colomns of likelihood array
  logic [2**Narray-1:0] CBLEN_in;  // for colomns of likelihood array
  logic [2**Narray-1:0] CSL_in;  // for colomns of likelihood array
  logic [2**Narray-1:0] CWL_in;  // for lines of likelihood array
  logic [2**Narray-1:0] selected_top;  // out of CDT for array colomns adr
  logic [2**Narray-1:0] selected_left;  // out of CDL for array lines adr
  logic [2**Nword_used-1:0] rnd[2**Narray-1:0];  // random numbers buses
  wire [Nword+3:0] reg_lcs[2**Narray-1:0];  // output likelihood colomn registers


  // Likelihood Array Decoders 

  complex_decoder_top #(Nword, Narray, N, M) CDT (
      clk,
      CBL,
      CBLEN,
      CSL,
      inference,
      load_seed,
      read_1,
      read_8,
      load_mem,
      read_out,
      stoch_log,
      seeds,
      adr_full_col,
      reg_lcs,
      rnd
  );

  complex_decoder_left #(Narray, N) CDL (
      CWL,
      inference,
      read_1,
      read_8,
      adr_full_row[N-1:N-Narray],
      CWL_in,
      selected_left
  );


  //  Likelihoods Array generate

  wire bit_next[2**Narray:1][2**Narray:0];
  wire [2**Narray-1:0] bit_out2;
  wire [2**Nword_used-1:0] DATA_next[2**Narray:1][2**Narray:0];
  wire [2**Nword_used-1:0] reg_out[2**Narray-1:0];

  generate
    genvar i, j;  // 4*4 or 2**Narray * 2**Narray
    for (i = 1; i <= 2 ** Narray; i = i + 1) begin : row
      // every row has 2**Narray +1 wire
      assign DATA_next[i][0] = 8'b0;
      assign reg_out[i-1]    = DATA_next[i][2**Narray];
      assign bit_next[i][0]  = '1;  // prev 0
      assign bit_out2[i-1]   = bit_next[i][2**Narray];
      for (j = 1; j <= 2 ** Narray; j = j + 1) begin : col

        likelihood #(Nword, Nword_used) likelihood_cell_unit (
            .clk(clk),
            .bit_prev(bit_next[i][j-1]),
            .DATA_prev(DATA_next[i][j-1]),
            .reg_lcs(reg_lcs[j-1]),
            .CWL_in(CWL_in[i-1]),
            .inference(inference),
            .load_seed(load_seed),
            .read_1(read_1),
            .read_8(read_8),
            .load_mem(load_mem),
            .stoch_log(stoch_log),
            .read_out(read_out),
            .adr_l(adr_full_row[Nword-1:0]),
            .selected_left(selected_left[i-1]),
            .rnd(rnd[j-1]),
            .bit_next(bit_next[i][j]),
            .DATA_next(DATA_next[i][j])
        );

      end
    end
  endgenerate

  // Output registers 
  logic [2**Narray-1:0] DATA_out;
  register_out #(Narray, Nword_used) outputs (
      clk,
      read_out,
      reg_out,
      DATA_out
  );
  // Output
  assign bit_out = stoch_log ? DATA_out : bit_out2;

endmodule