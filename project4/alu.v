module alu(x, y, aluop, zero, result);
    input[31:0] x;
    input[31:0] y;
    input [3:0] aluop;
    output zero;
    output [31:0] result;
    reg [31:0] res;
    always @(*) begin
      case(aluop)
        2: res = x + y;  //add型，lw， sw
        3: res = x - y;   //sub，beq
        4: res = x&y;
        5: res = x | y;   //ori，lui
        12: res = {31'b0,($signed(x))<($signed(y))};  //slt  小于则置位
        default: res = res;
      endcase  
    end
    assign zero = (res == 0 ? 1:0);
    assign result = res;
endmodule