//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 
// *************** LFSR Module

module LFSR_1bL #(parameter Nword = 3, M = 8) //
(       input logic clk,
        input logic inference,
        input logic load_lfsr,
        input logic stoch_log,
        input logic [2**Nword-1:0] seeds,
        output logic [M-1:0] rnd);

        logic feedback;
        assign feedback = rnd[7]^rnd[5]^rnd[4]^rnd[3] & 1'b1; //
        logic en_clk;
        assign en_clk = clk & ~stoch_log;

        always_ff@(posedge en_clk)
          if (load_lfsr) begin
           rnd <= seeds;
           end
          else if (inference) begin
           rnd <= {rnd[M-2:0],feedback};
           end
          else
           begin
           rnd <= rnd;
          end

endmodule
