module im(input [9:0]raddr, output [31:0]rdata);
    reg [31:0]ROM[0:1024];
    integer i;
    initial begin
        for(i = 0; i < 1024; i++)
            ROM[i] = 0;
        $readmemh("code.txt", ROM);
    end
    assign rdata = ROM[raddr];
endmodule