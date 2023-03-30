//**********************************************************************
//**********  Bayesian design with likelihood array of 4k rram *********
//**********************************************************************
/** Developed by Tifenn adapted by Kamel and Clement**/

// Updated for 6/12/21 Run, 4x4 array of 64x64 RRAM 

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