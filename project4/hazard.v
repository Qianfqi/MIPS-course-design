module hazard(
    input [4:0]WAddrM,   
    input [4:0]WAddrW,   
    input [4:0]WAddrE,   //rd
    input [4:0]RAddr1D,
    input [4:0]RAddr1E,  //rs
    input [4:0]RAddr2D,
    input [4:0]RAddr2E,  
    input [4:0]RAddr2M,  //rt
    input regwriteM,
    input regwriteE,
    input regwriteW,
    input [1:0]regsrcE,
    input [1:0]regsrcM,
    input npc_selD,
    input jumpD,
    output stall,
    output ForwardrtM,
    output [1:0]ForwardrsD,
    output [1:0]ForwardrtD,
    output [1:0]ForwardrsE,
    output [1:0]ForwardrtE
);
//stall
    wire branchstall, loadstall, jumpstall;
    assign branchstall = npc_selD&& ((WAddrE!=0 && regwriteE && regsrcE!=2 && (RAddr1D==WAddrE ||RAddr2D==WAddrE))||
							 (WAddrM!=0 && regsrcM==1 &&(RAddr1D==WAddrM ||RAddr2D==WAddrM)));
    assign jumpstall = jumpD&& (WAddrE!=0 && (regwriteE && regsrcE!=2 && RAddr1D==WAddrE)||
							(WAddrM!=0 && regsrcM==1 && RAddr1D==WAddrM));
    assign loadstall = regsrcE==1 && WAddrE!=0 && (RAddr2D==WAddrE|| RAddr1D==WAddrE); //首先检测是不是load指令，接下来看在ex阶段的rd寄存器是不是和decode阶段的某个寄存器相同
    assign stall = branchstall || loadstall || jumpstall;
//forward
    assign ForwardrsD = WAddrE!=0 && regwriteE && WAddrE==RAddr1D? 3 :
	                   WAddrM!=0 && regwriteM && WAddrM==RAddr1D? 2 :
	                   WAddrW!=0 && regwriteW && WAddrW==RAddr1D? 1 : 0;
	 assign ForwardrtD = WAddrE!=0 && regwriteE && WAddrE==RAddr2D? 3 :
	                   WAddrM!=0 && regwriteM && WAddrM==RAddr2D? 2 :
	                   WAddrW!=0 && regwriteW && WAddrW==RAddr2D? 1 : 0;
	 
	 assign ForwardrsE = WAddrM!=0 && regwriteM && WAddrM==RAddr1E? 2 :
	                   WAddrW!=0 && regwriteW && WAddrW==RAddr1E? 1 : 0;

	 assign ForwardrtE = WAddrM!=0 && regwriteM && WAddrM==RAddr2E? 2 :
	                   WAddrW!=0 && regwriteW && WAddrW==RAddr2E? 1 : 0;
	 
	 assign ForwardrtM=WAddrW!=0 && regwriteW && WAddrW==RAddr2M;
    
endmodule