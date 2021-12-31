`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2021 21:27:04
// Design Name: 
// Module Name: f_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dec_test();
    logic [3:0] my_Y;
    logic [1:0] D;
    integer i;
    dec2_4 uut( .Y(my_Y),
                .D(D));
    initial begin
        D = 2'b0;
        for(i = 0; i < 4; i = i + 1) begin
            #10 D = D + 1;
        end
    end
endmodule

module mux4_1_test();
    logic [3:0] D;
    logic [1:0] S;
    logic Y;
    integer i, j;
    mux4_1 uut( .Y(Y),
                .D(D),
                .S(S));
    initial begin
        D = 4'b0; S = 2'b0;
        for(i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                #10 S = S + 1;
            end
            #10 D = D + 1;
        end
    end
endmodule

module mux8_1_test();
    logic [7:0] D;
    logic [2:0] S;
    logic Y;
    integer i, j;
    mux8_1 uut( .Y(Y),
                .D(D),
                .S(S));
    initial begin
        D = 8'b0; S = 3'b0;
        for(i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                #10 S = S + 1;
            end
            #10 D = D + 1;
        end
    end
endmodule

module f_test();
    logic [3:0] in;
    logic y;
    integer i;
    f uut(  .y(y),
            .a(in[3]),
            .b(in[2]),
            .c(in[1]),
            .d(in[0]));
    initial begin
        in = 4'b0;
        for (i = 0; i < 16; i = i + 1) begin
            # 10 in = in + 1;
        end        
    end
endmodule
