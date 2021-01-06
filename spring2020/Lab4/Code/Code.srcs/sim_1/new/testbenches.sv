`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2020 21:25:22
// Design Name: 
// Module Name: testbenches
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

module testMultiRegister();
    logic [1:0]sel;
    logic [3:0]in;
    logic clk, rst, shr_in, shl_in;
    logic [3:0]q;
    multifunctionRegister test( sel, in, clk, rst, shr_in, shl_in, q);
    initial begin
        sel = 2'b0; in = 4'b0; clk = 0; rst = 1; shr_in = 0; shl_in = 0; #1;
        rst = 0;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    repeat(2) begin
                        repeat(2) begin
                            repeat(2) begin
                                repeat(2) begin
                                    repeat(2) begin
                                        repeat(2) begin
                                            clk = ~clk; #20;
                                        end
                                        shr_in = ~shr_in; #20;
                                    end
                                    shl_in = ~shl_in; #20;
                                end
                                in[0] = ~in[0]; #20;
                            end
                            in[1] = ~in[1]; #20;
                        end
                        in[2] = ~in[2]; #20;
                    end
                    in[3] = ~in[3]; #20;
                end
                sel[0] = ~sel[0]; #20;
            end
            sel[1] = ~sel[1]; #20;
        end
    $stop;
    end                                                            
endmodule

