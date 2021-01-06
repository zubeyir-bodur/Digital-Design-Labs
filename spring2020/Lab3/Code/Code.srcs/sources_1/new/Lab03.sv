`timescale 1ns / 1ps


// Behavorial module for 3 to 8 decoder 
module threeTo8decoder( input logic [2:0]a,
                        output logic [7:0]y
    );
    assign y[0] = ~a[2] & ~a[1] & ~a[0];
    assign y[1] = ~a[2] & ~a[1] & a[0];
    assign y[2] = ~a[2] & a[1]  & ~a[0];
    assign y[3] = ~a[2] & a[1]  & a[0];
    assign y[4] = a[2] & ~a[1] & ~a[0];
    assign y[5] = a[2] & ~a[1] & a[0];
    assign y[6] = a[2] & a[1]  & ~a[0];
    assign y[7] = a[2] & a[1]  & a[0];
endmodule

// Behavorial module for 4 to 1 mux
module fourTo1mux( input logic [1:0]s, [3:0]d,
                   output logic y
    );
    logic [1:0]mid;
    assign mid[0] = s[0] ? d[1] : d[0];
    assign mid[1] = s[0] ? d[3] : d[2];
    assign y = s[1] ? mid[1] : mid[0];
endmodule

// Structural module for 8 to 1 mux
module eightTo1mux( input logic [2:0]s, [7:0]d,
                    output logic y
    );
    logic [1:0]mid;
    logic [1:0]or_in;
    fourTo1mux mux4_0( s[1:0], d[3:0], mid[0]);
    fourTo1mux mux4_1( s[1:0], d[7:4], mid[1]);
    and and_0 ( or_in[0], mid[0], ~s[2]);
    and and_1 ( or_in[1], mid[1], s[2]);
    or or_0( y, or_in[0], or_in[1]);
endmodule

// Structural module for the boolean function F(A,B,C,D)
// = ?(1, 2, 7, 8, 9, 10, 12, 13)
module functionF( input a, b, c, d,
                 output logic y
    );
    logic [2:0] s;
    logic [7:0] d_prime;
    assign s[2] = a;
    assign s[1] = b;
    assign s[0] = c;
    assign d_prime[7] = 0;
    assign d_prime[6] = 1;
    assign d_prime[5] = ~d;
    assign d_prime[4] = 1;
    assign d_prime[3] = d;
    assign d_prime[2] = 0;
    assign d_prime[1] = ~d;
    assign d_prime[0] = d;
    eightTo1mux mux8_0( s, d_prime, y );
endmodule