`include "pc.v"
`include "im.v"
`include "grf.v"
`include "ext.v"
`include "dm.v"
`include "control.v"
`include "alu.v"
`include "pipelineRegs.v"
`include "compare.v"
`include "hazard.v"
module mips(input clk, input reset);
	parameter delay_slot=1'b1;
	parameter condition=1'b1;
	wire stall;  //这里的stall理解为，等待正确的数据
	wire [1:0]ForwardrsD;
	wire [1:0]ForwardrtD;
	wire [1:0]ForwardrsE;
	wire [1:0]ForwardrtE;
	wire ForwardrtM;

    wire [31:0]nextPC;
	wire [31:0]IAddrF; //fetch stage
	wire [31:0]IAddrD; //decode stage
	wire [31:0]IAddrE; //exe stage
	wire [31:0]IAddrM; //memery stage
	wire [31:0]IAddrW; //write back stage
	 
	wire [31:0]InstrF; //fetch stage
	wire [31:0]InstrD; //decode stage
	wire [31:0]InstrE; //exe stage
	wire [31:0]InstrM; //memery stage
	wire [31:0]InstrW; //write back stage
	wire [31:0]PC4D;
	wire [31:0]PC4E;
	wire [31:0]PC4M;
	wire [31:0]PC4W;
//每个阶段的控制信号
    wire jumpD; 
	wire [1:0]regsrcD; 
	wire memwriteD; 
	wire npc_selD;
	wire [1:0] alusrcD;
	wire [1:0] regdistD;
	wire regwriteD;
	wire [1:0] extopD;
	wire [3:0]aluopD;

	wire jumpE; 
	wire [1:0]regsrcE; 
	wire memwriteE; 
	wire npc_selE;
	wire [1:0] alusrcE;
	wire [1:0] regdistE;
	wire regwriteE;
	wire [1:0] extopE;
	wire [3:0]aluopE;

	wire jumpM; 
	wire [1:0]regsrcM; 
	wire memwriteM; 
	wire npc_selM;
	wire [1:0] alusrcM;
	wire [1:0] regdistM;
	wire regwriteM;
	wire [1:0] extopM;
	wire [3:0]aluopM;

	wire jumpW; 
	wire [1:0]regsrcW; 
	wire memwriteW; 
	wire npc_selW;
	wire [1:0] alusrcW;
	wire [1:0] regdistW;
	wire regwriteW;
	wire [1:0] extopW;
	wire [3:0]aluopW;   
	
//pc选择器
	wire pcsrc; 

    //fetch
    pc my_pc(clk, ~stall, reset, nextPC, IAddrF);  //fetch阶段不管后面的阶段，它只负责根据上一周期计算的nextpc取指令（如果没有stall的话）
    im my_im(IAddrF[11:2], InstrF);
    preg32 InstrFD(clk, ~stall, ((jumpD|pcsrc)&~stall)|reset, InstrF, InstrD);   //没有阻塞，跳转情况，把指令存在IF/ID流水寄存器里， 然后下一级流水，即decode阶段就从里面取
    preg32 IAddrFD(clk, ~stall, ((jumpD|pcsrc)&~stall)|reset, IAddrF, IAddrD);   //把当前pc值存在IF/ID流水寄存器里
    preg32 PCnextFD(clk, ~stall, ((jumpD|pcsrc)&~stall)|reset, IAddrF+4, PC4D);  //把pc+4的值存在IF/ID流水寄存器里
    
    //decode
    control controlD(InstrD, jumpD, regsrcD,memwriteD, npc_selD, alusrcD, regdistD, regwriteD, extopD, aluopD);
	
	wire [31:0]ImmeD;
	ext ex(InstrD[15:0], extopD, ImmeD);
	wire [4:0]RAddr1D;
	wire [4:0]RAddr2D;
	wire [4:0]RAddr1E;
	wire [4:0]RAddr2E;
	wire [4:0]RAddr1M;
	wire [4:0]RAddr2M;
	wire [4:0]WAddrW;
	wire [4:0]WAddrD;
	wire [4:0]WAddrE;
	wire [4:0]WAddrM;
	wire [4:0]rsE;
	wire [4:0]rsM;
	wire [4:0]rsW;
	wire [4:0]rtE;
	wire [4:0]rtM;
	wire [4:0]rtW;
	assign WAddrD=regdistD[1]?5'd31:(regdistD[0]?InstrD[15:11]:InstrD[20:16]);   //rd    regdst[1]时，为jal,jal write gpr[31]
	wire [31:0]WDataW;
	wire [31:0]WDataM;
	wire [31:0]RData1D;
	wire [31:0]RData2D;
	wire [31:0]RData1E;
	wire [31:0]RData2E;
	wire [31:0]ImmeE;
	wire [31:0]jumpto;
	wire trueD;
	assign RAddr1D = InstrD[25:21];  //rs
	assign RAddr2D = InstrD[20:16];  //rt
	//assign rdD = InstrD[15:11];
	GRF my_grf(clk,regwriteW,reset,RAddr1D,RAddr2D,WAddrW,WDataW,IAddrW,RData1D,RData2D);
	//此时决定是否写的信号是存在MEM/WB流水寄存器中，故为regwriteW
	wire [31:0]cmp1;
	wire [31:0]cmp2;
	assign cmp1=ForwardrsD==3? aluresultE: ForwardrsD==2? WDataM: ForwardrsD==1? WDataW: RData1D;          
	assign cmp2=ForwardrtD==3? aluresultE: ForwardrtD==2? WDataM: ForwardrtD==1? WDataW: RData2D; //旁路
	compare cmp(cmp1,cmp2,trueD);
	assign pcsrc = npc_selD && trueD;
	assign jumpto=alusrcD[0]?{IAddrF[31:28],InstrD[25:0],2'b00}:cmp1;    //ALUSrc[0]时，为j型指令，pcnext为由三部分拼接而成  其他的jr beq都是用第一个操作数
	assign nextPC=jumpD ? jumpto : pcsrc? PC4D+ImmeD :IAddrF+4;     //分支地址提前计算
	preg32 InstrDE(clk, 1'b1, stall|reset, InstrD, InstrE);   //把指令存在ID/EX流水寄存器里， 然后下一级流水，即exe阶段就从里面取
    preg32 IAddrDE(clk, 1'b1, stall|reset, IAddrD, IAddrE);   //把当前pc值存在ID/EX流水寄存器里
    preg32 PCnextDE(clk, 1'b1, stall|reset, IAddrD+4, PC4E);  //把pc+4的值存在ID/EX流水寄存器里
	preg32 Rdata1DE(clk, 1'b1, stall|reset, cmp1, RData1E); //把RData1的值存在ID/EX流水寄存器里
	preg32 Rdata2DE(clk, 1'b1, stall|reset, cmp2, RData2E); //把RData2的存在ID/EX流水寄存器里
	preg5 rsDE(clk,1'b1,stall|reset,RAddr1D,rsE);
	preg5 rtDE(clk,1'b1,stall|reset,RAddr2D,rtE);
	//preg5 rdDE(clk,1'b1,stall|reset,rdD,rdE);
	preg32 ImmeDE(clk, 1'b1, stall|reset, ImmeD, ImmeE); //把扩展后的立即数的值存在ID/EX流水寄存器里
	preg5 WaddrDE(clk, 1'b1, stall|reset, WAddrD, WAddrE); //写哪个寄存器


	//execute
	control controlE(InstrE, jumpE, regsrcE,memwriteE, npc_selE, alusrcE, regdistE, regwriteE, extopE, aluopE);
	wire [31:0]a;
	wire [31:0]b;
	assign a=ForwardrsE==2? WDataM: ForwardrsE==1? WDataW: RData1E;
	assign b=ForwardrtE==2? WDataM: ForwardrtE==1? WDataW: RData2E; //旁路
	wire [31:0]x; //alu的第一个输入
	wire [31:0]y; //alu的第二个输入
	wire zero;
	wire [31:0]aluresultE;
	assign x = a;
	assign y = alusrcE[0]?ImmeE:b;
	alu myalu(x, y, aluopE, zero, aluresultE);
	wire [31:0]MemwritedataE;
	wire [31:0]MemwritedataM;
	wire [31:0]aluresultM;
	assign MemwritedataE = b;
	//wire [4:0]WriteregE;
	//assign WriteregE = 
	preg32 InstrEM(clk,1'b1,reset,InstrE,InstrM);
	preg32 AluresultEM(clk,1'b1,reset,aluresultE,aluresultM);
	preg32 MemWDataEM(clk,1'b1,reset,MemwritedataE,MemwritedataM);
	preg32 PC4EM(clk,1'b1,reset,PC4E,PC4M);
	preg32 IAddrEM(clk,1'b1,reset,IAddrE,IAddrM);
	preg5 WaddrEM(clk, 1'b1, reset, WAddrE, WAddrM); //写哪个寄存器
	preg5 rtEM(clk,1'b1,reset,rtE,rtM);
	preg5 rsEM(clk,1'b1,reset,rsE,rsM);
	//Mem
	control controlM(InstrM, jumpM, regsrcM,memwriteM, npc_selM, alusrcM, regdistM, regwriteM, extopM, aluopM);
	wire[13:0]Memwriteaddr;
	wire[31:0]MemoutM;
	wire[31:0]MemoutW;
	wire[31:0]aluresultW;
	assign WDataM=regsrcM==2?PC4M: aluresultM;
	assign Memwriteaddr = aluresultM[13:0];
	dm_4k dm(Memwriteaddr, MemwritedataM, memwriteM, clk, InstrM[31:26],IAddrM, MemoutM);
	preg32 InstrMW(clk,1'b1,reset,InstrM,InstrW);
	preg32 MemoutMW(clk, 1'b1, reset, MemoutM, MemoutW);
	preg32 AluresultMW(clk, 1'b1, reset, aluresultM, aluresultW);
	preg5 WaddrMW(clk, 1'b1, reset, WAddrM, WAddrW);
	preg32 PC4MW(clk,1'b1,reset,PC4M,PC4W);
	preg32 IAddrMW(clk,1'b1,reset,IAddrM,IAddrW);
	preg5 rtMW(clk,1'b1,reset,rtM,rtW);
	preg5 rsMW(clk,1'b1,reset,rsM,rsW);
	//Writeback
	control controlW(InstrW, jumpW, regsrcW,memwriteW, npc_selW, alusrcW, regdistW, regwriteW, extopW, aluopW);
	assign WDataW = regsrcW==2? PC4W: regsrcW==1? MemoutW : aluresultW;

	hazard myharzard(
		WAddrM,
		WAddrW,
		WAddrE,
		RAddr1D,
		rsE,
		RAddr2D,
		rtE,
		rtM,
		regwriteM,
		regwriteE,
		regwriteW,
		regsrcE,
		regsrcM,
		npc_selD,
		jumpD,
		stall,
		ForwardrtM,
		ForwardrsD,
		ForwardrtD,
		ForwardrsE,
		ForwardrtE
	);
endmodule