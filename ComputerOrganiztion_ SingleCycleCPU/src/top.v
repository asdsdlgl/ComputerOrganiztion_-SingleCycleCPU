// top
`include "Regfile.v"
`include "PC.v"
`include "Mux4to1.v"
`include "Mux2to1.v"
`include "Jump_Ctrl.v"
`include "IM.v"
`include "DM.v"
`include "Controller.v"
`include "ALU.v"
module top ( clk,
             rst,
			 // Instruction Memory
			 IM_Address,
             Instruction,
			 // Data Memory
			 DM_Address,
			 DM_enable,
			 DM_Write_Data,
			 DM_Read_Data);

	parameter data_size = 32;
	parameter mem_size = 16;	

	input  clk, rst;
	
	// Instruction Memory
	output [mem_size-1:0] IM_Address;	
	input  [data_size-1:0] Instruction;

	// Data Memory
	output [mem_size-1:0] DM_Address;
	output DM_enable;
	output [data_size-1:0] DM_Write_Data;	
        input  [data_size-1:0] DM_Read_Data;
	

	wire [4:0] Rs;
	wire [4:0] Rt;
	wire [4:0] Rd;
	wire [4:0] RtRd_result;
	wire [4:0] Wr;
	wire [4:0] Shamt;
	wire [15:0] imm;
	wire [5:0] opcode;
	wire [5:0] funct;
	wire [3:0] ALUOp;
	wire RegWrite;
	wire MemWrite;
	wire MemToReg;
	wire Branch;
	wire Jr;
	wire Jump;
	wire Jal;
	wire RegDst;
	wire Signextend;
	wire [31:0]Wd;
	wire [17:0]PCout;
	wire [17:0] PCin;
	wire [31:0] imm_sign;
	wire [31:0] ToALU;
	wire [31:0] RsToALU;
	wire [31:0] RtToALU;
	wire [31:0] ALU_result;
	wire [31:0] sign_ex1;
	wire [31:0] sign_ex2;
	wire [31:0] WD;
	wire [31:0] DoubleEnd;
	wire [31:0] BeforeJal;
	wire [17:0] add_4;
	wire [17:0] double_add_4;
	wire [17:0] forbranch;
	wire [1:0] JC;
	// write your code here

	assign Rs = Instruction[25:21];
	assign Rt = Instruction[20:16];
	assign Rd = Instruction[15:11];
	assign imm = Instruction[15:0];
	assign opcode = Instruction[31:26];
	assign funct = Instruction[5:0];
	assign shamt = Instruction[10:6];
	assign IM_Address = PCout[17:2];
	assign DM_enable = MemWrite;
	assign DM_Address = ALU_result[17:2];
	assign DM_Write_Data = WD;
	

	assign add_4 = PCout + 4;
	assign double_add_4 = add_4 + 4;
	Controller Con(.opcode(opcode),.funct(funct),.ALUOp(ALUOp),.RegWrite(RegWrite),.Branch(Branch),.Jr(Jr),.Jump(Jump),.Jal(Jal),.MemWrite(MemWrite),.MemToReg(MemToReg),.RegDst(RegDst),.Signextend(Signextend));
	Mux2to1 MuxJal(.I0(BeforeJal),.I1({14'b0,double_add_4}),.S(Jal),.out(WD));
	Mux2to1#(5) RtMux(.I0(Rt),.I1(Rd),.S(RegDst),.out(RtRd_result));
	Mux2to1#(5) WRMux(.I0(RtRd_result),.I1(5'd31),.S(RegDst),.out(Wr));
	Regfile Regf(.clk(clk),.rst(rst),.Read_addr_1(Rs),.Read_addr_2(Rt),.Read_data_1(RsTOALU),.Read_data_2(RtTOALU),.RegWrite(RegWrite),.Write_addr(Wr),.Write_data(Wd));
	assign imm_sign = {Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],Instruction[15],imm};
	Mux2to1 Rs_ALU_Mux(.I0(RtToALU),.I1(imm_sign),.S(RegDst),.out(ToALU));
	ALU Alu1(.ALUOp(ALUOp),.src1(RsToALU),.src2(ToALU),.shamt(shame),.ALU_result(ALU_result),.Zero(Zero));
	assign sign_ex1 = {RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15],RtToALU[15:0]};
	Mux2to1 Rt_To_WD(.I0(RtToALU),.I1(sign_ex1),.S(Signextend),.out(WD));
	assign sign_ex2 = {DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15],DM_Read_Data[15:0]};
	Mux2to1 EndMux1(.I0(DM_Read_Data),.I1(sin_ex2),.S(Signextend),.out(DoubleEnd));
	Mux2to1 EndMux2(.I0(ALU_result),.I1(DoubleEnd),.S(MemToReg),.out(BeforeJal));

	assign forbranch = add_4 + {imm,2'b00};
	Jump_Ctrl ctrl (.Zero(Zero),.JumpOP(JC),.Branch(Branch),.Jump(Jump),.Jr(Jr));
	Mux4to1 mux4(.I0(add_4),.I1(forbranch),.I2(RsToALU),.I3({imm,2'b00}),.S(JC),.out(PCin));

endmodule


























