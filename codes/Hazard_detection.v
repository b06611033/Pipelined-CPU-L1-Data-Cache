module Hazard_detection 
(EX_RD_in, rs1_in, rs2_in, MemRead_in, PCWrite_out, noop_out, stall_out);

input [4:0] EX_RD_in, rs1_in, rs2_in;
input MemRead_in;
output PCWrite_out, noop_out, stall_out;
wire equal_rd_rs1,equal_rd_rs2;
assign equal_rd_rs1=(EX_RD_in==rs1_in)?1:0;
assign equal_rd_rs2=(EX_RD_in==rs2_in)?1:0;
reg PCWrite_out, noop_out, stall_out;
	
always@(MemRead_in or equal_rd_rs1 or equal_rd_rs2) begin
	if(MemRead_in && (equal_rd_rs1 || equal_rd_rs2)) begin 
			PCWrite_out<=0;noop_out<=1;stall_out<=1; 
	end
	else begin 
			PCWrite_out<=1;noop_out<=0;stall_out<=0;
	end
end
endmodule