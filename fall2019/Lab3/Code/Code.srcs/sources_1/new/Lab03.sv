`timescale 1ns / 1ps

// Inverter module

module inv( input logic a, output logic y
    );
    assign y = ~a;
endmodule

module and2( input logic a, b,
            output logic y
    );
    assign y = a & b;
endmodule

module or2( input logic a, b,
            output logic y
    );
    assign y = a | b;
endmodule

// 4 input OR gate module

module or4( input logic a, b, c, d,
            output logic y
    );
    assign y = a | b | c | d;
endmodule

// Behavorial SystemVerilog module for 2-to-4 decoder using arrays

module decoder2to4reg ( input reg a[1:0],
                     output reg y[4:0]
    );
    assign y[0] = ~a[0] & ~a[1];
    assign y[1] = a[0] & ~a[1];
    assign y[2] = ~a[0] & a[1];
    assign y[3] = a[0] & a[1];
endmodule

// Behavorial SystemVerilog module for 2-to-4 decoder

module decoder2to4 ( input logic a0, a1,
                     output logic y0, y1, y2, y3
    );
    assign y0 = ~a0 & ~a1;
    assign y1 = a0 & ~a1;
    assign y2 = ~a0 & a1;
    assign y3 = a0 & a1;
endmodule

// Behavorial SystemVerilog module for 2-to-1 multiplexer

module mux2to1( input logic d1, d0, s0,
                output logic y
    );
    assign y = s0 ? d0 : d1;
endmodule

// Structural SystemVerilog module for 4-to-1 mux

module mux4to1( input logic d0, d1, d2, d3, s1, s0,
                output logic y
    );
    logic m1, m0;
    mux2to1 mux1( d0, d1, s0, m1);
    mux2to1 mux2( d2, d3, s0, m0);
    mux2to1 mux3( m1, m0, s1, y);
endmodule


// Structural SystemVerilog module for 8-to-1 mux

module mux8to1( input logic d0, d1, d2, d3, d4, d5, d6, d7,
                input logic s2, s1, s0,
                output logic y
    );
    logic n0, n1, n2, n3, n4;
    mux4to1 mux1( d0, d1, d2, d3, s1, s0, n0);
    mux4to1 mux2( d4, d5, d6, d7, s1, s0, n1);
    inv inv1( s2, n2);
    and2 and1( n0, n2, n3);
    and2 and2( s2, n1, n4);
    or2 or1( n3, n4, y);
endmodule


// Structural SystemVerilog module for the function F

module functionF( input logic a, b, c, d,
                 output logic f
    );
    logic d_not_l_not, d_not_l, d_l_not, d_l, one, d_, d_not;
    decoder2to4 decoder( d, 1, d_not_l_not, d_l_not, d_not_l, d_l); // second input is 1 instead of L
    or2 or1( d_not_l_not, d_not_l, d_not);
    or2 or2( d_l_not, d_l, d_);
    or4 or3( d_not_l_not, d_not_l, d_l_not, d_l, one);
    mux8to1 mux( d_not, d_not, d_, d_not, d_not, d_not, one, d_, a, b, c, f);
endmodule

/////////////////////////////////////////
//  DECODER MODULES FOR FPGA PROJECT   //
/////////////////////////////////////////
module decoder2to4withEnable( input logic a0, a1, e,
                     output logic y0, y1, y2, y3
    );
    assign y0 = e & ~a0 & ~a1;
    assign y1 = e & a0  & ~a1;
    assign y2 = e & ~a0 & a1;
    assign y3 = e & a0  & a1;
endmodule

module decoder2to4Basys( input sw[0:2], output led[0:3]);
    decoder2to4withEnable decoder(sw[0], sw[1], sw[2], led[0], led[1], led[2], led[3]);
endmodule

/////////////////////////////////////
//  MUX MODULES FOR FPGA PROJECT   //
/////////////////////////////////////

module functionFwithInverter( input logic a, b, c, d,
                 output logic f
    );
    logic d_not, one;
    inv innverter(d, d_not);
    or2 orGate(d, d_not, one);
    mux8to1 mux( d_not, d_not, d, d_not, d_not, d_not, one, d, a, b, c, f);
endmodule

module functionFBasys( input sw[0:3], output led[0:1]);
    functionFwithInverter fun( sw[3], sw[2], sw[1], sw[0], led[0]);
endmodule