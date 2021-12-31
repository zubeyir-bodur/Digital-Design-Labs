/**
 * Title: 2 Bit Full Adder
 * Author: Zubeyir Bodur
 * ID: 21702382
 * Section: 4
 * Lab : 2
 * Description: Several implementations 
 * 				for 1 Bit & 2 Bit Adder
 */
`timescale 1ns / 1ps

/**
 * This design uses 3 XOR, 3 AND and 2 OR gates
 * In total, it makes around 66 CMOS transistors
 */
module adder1D(	input logic a, b, c_in,
                output logic s, c_out
);
	assign s = a ^ b ^ c_in;
	assign c_out = a & b | a & c_in | b & c_in;
endmodule

/**
 * This design uses only 2 XOR, 2 AND and 1 OR gate
 * In total, it makes around 42 CMOS transistors
 */
module adder1S( input logic a, b, c_in,
               	output logic s, c_out
              );
	logic a_xor_b, a_and_b, c_in_and_axorb;
	xor2 xor_1(a_xor_b, a, b);
	xor2 xor_2(s, a_xor_b, c_in);
	and2 and_1(a_and_b, a, b);
	and2 and_2(c_in_and_axorb, c_in, a_xor_b);
	or2 or_(c_out, a_and_b, c_in_and_axorb);
endmodule

module adder2S( input logic[1:0] a, b,
               	input logic c_in,
               	output logic[1:0] s,
               	output logic c_out
);
	logic c_in_1;
	adder1D zerothbit(a[0], b[0], c_in, s[0], c_in_1);
	adder1D firstbit(a[1], b[1], c_in_1, s[1], c_out);
endmodule

module and2(output logic y,
           	input logic a, b);
	assign y = a & b;
endmodule

module or2(	output logic y, 
          	input logic a, b);
	assign y = a | b;
endmodule

module xor2(output logic y, 
          	input logic a, b);
	assign y = a ^ b;
endmodule