module calculatePC(input[31:0] pc, input imm, input npcop, output reg[31:0] npc);
wire[31:0] temp;
assign temp = pc + 4;
if(npcop)
    assign npc = temp;
    
endmodule