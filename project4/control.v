module control(input[31:0] bus, output jump, output [1:0]regsrc, output memwrite, output npc_sel, output[1:0] alusrc, output [1:0] regdist,
output regwrite, output[1:0] extop, output [3:0]aluop);
reg[15:0] temp;
always @(bus) begin
    if(bus == 0) temp = 0;
    else case(bus[31:26])
    0:case(bus[5:0])
        8: temp = 16'b00_0_00_00_0_0_00_1_0000;//jr
        33: temp = 16'b00_1_01_00_0_0_00_0_0010;//addu
        35: temp = 16'b00_1_01_00_0_0_00_0_0011;//subu
        42: temp = 16'b00_1_01_00_0_0_00_0_1100;//slt
    endcase
    2:temp = 16'b00_0_00_01_0_0_00_1_0000;//j
    3:temp = 16'b00_1_10_01_0_0_10_1_0000;//jal
    4:temp = 16'b11_0_00_00_1_0_00_0_0011;//beq
    8:temp = 16'b00_1_00_01_0_0_00_0_0010;//addi
    9:temp = 16'b00_1_00_01_0_0_00_0_0010;//addiu
    10:temp = 16'b00_1_00_01_0_0_00_0_1100;//slti
    13:temp = 16'b01_1_00_01_0_0_00_0_0101;//ori
    15:temp = 16'b10_1_00_01_0_0_00_0_0101;//lui
    32:temp = 16'b00_1_00_01_0_0_01_0_0010;//lb
	33:temp = 16'b00_1_00_01_0_0_01_0_0010;//lh
    35:temp = 16'b00_1_00_01_0_0_01_0_0010;//lw
    36:temp = 16'b00_1_00_01_0_0_01_0_0010;//lbu
	37:temp = 16'b00_1_00_01_0_0_01_0_0010;//lhu
    40:temp = 16'b00_0_00_01_0_1_00_0_0010;//sb
	41:temp = 16'b00_0_00_01_0_1_00_0_0010;//sh
    43:temp = 16'b00_0_00_01_0_1_00_0_0010; //sw
    endcase
end
assign {extop, regwrite, regdist, alusrc, npc_sel, memwrite, regsrc, jump, aluop} = temp;
endmodule