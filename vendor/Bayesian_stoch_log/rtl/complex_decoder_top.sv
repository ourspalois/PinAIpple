//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 

module complex_decoder_top #(
    parameter Nword = 6,
    Narray = 2,
    N = 8,
    M = 64,
    Nword_used = 3
) (
    input logic clk,
    input logic CBL,
    CBLEN,
    CSL,
    input logic inference,
    load_seed,
    read_1,
    read_8,
    load_mem,
    read_out,
    input logic stoch_log,
    input logic [2**Nword_used-1:0] seeds,
    input logic [N-1:0] adr_full_col,
    output logic [Nword+3:0] reg_lcs[2**Narray-1:0],
    output logic [2**Nword_used-1:0] rnd[2**Narray-1:0]
);


  // Decoder Base
  logic [2**Narray-1:0] selected_top;
  logic [2**Narray-1:0] CSL_in, CBLEN_in, CBL_in;
  assign selected_top = (inference | load_seed | read_out | (load_mem & (read_8 | read_1))) ? 4'b0 : (4'b1 << adr_full_col[N-1:N-Narray]);  // 
  assign CBLEN_in = inference ? 4'b0 : (CBLEN ? selected_top : 4'b0);
  assign CBL_in = inference ? 4'b0 : (CBL ? selected_top : 4'b0);
  assign CSL_in = inference ? 4'b0 : (CSL ? selected_top : 4'b0);
  logic [2**Narray-1:0] selected_lfsr;
  assign selected_lfsr = inference ? 4'b0 : (stoch_log ? 4'b0 : 4'b1 << adr_full_col[N-1:N-2]);

  logic [2**Nword_used-1:0] seed;
  assign seed = stoch_log ? 8'b0 : seeds;

  // LFSRs
  generate
    genvar i;
    for (i = 0; i < 2 ** Narray; i = i + 1) begin : col_lfsr
      LFSR_1bL #(Nword_used, 2 ** Nword_used) lfsr (
          clk,
          inference,
          selected_lfsr[i] & load_seed,
          stoch_log,
          seed,
          rnd[i]
      );
    end
  endgenerate

  // registres col
  reg [Nword+3:0] reg_lc[2**Narray-1:0];
  assign reg_lcs = reg_lc;
  always_ff @(posedge clk) begin
    // pour un array 4x4
    case (selected_top)
      4'b0001: begin
        reg_lc[0] <= {
          selected_top[0], CBLEN_in[0], CBL_in[0], CSL_in[0], adr_full_col[Nword-1:0]
        };  //
        reg_lc[1][Nword+3] <= {selected_top[1]};
        reg_lc[2][Nword+3] <= {selected_top[2]};
        reg_lc[3][Nword+3] <= {selected_top[3]};
      end

      4'b0010: begin
        reg_lc[1] <= {
          selected_top[1], CBLEN_in[1], CBL_in[1], CSL_in[1], adr_full_col[Nword-1:0]
        };  // 
        reg_lc[2][Nword+3] <= {selected_top[2]};
        reg_lc[3][Nword+3] <= {selected_top[3]};
        reg_lc[0][Nword+3] <= {selected_top[0]};
      end

      4'b0100: begin
        reg_lc[2] <= {
          selected_top[2], CBLEN_in[2], CBL_in[2], CSL_in[2], adr_full_col[Nword-1:0]
        };  // 
        reg_lc[1][Nword+3] <= {selected_top[1]};
        reg_lc[3][Nword+3] <= {selected_top[3]};
        reg_lc[0][Nword+3] <= {selected_top[0]};
      end

      4'b1000: begin
        reg_lc[3] <= {
          selected_top[3], CBLEN_in[3], CBL_in[3], CSL_in[3], adr_full_col[Nword-1:0]
        };  //
        reg_lc[1][Nword+3] <= {selected_top[1]};
        reg_lc[2][Nword+3] <= {selected_top[2]};
        reg_lc[0][Nword+3] <= {selected_top[0]};
      end
      4'b0000: reg_lc <= '{default: 0};
      default: reg_lc <= '{default: 0};
    endcase

  end



endmodule
