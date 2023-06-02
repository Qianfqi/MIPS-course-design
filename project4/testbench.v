`timescale 1ns/1ns
`include "mips.v"
module tb;
    reg clock;
    reg reset;
    mips mycpu(.clk(clock), .reset(reset));
    //display the output
    initial begin
        clock = 0;
        reset = 1;
        #10 reset = 0;
        #1000 $finish;
    end
    initial
    begin
        //$monitor( $time, " :pc = %h",pc_next);
        //$monitor( $time, " :Instr = %h", Instr);
        $dumpfile("code_wave.vcd");
        $dumpvars;
    end
    always
        #5 clock = ~clock;
endmodule