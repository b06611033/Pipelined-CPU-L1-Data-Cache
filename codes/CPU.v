module CPU
(
    clk_i, 
    rst_i,
    start_i,
    mem_data_i, 
    mem_ack_i,     
    mem_data_o, 
    mem_addr_o,     
    mem_enable_o, 
    mem_write_o
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

input [255:0] mem_data_i;
input mem_ack_i;
output [255:0] mem_data_o;
output [31:0] mem_addr_o;
output mem_enable_o;
output mem_write_o;

//wire in all stage
wire Mem_stall;

//wires in IF stage
wire [31:0] IFinstruction;
wire [31:0] PC_plus4;
wire [31:0] IFPC_current;
wire [31:0] PC_nxt;
wire PCWrite;


//wires in ID stage
wire [31:0] IDinstruction;
wire [6:0] IDOp;
wire [4:0] IDrd;
wire [4:0] IDrs1;
wire [4:0] IDrs2;
wire [2:0] IDfunct3;
wire [6:0] IDfunct7;
wire [31:0] imme_in;

wire signed [31:0] IDDatabus1;    //for rs1
wire signed [31:0] IDDatabus2;    //for rs2
wire [31:0] IDimme_out;    //change to signed for branch address


wire [1:0] IDALUOp;
wire IDALUSrc;
wire IDRegWrite;   //also pipeline register input in EXMEM
wire IDMemtoReg;   //also pipeline register input in EXMEM
wire IDMemRead;    //also pipeline register input in EXMEM
wire IDMemWrite;   //also pipeline register input in EXMEM

wire noop;
wire stall;
wire branch_inst;
wire comparison_result;
wire branch_dec;   //branch decision
wire signed [31:0] branch_PC;
wire signed [31:0] branch_address;   //branch pc + current pc

wire [31:0] IDPC_current;    


//wires in EX stage
wire [2:0] ALUCtrl;      //output from ALU Control
wire signed [31:0] alu_in2;     //output from mux
wire signed [31:0] EXalu_out;

wire [1:0] EXALUOp;
wire EXALUSrc;
wire EXRegWrite;
wire EXMemtoReg;
wire EXMemRead;
wire EXMemWrite;

wire [31:0] EXimme_out;
wire [31:0] EXDatabus1;    
wire [31:0] EXDatabus2;     //also pipeline register input in EXMEM

wire [4:0] EXrd;
wire [4:0] EXrs1;
wire [4:0] EXrs2;

wire [2:0] EXfunct3;
wire [6:0] EXfunct7;
wire [6:0] EXOp;

wire signed [31:0] MUXrs1_out;
wire signed [31:0] MUXrs2_out;
wire [1:0] ForwardA;
wire [1:0] ForwardB;

// wires in MEM stage
wire MEMRegWrite;
wire MEMMemtoReg;
wire MEMMemRead;
wire MEMMemWrite;
wire signed [31:0] MEMMem_out;
wire signed [31:0] MEMalu_out;
wire signed [31:0] MEMDatabus2;

wire [4:0] MEMrd;

//wires in WB stage
wire WBRegWrite;
wire WBMemtoReg;
wire [4:0] WBrd;
wire signed [31:0] WBalu_out;
wire signed [31:0] WBMem_out;
wire signed [31:0] MUXWB_out;



//IF stage

Adder Add_PC(
    .data1_in   (IFPC_current),
    .data2_in   (32'd4),
    .data_o     (PC_plus4)
);


PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (PC_nxt),
    .pc_o       (IFPC_current),
    .PCWrite_i (PCWrite),
    .stall_i(Mem_stall)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (IFPC_current), 
    .instr_o    (IFinstruction)
);

IFID IFID(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .IFID_instr_i (IFinstruction),
  .IFID_instr_o (IDinstruction),
  .PC_current_i(IFPC_current),
  .PC_current_o(IDPC_current),
  .stall_i (stall),
  .flush_i (branch_dec),
  .MemStall_in(Mem_stall)
);


//ID stage


assign IDOp = IDinstruction[6:0];
assign IDrd = IDinstruction[11:7];  
assign IDfunct3 = IDinstruction[14:12];    
assign IDrs1 = IDinstruction[19:15]; 
assign IDrs2 = IDinstruction[24:20]; 
assign IDfunct7 = IDinstruction[31:25];
assign imme_in = IDinstruction[31:0];




Control Control(
    .Op_i       (IDOp),
    .ALUOp_o    (IDALUOp),
    .ALUSrc_o   (IDALUSrc),
    .RegWrite_o (IDRegWrite),
    .MemWrite_o(IDMemWrite),
    .MemRead_o(IDMemRead),
    .MemtoReg_o(IDMemtoReg),
    .noop_i(noop),
    .branch_inst_o(branch_inst)
);



Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (IDrs1),
    .RS2addr_i   (IDrs2),
    .RDaddr_i   (WBrd), 
    .RDdata_i   (MUXWB_out),
    .RegWrite_i (WBRegWrite),   
    .RS1data_o   (IDDatabus1), 
    .RS2data_o   (IDDatabus2) 
);

Sign_Extend Sign_Extend(
    .data_i     (imme_in),
    .Op_i       (IDOp),
    .funct3_i   (IDfunct3),
    .data_o     (IDimme_out)
);

IDEX  IDEX
(
  .RegWrite_in (IDRegWrite),
  .MemtoReg_in (IDMemtoReg),
  .MemRead_in (IDMemRead), 
  .MemWrite_in (IDMemWrite),
  .ALUOp_in (IDALUOp),
  .ALUSrc_in (IDALUSrc),
  .RegWrite_out (EXRegWrite), 
  .MemtoReg_out (EXMemtoReg),   
  .MemRead_out (EXMemRead), 
  .MemWrite_out (EXMemWrite), 
  .ALUSrc_out (EXALUSrc),    
  .ALUOp_out (EXALUOp),  
  .reg_read_data_1_in (IDDatabus1), 
  .reg_read_data_2_in (IDDatabus2), 
  .reg_read_data_1_out (EXDatabus1), 
  .reg_read_data_2_out (EXDatabus2), 
  .immi_sign_extended_in (IDimme_out), 
  .immi_sign_extended_out (EXimme_out), 
  .funct3_in (IDfunct3),
  .funct7_in (IDfunct7),
  .funct3_out (EXfunct3),
  .funct7_out (EXfunct7),
  .Op_in (IDOp),
  .Op_out (EXOp),
  .RD_in (IDrd), 
  .RD_out (EXrd),
  .rs1_in(IDrs1),
  .rs2_in(IDrs2),
  .rs1_out(EXrs1),
  .rs2_out(EXrs2),
  .MemStall_in(Mem_stall),
  .clk_i (clk_i),
  .rst_i (rst_i)
);

Hazard_detection Hazard_detection  (
.EX_RD_in(EXrd), .rs2_in(IDrs1), 
.rs1_in(IDrs2), .MemRead_in(EXMemRead), 
.PCWrite_out(PCWrite), .noop_out(noop), .stall_out(stall)
);

Comparison_unit Comparison_unit (
.rs1_data_in(IDDatabus1), .rs2_data_in(IDDatabus2), .comparison_out(comparison_result)
);

Branch_decision Branch_decision (
  .branch_inst_in(branch_inst), .comparison_in(comparison_result), .decision_out(branch_dec)
);

Shift_left Shift_left(                    //for branch address
   .shift_in(IDimme_out), .shift_out(branch_PC)
) ;

Adder Add_address(
    .data1_in   (branch_PC),
    .data2_in   (IDPC_current),
    .data_o     (branch_address)
);

MUX32 MUX_PCSrc(
    .data1_i    (PC_plus4),
    .data2_i    (branch_address),
    .select_i   (branch_dec),
    .data_o     (PC_nxt)
);
//EX stage


MUX32 MUX_ALUSrc(
    .data1_i    (MUXrs2_out),
    .data2_i    (EXimme_out),
    .select_i   (EXALUSrc),
    .data_o     (alu_in2)
);

ALU ALU(
    .data1_i    (MUXrs1_out),
    .data2_i    (alu_in2),
    .ALUCtrl_i  (ALUCtrl),
    .data_o     (EXalu_out),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct7_i   (EXfunct7),
    .funct3_i   (EXfunct3),  
    .ALUOp_i    (EXALUOp),
    .Op_i       (EXOp),
    .ALUCtrl_o  (ALUCtrl)
);

EXMEM EXMEM
( 
    .RegWrite_in(EXRegWrite), 
    .MemtoReg_in(EXMemtoReg),
    .MemRead_in(EXMemRead), 
    .MemWrite_in(EXMemWrite),   
    .RegWrite_out(MEMRegWrite), 
    .MemtoReg_out(MEMMemtoReg),    
    .MemRead_out(MEMMemRead), 
    .MemWrite_out(MEMMemWrite),  
    .ALU_result_in(EXalu_out), 
    .ALU_result_out(MEMalu_out),
    .reg_read_data_2_in(MUXrs2_out),  
    .reg_read_data_2_out(MEMDatabus2),    //should be memrs2_out but i dont want to change
    .ID_EX_Rd_in(EXrd), 
    .EX_MEM_Rd_out(MEMrd), 
    .MemStall_in(Mem_stall),
    .clk_i(clk_i), 
    .rst_i(rst_i)
);

MUX_Foward MUX_rs1_data (.in00(EXDatabus1), .in01(MUXWB_out), .in10(MEMalu_out), .mux_out(MUXrs1_out), .control(ForwardA));
MUX_Foward MUX_rs2_data (.in00(EXDatabus2), .in01(MUXWB_out), .in10(MEMalu_out), .mux_out(MUXrs2_out), .control(ForwardB));

Forwarding_Control Forwarding_Control
(
    .MEM_Rd(MEMrd), .WB_Rd(WBrd), .EX_rs1(EXrs1), .EX_rs2(EXrs2), 
    .MEM_RegWrite(MEMRegWrite), .WB_RegWrite(WBRegWrite), .ForwardA(ForwardA), .ForwardB(ForwardB)
);

//MEM stage

dcache dcache(
    .clk_i (clk_i),
    .rst_i (rst_i), 
    .cpu_addr_i (MEMalu_out), 
    .cpu_MemRead_i (MEMMemRead),
    .cpu_MemWrite_i (MEMMemWrite),
    .cpu_data_i (MEMDatabus2),
    .cpu_data_o (MEMMem_out),
    .cpu_stall_o (Mem_stall),

    .mem_data_i (mem_data_i),
    .mem_ack_i  (mem_ack_i),
    .mem_data_o (mem_data_o),
    .mem_addr_o (mem_addr_o),
    .mem_enable_o(mem_enable_o),
    .mem_write_o (mem_write_o)
);

MEMWB MEMWB 
(
	.RegWrite_in(MEMRegWrite), 
	.MemtoReg_in(MEMMemtoReg), 
	.RegWrite_out(WBRegWrite), 
	.MemtoReg_out(WBMemtoReg), 
	.read_alu_data_in(MEMalu_out), 
	.read_addr_data_in(MEMMem_out), 
	.read_alu_data_out(WBalu_out), 
	.read_addr_data_out(WBMem_out), 
	.EX_MEM_Rd_in(MEMrd), 
	.MEM_WB_Rd_out(WBrd), 
    .MemStall_in(Mem_stall),
	.clk_i(clk_i), 
	.rst_i(rst_i)
);


//WB stage
MUX32 MUXWB(
    .data1_i    (WBalu_out),
    .data2_i    (WBMem_out),
    .select_i   (WBMemtoReg),
    .data_o     (MUXWB_out)
);



endmodule

