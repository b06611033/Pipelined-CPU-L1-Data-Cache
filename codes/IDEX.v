module IDEX
(
  RegWrite_in,
  MemtoReg_in,
  MemRead_in, 
  MemWrite_in,
  ALUOp_in,
  ALUSrc_in,
  RegWrite_out, 
  MemtoReg_out,   
  MemRead_out, 
  MemWrite_out, 
  ALUSrc_out,    
  ALUOp_out,  
  reg_read_data_1_in, 
  reg_read_data_2_in, 
  reg_read_data_1_out, 
  reg_read_data_2_out, 
  immi_sign_extended_in, 
  immi_sign_extended_out, 
  funct3_in,
  funct7_in,
  funct3_out,
  funct7_out,
  Op_in,
  Op_out,
  RD_in, 
  RD_out,
  rs1_in,
  rs2_in,
  rs1_out,
  rs2_out,
  clk_i,
  rst_i,
  MemStall_in
);
	
//  WB control signal
input RegWrite_in, MemtoReg_in;
output RegWrite_out, MemtoReg_out;
//  MEM control signal
input MemRead_in, MemWrite_in;
output MemRead_out, MemWrite_out;
// EX control signal
input  ALUSrc_in;
input [1:0] ALUOp_in;
output ALUSrc_out;
output [1:0] ALUOp_out;
// data content
input [31:0] reg_read_data_1_in, reg_read_data_2_in, immi_sign_extended_in;
output [31:0] reg_read_data_1_out, reg_read_data_2_out, immi_sign_extended_out;
//funct content
input [6:0] funct7_in;
input [2:0] funct3_in;
output [6:0] funct7_out;
output [2:0] funct3_out;
input [6:0] Op_in;
output [6:0] Op_out;
//address content
input [4:0] RD_in,rs1_in,rs2_in;
output [4:0] RD_out,rs1_out,rs2_out;
// general signal
// reset: async; set all register content to 0
input clk_i, rst_i;
input MemStall_in;
	
reg RegWrite_out, MemtoReg_out;
reg MemRead_out, MemWrite_out;
reg ALUSrc_out;
reg [1:0] ALUOp_out;
reg [31:0] reg_read_data_1_out, reg_read_data_2_out, immi_sign_extended_out;
reg [6:0] funct7_out;
reg [2:0] funct3_out;
reg [6:0] Op_out;
reg [4:0] RD_out,rs1_out,rs2_out;

always @(posedge clk_i or posedge rst_i) begin
		if (rst_i == 1'b1) begin
			RegWrite_out <= 1'b0;
			MemtoReg_out <= 1'b0;
			MemRead_out <= 1'b0;
			MemWrite_out <= 1'b0;
			RD_out <= 5'b0;
			rs1_out <= 5'b0;
			rs2_out <= 5'b0;
			ALUSrc_out <= 1'b0;
			ALUOp_out <= 2'b0;
			reg_read_data_1_out <= 32'b0;
			reg_read_data_2_out <= 32'b0;
			immi_sign_extended_out <= 32'b0;
      funct7_out <= 7'b0;
			funct3_out <= 3'b0;
			Op_out <= 7'b0;		
		end
		else if (MemStall_in == 1'b0) begin
			RegWrite_out <= RegWrite_in;
			MemtoReg_out <= MemtoReg_in;
			MemRead_out <= MemRead_in;
			MemWrite_out <= MemWrite_in;
			RD_out <= RD_in;
			rs1_out <= rs1_in;
			rs2_out <= rs2_in;
			ALUSrc_out <= ALUSrc_in;
			ALUOp_out <= ALUOp_in;
			reg_read_data_1_out <= reg_read_data_1_in;
			reg_read_data_2_out <= reg_read_data_2_in;
			immi_sign_extended_out <= immi_sign_extended_in;
      funct7_out <= funct7_in;
			funct3_out <= funct3_in;
			Op_out <= Op_in;
		
		end	
		
end	
	
endmodule