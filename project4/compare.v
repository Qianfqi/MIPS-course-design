module compare(
input [31:0]c1,
input [31:0]c2,
output reg true
);
    always @(*) begin
		    true=c1==c2;
	 end
endmodule