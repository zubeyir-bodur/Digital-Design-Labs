`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2021 19:47:08
// Design Name: 
// Module Name: two4Dec
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


module dec2_4(
    output logic [3:0] Y,
    input logic  [1:0] D 
    );
    always_comb begin
        case(D)
            2'b00: Y = 4'b0001;
            2'b01: Y = 4'b0010;
            2'b10: Y = 4'b0100;
            2'b11: Y = 4'b1000;
            default: Y = 4'b0000; // if one of the D's are contention, set all Y's to 0
        endcase
    end
    
endmodule

module mux4_1(
    output logic Y,
    input logic [3:0] D,
    input logic [1:0] S 
    );
    always_comb begin
        case(S)
            2'b00: Y = D[0];
            2'b01: Y = D[1];
            2'b10: Y = D[2];
            2'b11: Y = D[3];
            default: Y = 1'bZ; // if D is a contention, have Y disconnected
        endcase
    end
endmodule

module mux8_1(
    output logic Y,
    input logic [7:0] D,
    input logic [2:0] S 
    );
    logic lo, hi;
    mux4_1 muxlo(lo, D[3:0], S[1:0]);
    mux4_1 muxhi(hi, D[7:4], S[1:0]);
    //assign Y = S[2] ? hi : lo;
    logic s_not_and_lo, s_and_hi, s_not;
    inv sinv(s_not, S[2]);
    and2 and2lo(s_not_and_lo, s_not, lo);
    and2 and2hi(s_and_hi, S[2], hi);
    or2 out(Y, s_not_and_lo, s_and_hi);
endmodule

module f(
    output logic y,
    input logic a, b, c, d
    );
    logic [7:0] inputs;
    logic [2:0] select;
    logic d_not;
    inv dinv(d_not, d);
    assign inputs = {d, d_not, d_not, 1'b1, d, d, d_not, d};
    assign select = {a, b, c};
    mux8_1 out(y, inputs, select);
endmodule

module and2(
    output logic y,
    input logic a, b
    );
    assign y = a & b;
endmodule

module or2(
    output logic y,
    input logic a, b
    );
    assign y = a | b;
endmodule

module inv(
    output logic y,
    input logic a
    );
    assign y = ~a;
endmodule