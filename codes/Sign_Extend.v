module Sign_Extend (
    data_i,
    funct3_i,
    Op_i,
    data_o
);

input  [31:0]  data_i;
input  [2:0]  funct3_i;
input  [6:0]  Op_i;
output  reg [31:0]  data_o;



//assign data_o = (funct3_i == 3'b101) ? { {27{data_i[4]}}, data_i[4:0] }: { {20{data_i[11]}}, data_i };
always @(*) begin
    if (funct3_i == 3'b101) begin
        data_o = { {27{data_i[24]}}, data_i[24:20]};      //srai
    end
    
    else if (funct3_i == 3'b000 && Op_i == 7'b0010011) begin
        data_o = { {20{data_i[31]}}, data_i[31:20]};     //addi
    end

    else if (funct3_i == 3'b010 && Op_i == 7'b0000011 ) begin
        data_o = { {20{data_i[31]}}, data_i[31:20]};     //lw
    end

    else if (funct3_i == 3'b010 && Op_i == 7'b0100011) begin
        data_o = { {20{data_i[31]}},data_i[31:25], data_i[11:7]};    //sw
    end

    else if (funct3_i == 3'b000 && Op_i == 7'b1100011) begin
        data_o = { {20{data_i[31]}}, data_i[7], data_i[30:25], data_i[11:8]};    //beq
    end
    
end  
 

endmodule