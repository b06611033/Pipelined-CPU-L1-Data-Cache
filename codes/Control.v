module Control
(
    ALUOp_o,
    ALUSrc_o,
    RegWrite_o,
    MemWrite_o,
    MemRead_o,
    MemtoReg_o,
    Op_i,
    noop_i,
    branch_inst_o
);

input  [6:0]   Op_i;
output reg ALUSrc_o;
output reg [1:0]   ALUOp_o;
output reg RegWrite_o;
output reg MemRead_o;
output reg MemWrite_o;
output reg MemtoReg_o;
input noop_i;
output reg branch_inst_o;



always @(*) begin
    if (noop_i == 1'b1) begin
        ALUSrc_o = 1'b0;
        RegWrite_o = 1'b0;
        ALUOp_o = 2'b00;
        MemRead_o = 1'b0;
        MemWrite_o = 1'b0;
        MemtoReg_o = 1'b0;
        branch_inst_o = 1'b0;
    end
    else begin
         if (Op_i == 7'b0110011) begin
             ALUSrc_o = 1'b0;
         end
         else begin
             ALUSrc_o = 1'b1;
         end

         if (Op_i == 7'b0100011 || Op_i == 7'b1100011 ) begin
             RegWrite_o = 1'b0;
         end
         else begin
             RegWrite_o = 1'b1;
         end

         
         if (Op_i == 7'b0110011) begin
             ALUOp_o = 2'b10;
         end
         else begin
             ALUOp_o = 2'b01;    //b01 is immediate type
         end

         
         if (Op_i == 7'b0000011) begin
             MemRead_o = 1'b1;
         end
         else begin
             MemRead_o = 1'b0;
         end

         
         if (Op_i == 7'b0100011) begin
             MemWrite_o = 1'b1;
         end
         else begin
             MemWrite_o = 1'b0;
         end

         
         if (Op_i == 7'b0000011) begin
             MemtoReg_o = 1'b1;
         end
         else begin
             MemtoReg_o = 1'b0;
         end

          if (Op_i == 7'b1100011) begin
             branch_inst_o = 1'b1;
         end
         else begin
             branch_inst_o = 1'b0;
         end
    end
end

endmodule




