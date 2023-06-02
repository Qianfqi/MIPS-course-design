module ext(input[15:0] imm, input[1:0] extop, output[31:0] extnum);
    reg[31:0] outcome;
  always @(*) begin
    case(extop) 
        0:outcome={{16{imm[15]}},imm};  //带符号扩展
        1:outcome={16'h0000,imm}; //前面补0
        2:outcome={imm,16'h0000}; //后面补0
        3:outcome={{14{imm[15]}},imm,2'b00};
    endcase
  end
  assign extnum = outcome;
endmodule

module extbyte(
input [7:0]imm,
input extop,
output [31:0]ext
);
	 assign ext = extop?{24'b0,imm}:{{24{imm[7]}},imm};
endmodule