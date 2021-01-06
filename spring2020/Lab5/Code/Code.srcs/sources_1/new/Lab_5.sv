`timescale 1ns / 1ps

module nextStateLogic( input logic s_a, s_b,
                       input logic [2:0]s,
                       output logic [2:0]n_s
);
    logic [2:0] mint_2;
    logic [3:0] mint_0;

    and and1( mint_2[0], ~s[2], s[1], s[0] );
    and and2( mint_2[1], s[2], ~s[1] );
    and and3( mint_2[2], s[2], s[1], ~s[0] );

    or or1( n_s[2], mint_2[0], mint_2[1], mint_2[2] );

    xor xor1( n_s[1], s[1], s[0]);

    and and4( mint_0[0], ~s[2], ~s[1], ~s[0], ~s_a );
    and and5( mint_0[1], ~s[2], s[1], ~s[0] );
    and and6( mint_0[2], s[2], ~s[1], ~s[0], ~s_b );
    and and7( mint_0[3], s[2], s[1], ~s[0] );

    or  or2(n_s[0], mint_0[0], mint_0[1] ,mint_0[2], mint_0[3]);
endmodule

module outputLogic( input logic [2:0]s,
                    output logic [2:0]l_a, l_b
);
    and and1 (l_a[2], 1);
    or  or1  (l_a[1], ~s[2] & ~s[1], s[2] & s[1] & s[0]);
    and and2 (l_a[0], ~s[2], ~s[1], ~s[0]);
    
    and and3 (l_b[2], 1);
    or  or2  (l_b[1], s[2] & ~s[1], ~s[2] & s[1] & s[0]);
    and and4 (l_b[0], s[2], ~s[1], ~s[0]);
endmodule

// Module for clock divider to reduce CLK frequency from 100 Mhz to 0.5 Hz
module clkDivider(	input logic[31:0] divider,
                    input logic clk, rst,
                    output logic clk_prime
);
    logic [31:0]count = 32'b0;
    always_ff @( posedge clk, posedge rst) begin
        if      ( rst == 1 )            count <= 32'b0;
        else if ( count >= divider - 1) count <= 32'b0;
        else                            count <= count + 1;
    end
    
    always_ff @(posedge clk, posedge rst) begin
        if      (rst == 1)              clk_prime <= 32'b0;
        else if (count == divider - 1)  clk_prime <= ~clk_prime;
        else                            clk_prime <= clk_prime;
    end
endmodule

module trafficLightController( input logic s_a, s_b, clk, rst,
                               output logic [2:0]l_a, l_b
);
    logic[2:0]s;
    logic[2:0]n_s;
    logic[31:0]divider = 32'b101111101011110000100000000;
    logic clk_prime;
    
    nextStateLogic nextState(s_a, s_b, s, n_s);
    clkDivider divide(divider, clk, rst, clk_prime);
    
    always_ff@ (posedge clk_prime, posedge rst) begin
        if (rst) s <= 3'b0;
        else     s <= n_s;
    end
    
    outputLogic out(s, l_a, l_b);
endmodule

module trafficLightControllerSimulation(    input logic s_a, s_b, clk, rst,
                                            output logic [2:0]l_a, l_b
);
    logic[2:0]s;
    logic[2:0]n_s;
    logic[31:0]divider = 32'b1;
    logic clk_prime;
    
    nextStateLogic nextState(s_a, s_b, s, n_s);
    clkDivider divide(divider, clk, rst, clk_prime);
    
    always_ff@ (posedge clk_prime, posedge rst) begin
        if (rst) s <= 3'b0;
        else     s <= n_s;
    end
    
    outputLogic out(s, l_a, l_b);
endmodule