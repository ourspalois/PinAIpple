//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 


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
