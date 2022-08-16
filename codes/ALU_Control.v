module ALU_Control
(
    funct7_i,
    funct3_i,
    ALUOp_i,
    Op_i,
    ALUCtrl_o
);

input   [6:0]   funct7_i;
input   [2:0]   funct3_i;
input   [1:0]   ALUOp_i;
input   [6:0]   Op_i;
output  reg [2:0]   ALUCtrl_o;


always @(*) begin
    if (funct7_i == 7'b0000001 && ALUOp_i == 2'b10) begin
        ALUCtrl_o = 3'b000;             //mul
    end

    else if (funct7_i == 7'b0100000 && ALUOp_i == 2'b10 ) begin
        ALUCtrl_o = 3'b001;         //sub
    end

    else if (funct3_i == 3'b101) begin
        ALUCtrl_o = 3'b010;         //shift right
    end
    
    else if ( funct3_i == 3'b000 && funct7_i == 7'b0000000 && ALUOp_i == 2'b10) begin
        ALUCtrl_o =3'b100 ;        //add 
    end

    else if ( funct3_i == 3'b000 && Op_i == 7'b0010011 ) begin
        ALUCtrl_o =3'b100 ;        //addi 
    end

    else if ( funct3_i == 3'b010) begin
        ALUCtrl_o =3'b100 ;        //lw sw 
    end
    
    else if (funct3_i == 3'b111) begin
        ALUCtrl_o =3'b011 ;        //and
    end

    else if (funct3_i == 3'b100) begin
        ALUCtrl_o =3'b101 ;        //xor
    end

    else if (funct3_i == 3'b001) begin
        ALUCtrl_o =3'b110 ;        //sll
    end
    else if (funct3_i == 3'b110) begin
        ALUCtrl_o =3'b111 ;        //or
    end
end


endmodule

