module IFID
(
  clk_i,
  rst_i,
  IFID_instr_i,
  IFID_instr_o,
  stall_i,
  PC_current_i,
  PC_current_o,
  flush_i, 
  MemStall_in 
); 
input [31:0] IFID_instr_i; 
input clk_i;
input rst_i;
output reg [31:0] IFID_instr_o; 
input stall_i;
input [31:0] PC_current_i;
output reg [31:0] PC_current_o;
input flush_i;

input MemStall_in;
 

 
always@(posedge clk_i)  begin 
   if(rst_i == 1'b1) begin 
      IFID_instr_o <=32'b0; 
      PC_current_o <=32'b0;
   end 
  
   else if (flush_i == 1'b1) begin         
      IFID_instr_o <= 32'b0;
      PC_current_o <=32'b0;
   end 
   
   else if (stall_i == 1'b0 && MemStall_in == 1'b0 ) begin         
      IFID_instr_o <= IFID_instr_i;
      PC_current_o <= PC_current_i;
   end
end 

endmodule