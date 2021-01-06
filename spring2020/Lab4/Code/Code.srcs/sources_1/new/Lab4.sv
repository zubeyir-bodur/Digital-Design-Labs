`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.04.2020 21:11:55
// Design Name: 
// Module Name: Lab4
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


module d_flip_flop ( input logic clk, rst, d, 
                     output logic q
);
    always_ff @(posedge clk) begin
        if (rst) q <= 0; 
        else q <= d;
    end
endmodule 

// Module for clock divider to reduce CLK signal from 100 Mhz to 1Hz
module clkDivider(	input logic clk, rst,
                    output logic clk_prime
);
    logic [31:0]divider = 32'b101111101011110000100000000;// 10^8 in decimal, can be used to actually see the leds in FPGA
    // logic [31:0]divider = 32'b1; => 2 in decimal, this can be used instead to see small enough waves in the simulation.
    logic [31:0]count = 32'b0;

    always_ff @( posedge clk, posedge rst) begin
        if ( rst == 1 )
            count <= 32'b0;
        else if ( count >= divider - 1)
            count <= 32'b0;
        else
            count <= count + 1;
    end
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst == 1)
             clk_prime <= 32'b0;
        else if (divider != 0 && count == divider - 1)
            clk_prime <= ~clk_prime;
        else
            clk_prime <= clk_prime;
    end
endmodule


// Module for multifunction register
module multifunctionRegister( input logic [1:0]sel, [3:0]in,
                              input logic clk, rst, shr_in, shl_in,
output logic [3:0]q
);
logic clk_prime;
clkDivider divide( clk, rst, clk_prime);

always_ff @(posedge clk_prime, posedge rst)
    if (rst) q <= 4'b0;
    else begin
        case( sel )
            2'b00: q <= q;
            
            2'b01: q <= in;
            
            2'b10:
            begin
                q <= q >> 1;
                q[3] <= shr_in;
            end

            2'b11:
            begin
                q <= q << 1;
                q[0] <= shl_in;
            end
        endcase
    end
endmodule
