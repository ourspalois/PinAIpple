//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 

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
