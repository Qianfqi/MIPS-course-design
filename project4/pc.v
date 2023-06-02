module pc(input clk, input en, input reset, input [31:0]npc, output reg[31:0]iaddr);
always @(posedge clk) begin
    if(reset)
        iaddr <= 32'h00003000;
    else if(en)
        iaddr <= npc;
    //$display("%h",iaddr);
end

endmodule