module MEMWB
(
    RegWrite_in, 
    MemtoReg_in, 
    RegWrite_out, 
    MemtoReg_out, 
    read_alu_data_in, 
    read_addr_data_in, 
    read_alu_data_out, 
    read_addr_data_out, 
    EX_MEM_Rd_in, 
    MEM_WB_Rd_out, 
    clk_i, 
    rst_i,
	MemStall_in
);
	// WB control signal
	input RegWrite_in, MemtoReg_in;
	output RegWrite_out, MemtoReg_out;
	// data content
	input [31:0] read_alu_data_in, read_addr_data_in;
	output [31:0] read_alu_data_out, read_addr_data_out;
	input [4:0] EX_MEM_Rd_in;
	output [4:0] MEM_WB_Rd_out;
	// general signal
	// reset: async; set all register content to 0
	input clk_i, rst_i;
	input MemStall_in;
	
	reg RegWrite_out, MemtoReg_out;
	reg [31:0] read_alu_data_out, read_addr_data_out;
	reg [4:0] MEM_WB_Rd_out;
	
	always @(posedge clk_i or posedge rst_i)
	begin
		if (rst_i == 1'b1)
		begin
			RegWrite_out <= 1'b0;
			MemtoReg_out <= 1'b0;
			read_alu_data_out <= 32'b0;
			read_addr_data_out <= 32'b0;
			MEM_WB_Rd_out <= 5'b0;
		end
		else if (MemStall_in == 1'b0) begin
			RegWrite_out <= RegWrite_in;
			MemtoReg_out <= MemtoReg_in;
			read_alu_data_out <= read_alu_data_in;
		    read_addr_data_out <= read_addr_data_in;
			MEM_WB_Rd_out <= EX_MEM_Rd_in;
		end
		
	end
	
endmodule
