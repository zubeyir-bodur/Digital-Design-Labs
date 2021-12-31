/**
 * Title: 2 Bit Full Adder
 * Author: Zubeyir Bodur
 * ID: 21702382
 * Section: 4
 * Lab : 2
 * Description: Testbenches for modules in design.sv
 */
`timescale 1ns / 1ps

module testadder1D();
	logic c_in, c_out;
	logic a, b, s;
	integer i, j, k;
	adder1D uut(.a(a),
				.b(b),
				.c_in(c_in),
				.s(s),
				.c_out(c_out)
				);
	initial begin
		a <= 0;
		b <= 0;
		c_in <= 0;
		for(i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				for (k = 0; k < 2; k = k + 1) begin
					#10 $display("A = 1'b%b ; B = 1'b%b ; C_in = 1'b%b ; C_out = 1'b%b ; S = 1'b%b", a, b, c_in, c_out, s);
					c_in <= c_in + 1;
				end
				b <= b + 1;
			end
			a <= a + 1;
		end
	end
endmodule

module testadder1S();
	logic c_in, c_out;
	logic a, b, s;
	integer i, j, k;
	adder1S uut(.a(a),
				.b(b),
				.c_in(c_in),
				.s(s),
				.c_out(c_out)
				);
	initial begin
		a <= 0;
		b <= 0;
		c_in <= 0;
		for(i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				for (k = 0; k < 2; k = k + 1) begin
					#10 $display("A = 1'b%b ; B = 1'b%b ; C_in = 1'b%b ; C_out = 1'b%b ; S = 1'b%b", a, b, c_in, c_out, s);
					c_in <= c_in + 1;
				end
				b <= b + 1;
			end
			a <= a + 1;
		end
	end
endmodule

module testadder2S();
	logic c_in, c_out;
	logic[1:0] a, b, s;
	integer i, j;
  
	adder2S uut(.a(a),
				.b(b),
				.c_in(c_in),
				.s(s),
				.c_out(c_out)
				);
  
	initial begin
		a <= 0;
		b <= 0;
		c_in <= 0;
		for(i = 0; i < 4; i = i + 1) begin
			for (j = 0; j < 4; j = j + 1) begin
				#10 $display("A = 2'b%b ; B = 2'b%b ; C_in = 1'b%b ; C_out = 1'b%b ; S = 2'b%b", a, b, c_in, c_out, s);
				b <= b + 1;
			end
			a <= a + 1;
		end
	end
endmodule
