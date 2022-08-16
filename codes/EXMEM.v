module EXMEM
( 
    RegWrite_in, 
    MemtoReg_in,
    MemRead_in, 
    MemWrite_in,   
    RegWrite_out, 
    MemtoReg_out,    
    MemRead_out, 
    MemWrite_out,  
    ALU_result_in, 
    ALU_result_out,
    reg_read_data_2_in,  
    reg_read_data_2_out, 
    ID_EX_Rd_in, 
    EX_MEM_Rd_out, 
    clk_i, 
    rst_i,
	MemStall_in
);
	
	// WB control signal
	input RegWrite_in, MemtoReg_in;
	output RegWrite_out, MemtoReg_out;
	// MEM control signal
	input  MemRead_in, MemWrite_in;
	output MemRead_out, MemWrite_out;

	input MemStall_in;
	
	//  data content
	input [31:0] ALU_result_in, reg_read_data_2_in;
	output [31:0] ALU_result_out, reg_read_data_2_out;
	input [4:0] ID_EX_Rd_in;
	output [4:0] EX_MEM_Rd_out;
	// general signal
	// reset: async; set all register content to 0
	input clk_i, rst_i;

	reg RegWrite_out, MemtoReg_out;
	reg  MemRead_out, MemWrite_out;
	reg [31:0] ALU_result_out, reg_read_data_2_out;
	reg [4:0] EX_MEM_Rd_out;

	always @(posedge clk_i or posedge rst_i) begin
		if (rst_i == 1'b1)
		begin
		  RegWrite_out <= 1'b0;
		  MemtoReg_out <= 1'b0;
		  MemRead_out <= 1'b0;
		  MemWrite_out <= 1'b0;
		  ALU_result_out <= 32'b0;
		  reg_read_data_2_out <= 32'b0;
		  EX_MEM_Rd_out <= 5'b0; 
		end

		else if (MemStall_in == 1'b0) begin
		  RegWrite_out <= RegWrite_in;
		  MemtoReg_out <= MemtoReg_in;
		  MemRead_out <= MemRead_in;
		  MemWrite_out <= MemWrite_in;
		  ALU_result_out <= ALU_result_in;
		  reg_read_data_2_out <= reg_read_data_2_in;
		  EX_MEM_Rd_out <= ID_EX_Rd_in;
		end

	end

endmodule