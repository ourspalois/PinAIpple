//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 

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
