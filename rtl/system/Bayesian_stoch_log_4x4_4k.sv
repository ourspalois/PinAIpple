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


// **************** Complex decoders "Top and Left" *** 

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

// ***********************************************************************

module complex_decoder_left #(
    parameter Narray = 2,
    N = 8
) (
    input logic CWL_left,
    input logic inference,
    read_1,
    read_8,
    input logic [Narray-1:0] adr_full_row,
    output logic [2**Narray-1:0] CWL_in,
    output logic [2**Narray-1:0] selected_left
);

  // Instructions
  assign read = read_1 | read_8;

  // Decoder
  assign selected_left = inference ? 4'b0 : (read ? 4'b1111 : 4'b1 << adr_full_row);
  assign CWL_in = inference ? 4'b0 : (CWL_left ? selected_left : 4'b0);




endmodule



// *************** Decoder Left with PRIORS

module complex_decoder_left_priors #(
    parameter Narray = 2,
    N = 8,
    Nword_used = 3
) (
    input logic clk,
    input logic CWL_left,
    input logic inference,
    read_1,
    read_8,
    load_seed,
    activ_priors,
    load_priors,
    stoch_log,
    input logic [Narray-1:0] adr_full_row,
    input logic [2**Nword_used-1:0] seed,
    priors,
    output logic [2**Narray-1:0] CWL_in,
    output logic [2**Narray-1:0] selected_left,
    output logic [2**Narray-1:0] priors_stoch,
    output logic [2**Nword_used-1:0] priors_log[2**Narray-1:0]
);

  reg [2**Nword_used-1:0] priors_stock[2**Narray-1:0];
  logic [N-1:0] rnd;
  logic [2**Narray-1:0] bit_out_gupta;


  // Instructions
  assign read = read_1 | read_8;

  // Decoder
  assign selected_left = inference ? 4'b0 : (read ? 4'b1111 : 4'b1 << adr_full_row);
  assign CWL_in = inference ? 4'b0 : (CWL_left ? selected_left : 4'b0);

  // Priors
  always_ff @(posedge clk) begin
    if (activ_priors && load_priors) begin
      case (selected_left)
        4'b0001: begin
          priors_stoch[0] <= priors;
        end
        4'b0010: begin
          priors_stoch[1] <= priors;
        end
        4'b0100: begin
          priors_stoch[2] <= priors;
        end
        4'b1000: begin
          priors_stoch[3] <= priors;
        end
        default: priors_stoch <= '{default: 0};
      endcase
    end
    if (activ_priors && ~load_priors) begin
      priors_stock <= priors_stock;
    end
    if (~activ_priors) priors_stock <= '{default: 0};
  end

  // Gupta for stochastic

  LFSR_1bL #(Nword_used, 2 ** Nword_used) lfsr_left (
      clk,
      inference,
      activ_priors & load_seed,
      stoch_log,
      seed,
      rnd
  );
  generate
    genvar i;
    for (i = 0; i < 2 ** Narray; i = i + 1) begin : row_gupta
      Gupta #(N) gupta_left (
          .rnd(rnd),
          .proba(priors_stock[i]),
          .probabit(bit_out_gupta[i])
      );
    end
  endgenerate



  // Output for stoch
  assign priors_stoch = stoch_log ? 4'b0 : bit_out_gupta;



  // Output for log
  assign priors_log   = stoch_log ? priors_stock : '{default: 0};


endmodule




// *************** LFSR Module

module LFSR_1bL #(
    parameter Nword = 3,
    M = 8
)  // 
(
    input logic clk,
    input logic inference,
    input logic load_lfsr,
    input logic stoch_log,
    input logic [2**Nword-1:0] seeds,
    output logic [M-1:0] rnd
);

  logic feedback;
  assign feedback = rnd[7] ^ rnd[5] ^ rnd[4] ^ rnd[3] & 1'b1;  // 
  logic en_clk;
  assign en_clk = clk & ~stoch_log;

  always_ff @(posedge en_clk)
    if (load_lfsr) begin
      rnd <= seeds;
    end else if (inference) begin
      rnd <= {rnd[M-2:0], feedback};
    end else begin
      rnd <= rnd;
    end

endmodule

// ************** Output registers *****************

module register_out #(
    parameter Narray = 2,
    Nword = 3
) (
    input logic clk,
    read_out,
    input logic [2**Nword-1:0] data_in[2**Narray-1:0],
    output logic [2**Narray-1:0] data_out
);

  reg [2**Nword-1:0] data_in_reg[2**Narray-1:0];
  logic [Nword:0] cpt;
  logic choix;
  compteur #(Narray, Nword) compt (
      clk,
      read_out,
      cpt
  );
  //generate
  //genvar i; 
  //for ( i=0; i<2**Narray; i=i+1) begin : register
  always @(posedge clk) begin
    if (read_out && choix && cpt < 4'b1000) begin
      //cpt <= cpt+1;
      data_out[0] <= data_in_reg[0][2**Nword-1-cpt];
      data_out[1] <= data_in_reg[1][2**Nword-1-cpt];
      data_out[2] <= data_in_reg[2][2**Nword-1-cpt];
      data_out[3] <= data_in_reg[3][2**Nword-1-cpt];
      //data_in_reg[i] <= data_in_reg[i] << 1;
    end else begin
      data_out <= '{default: 0};
      data_in_reg <= data_in;
      choix <= 1;
      //cpt <= '0;
    end
    if (cpt == 4'b1110 && choix) choix <= 0;
  end
  //end 
  //endgenerate

endmodule

module compteur #(
    parameter Narray = 2,
    Nword = 3
) (
    input logic clk,
    read_out,
    output [Nword:0] cpt
);
  reg [Nword:0] cpt_reg;
  assign cpt = cpt_reg;
  always @(posedge clk) begin
    if (read_out) cpt_reg <= cpt_reg + 1;
    else cpt_reg <= 4'b1110;
  end
endmodule

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

//****************************** Stochastic computing **********************
module bot_logic #(
    parameter M = 8
) (
    input logic [M-1:0] DATA,
    input logic [M-1:0] rnd,
    input logic [$clog2(M)-1:0] adr_c,
    input logic bit_prev,
    select,
    adr_0,
    input logic stoch_log,
    input logic [M-1:0] DATA_prev,
    input logic inference,
    output logic [M-1:0] DATA_next,
    output logic bit_next
);

  logic probaBit, bit_prev0;
  assign bit_prev0 = stoch_log ? 1'b0 : bit_prev;
  Gupta #(M) gupta (
      .rnd(rnd),
      .proba(DATA),
      .probabit(probaBit)
  );

  logic selecting_out;
  selecting #(M) sel (
      .adr(adr_c),
      .proba(DATA),
      .select(select),
      .adr_0(adr_0),
      .probabit(probaBit),
      .selecting_out(selecting_out)
  );

  assign bit_next = selecting_out & bit_prev0;

  logic [M-1:0] DATA_auth;
  assign DATA_auth = inference ? DATA : 8'b0;
  additions #(M) add (
      .proba1(DATA_auth),
      .proba2(DATA_prev),
      .proba_out(DATA_next)
  );



endmodule

module bot_logic_log #(
    parameter M = 8
) (
    input logic clk,
    input logic read_out,
    prog,
    read_mem,
    adr_0,
    inference_en,
    stoch_log,
    input logic [M-1:0] DATA,
    DATA_prev,
    output logic [M-1:0] DATA_next
);
  reg [M-1:0] reg_mem;
  logic [M-1:0] DATA_auth;
  logic clk_en;

  assign en_clk = clk & stoch_log;
  always_ff @(posedge clk_en) begin
    if (prog || (read_mem && ~adr_0)) begin
      if (~(read_out)) reg_mem <= 8'b0;
    end else if ((read_mem && adr_0) || inference_en) reg_mem <= DATA;
  end

  assign DATA_auth = read_out ? reg_mem[M-1:0] : 8'b0;
  additions #(M) add (
      .proba1(DATA_auth),
      .proba2(DATA_prev),
      .proba_out(DATA_next)
  );

endmodule



//Gupta module
module Gupta #(
    parameter M = 8
)  //???????????????????
(
    input logic [M-1:0] rnd,
    input logic [M-1:0] proba,
    output logic probabit
);

  logic [M-2:0] Ni;
  logic [M-2:0] Oi;

  //Bloc 1
  assign Ni[0] = ~rnd[M-1];
  assign Oi[0] = rnd[M-1] & proba[M-1];

  //Bloc de base
  generate
    genvar i;
    for (i = 1; i <= M - 2; i = i + 1) begin
      assign Ni[i] = (~rnd[M-i-1]) & Ni[i-1];
      assign Oi[i] = Oi[i-1] | (proba[M-i-1] & Ni[i-1] & rnd[M-i-1]);
    end
  endgenerate

  //Bloc final
  assign probabit = Oi[M-2] | (proba[0] & rnd[0] & Ni[M-2]);

endmodule

module selecting #(
    parameter M = 8
) (
    input logic [$clog2(M)-1:0] adr,
    input logic [M-1:0] proba,
    input logic select,
    input logic adr_0,
    input logic probabit,
    output logic selecting_out
);

  assign selecting_out = select ? (adr_0 ? proba[adr] : 1'b1) : probabit;


endmodule



//************************* Log computation *************************


// Additions calcul log

module additions #(
    parameter M = 8
) (
    input  logic [M-1:0] proba1,
    proba2,
    output logic [M-1:0] proba_out
);
  logic [  M:0] d1;
  logic [M-1:0] overflow;
  assign overflow = 8'b11111111;

  assign d1 = proba1 + proba2;
  assign proba_out = d1[M] ? overflow : d1[M-1:0];

endmodule



//************************* Memory Decoders *************************

module decoder_bot #(
    parameter Nword = 6
) (
    input logic [Nword-1:0] adr,
    input logic read,
    input logic CSL_in,
    output logic [2**Nword-1:0] CSL_out
);

  logic [7:0] inter;
  logic [2**Nword-1:0] inter2;
  assign inter = read ? (CSL_in ? 8'b1 << adr[2:0] : 8'b0) : 8'b0;  // 
  assign inter2 = {
    inter[7],
    inter[7],
    inter[7],
    inter[7],
    inter[7],
    inter[7],
    inter[7],
    inter[7],
    inter[6],
    inter[6],
    inter[6],
    inter[6],
    inter[6],
    inter[6],
    inter[6],
    inter[6],
    inter[5],
    inter[5],
    inter[5],
    inter[5],
    inter[5],
    inter[5],
    inter[5],
    inter[5],
    inter[4],
    inter[4],
    inter[4],
    inter[4],
    inter[4],
    inter[4],
    inter[4],
    inter[4],
    inter[3],
    inter[3],
    inter[3],
    inter[3],
    inter[3],
    inter[3],
    inter[3],
    inter[3],
    inter[2],
    inter[2],
    inter[2],
    inter[2],
    inter[2],
    inter[2],
    inter[2],
    inter[2],
    inter[1],
    inter[1],
    inter[1],
    inter[1],
    inter[1],
    inter[1],
    inter[1],
    inter[1],
    inter[0],
    inter[0],
    inter[0],
    inter[0],
    inter[0],
    inter[0],
    inter[0],
    inter[0]
  };
  assign CSL_out = read ? inter2 : (CSL_in ? 64'b1 << adr : 64'b0);

endmodule

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


