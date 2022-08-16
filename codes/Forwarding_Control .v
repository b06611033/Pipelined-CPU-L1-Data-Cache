module Forwarding_Control 
(
    MEM_Rd, WB_Rd, EX_rs1, EX_rs2, WB_RegWrite, MEM_RegWrite, ForwardA, ForwardB
);
	input [4:0] MEM_Rd, WB_Rd, EX_rs1, EX_rs2;
	input MEM_RegWrite, WB_RegWrite;
	output [1:0] ForwardA, ForwardB;
	reg [1:0] ForwardA, ForwardB;
	
	wire equal_MEM_rs1,equal_MEM_rs2,equal_WB_rs1,equal_WB_rs2;
	wire nonzero_MEM_rd,nonzero_WB_rd;
	assign nonzero_MEM_rd=(MEM_Rd==0)?0:1;
	assign nonzero_WB_rd=(WB_Rd==0)?0:1;
	assign equal_MEM_rs1=(MEM_Rd==EX_rs1)?1:0;
	assign equal_MEM_rs2=(MEM_Rd==EX_rs2)?1:0;
	assign equal_WB_rs1=(WB_Rd==EX_rs1)?1:0;
	assign equal_WB_rs2=(WB_Rd==EX_rs2)?1:0;
	

	always@ (MEM_RegWrite or WB_RegWrite or nonzero_MEM_rd or nonzero_WB_rd or equal_MEM_rs1
	or equal_MEM_rs2 or equal_WB_rs1 or equal_WB_rs2 )
	begin
		if(MEM_RegWrite & nonzero_MEM_rd & equal_MEM_rs1)
			ForwardA<=2'b10;
		else if (WB_RegWrite & nonzero_WB_rd & equal_WB_rs1)
			ForwardA<=2'b01;
		else 
			ForwardA<=2'b00;
			
		if(MEM_RegWrite & nonzero_MEM_rd & equal_MEM_rs2)
			ForwardB<=2'b10;
		else if (WB_RegWrite & nonzero_WB_rd & equal_WB_rs2)
			ForwardB<=2'b01;
		else 
			ForwardB<=2'b00;
		
	end
endmodule