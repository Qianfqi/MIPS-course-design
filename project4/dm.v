/*module dm_4k( addr, din, we, clk, pc, dout );
    input   [11:0]  addr ;  // address bus 
    input   [31:0]  din ;   // 32-bit input data 
    input           we ;    // memory write enable 
    input           clk ;   // clock 
    input [31:0] pc;
    output  [31:0]  dout ;  // 32-bit memory output
    reg     [31:0]  dm[1023:0]; //DM
    integer i;
    initial begin
        for(i = 0; i < 1024; i++)
            dm[i] = 0;
    end
  always @(posedge clk) begin
    if(we)
    begin
        dm[addr[11:2]] = din; //偏移
        $display("%d%h: *%h <= %h",$time,pc, addr, din);
    end
  end
  assign dout = dm[addr[11:2]];
endmodule
*/
module dm_4k( addr, din, we, clk, op, pc, dout );
    input   [13:0]  addr ;  // address bus 
    input   [31:0]  din ;   // 32-bit input data 
    input           we ;    // memory write enable 
    input           clk ;   // clock 
    input [31:0] pc;
    input [5:0]op;
    output  [31:0]  dout ;  // 32-bit memory output
    reg     [7:0]  dm[1023:0]; //DM
    integer i;
    wire [31:0]result1;
    wire [31:0]result2;
    wire [31:0]result3;
    wire [31:0]result4;
    wire [13:0]temp;
    initial begin
        for(i = 0; i < 1024; i = i+4)
            {dm[i+3], dm[i+2], dm[i+1], dm[i]} = 0;
    end
  always @(posedge clk) begin
    if(we)
    begin
        i = {addr[13:2],2'b0};
        case(op)
        40 : dm[i] = din[7:0]; //sb
        41 : {dm[i+1], dm[i]} = din[15:0]; //sh
        43 : {dm[i+3], dm[i+2], dm[i+1], dm[i]} = din; //sw
        endcase
        $display("%d%h: *%h <= %h",$time,pc, i, {dm[i+3], dm[i+2], dm[i+1], dm[i]});
    end
  end
  assign temp = {addr[13:2],2'b0};
  ext extend1({dm[temp+1],dm[temp]},2'b00,result1);//lh选择带符号扩展
  ext extend2({dm[temp+1],dm[temp]},2'b01,result2);//lhu选择带符号扩展
  extbyte extend3(dm[temp],1'b0,result3);//lb选择带符号扩展
  extbyte extend4(dm[temp],1'b1,result4);//lb选择带符号扩展
  assign dout = (op==35)?{dm[temp+3], dm[temp+2], dm[temp+1], dm[temp]} : //lw
                (op==33)?result1: //lh
                (op==37)?result2: //lhu
                (op==32)?result3: //lb
                result4; //lbu
  //assign dout = {dm[temp+3], dm[temp+2], dm[temp+1], dm[temp]};
endmodule