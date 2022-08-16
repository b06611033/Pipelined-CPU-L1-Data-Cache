module Comparison_unit 
(
  rs1_data_in, 
  rs2_data_in, 
  comparison_out
);

input [31:0] rs1_data_in;
input [31:0] rs2_data_in;
output comparison_out;

assign comparison_out = rs1_data_in == rs2_data_in ? 1: 0; //1 if beq condition is satisfied


endmodule