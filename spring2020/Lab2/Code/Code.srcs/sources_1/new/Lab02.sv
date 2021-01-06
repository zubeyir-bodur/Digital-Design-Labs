`timescale 1ns / 1ps


module oneBitFullAdder( input logic a, b, c_in,
                        output logic c_out, sum
    );
    assign sum =  ~a & ~b & c_in | ~a & b & ~c_in 
                                    | a & ~b & ~c_in 
                                    | a & b & c_in;
    assign c_out = b & c_in | a & b | a & c_in;
endmodule

module oneBitFullSubstractor( input  logic a, b, b_in,
                              output logic b_out, dif
);
    assign dif =  ~a & ~b & b_in | ~a & b & ~b_in 
                                    | a & ~b & ~b_in 
                                    | a & b & b_in;
    assign b_out = b & b_in | ~a & b | ~a & b_in;
endmodule             

module fullAdder( input logic a, b, c_in,
                  output logic c_out, sum
    );
     oneBitFullAdder adder(a, b, c_in, c_out, sum);
endmodule

module fullSubs( input logic a, b, b_in,
                  output logic b_out, dif
    );
     oneBitFullSubstractor subs(a, b, b_in, b_out, dif);
endmodule

module TwoBitAdder( input logic a_1, a_0, b_1, b_0, c_in,
                    output logic  c_out, sum_1, sum_0  
    );
    logic c_out_1;
    fullAdder adder1( a_0, b_0, c_in, c_out_1, sum_0);
    fullAdder adder2( a_1, b_1, c_out_1, c_out, sum_1);
endmodule


