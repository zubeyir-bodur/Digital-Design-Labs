`timescale 1ns / 1ps

// Register without reset, set or enable
module TwoBitRegister( input logic [1:0]d,
                        input logic clk, rst,
                       output logic [1:0]q
    );
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            q <= 2'b00;
        else
        q <= d;
    end
endmodule

// Next State Logic
module sNext( input logic e, c, [1:0]s,
               output logic [1:0]sNext 
    );
    logic s0_XNOR_c, s0_XOR_c, s1_e_NOT;
    logic product_1, product_2;
    
    xnor xnor1( s0_XNOR_c, s[0], c);
    and and1 ( product_1, ~s[1], e, s0_XNOR_c);
    
    xor xor1( s0_XOR_c, s[0], c);
    and and2( product_2, s[1], s0_XOR_c);
    
    and and3( s1_e_NOT, s[1], ~e);
    
    or or2( sNext[1], product_1, product_2, s1_e_NOT );
    xor xor2( sNext[0], s[0], e);
endmodule    

/* SystemVerilog code for the driver
 * where y[3:0] = {A, B, Ab, Bb}
 */
module driverFSM( input logic e, c, clk, rst,
                  output logic [3:0]y
    );
    logic [1:0]sNext;
    logic [1:0]s;
    // Next state logic
    sNext nextStateLogic(e, c, s, sNext);
    
    // Register between states
    TwoBitRegister register( sNext, clk, rst, s);
    
    // Output logic
    xnor xnor1( y[3], s[1], s[0]);
    not inv1( y[2], s[1]); 
    xor xor3( y[1], s[1], s[0]);
    buf buffer( y[0], s[1]);
endmodule


/* SystemVerilog code to divide the given clk input so that
* frequency of clk prime is less than 40Hz.
* f_clk prime can also be modified by i bus.
*/
module clkDivider( input logic [1:0]i,
                   input logic clk,
                   input logic rst,
                   output logic clk_prime
    );
    logic [31:0]divider;
    always_comb begin
        case(i)
            2'b10:
                divider = 32'b?100000000000000000000000?; // Slowest car speed, which is 75 rev/min!!! that number is equal to 10^7 1000   
            2'b01:
                divider = 32'b?10000000000000000000000?; // Medium car speed,  which is 150 rev/min!!! that number is equal to 5*10^6 100
            2'b00:
                divider = 32'b?1000000000000000000000?; // Fastest car speed, which is 300 rev/min!!! that number is equal to 25*10^5 
            2'b11:
                divider = 32'b0; // Don't divide the clk signal if we tell car to stop.       
        endcase
    end
            
    logic [31:0]count = 32'b0;
    always_ff @( posedge clk, posedge rst) begin
        if (rst == 1)
            count <= 32'b0;
        else if (count >= divider - 1)
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

/* SystemVerilog code for the car
 * where i == {00} -- fastest
 *       i == {01} -- medium
 *       i == {10} -- slowest
 *       i == {11} -- car stops
 * and   y == {A, B, Ab, Bb}
 */
module car( input logic e, c, [1:0]i,
            input logic clk, rst,
            output logic [3:0]y,
            output logic e_, c_, [3:0]y_,
            output logic clk_prime,
            output s0, s1, s2, s3, s4, s5, s6, dp,
            output [3:0]an
    );
    clkDivider divide( i, clk, rst, clk_prime);
    driverFSM driver( e, c, clk_prime, rst, y);
    buf buffer1(e_, e);
    buf buffer2(c_, c);
    buf buffer3(y_[3], y[3]);
    buf buffer4(y_[2], y[2]);
    buf buffer5(y_[1], y[1]);
    buf buffer6(y_[0], y[0]);
    logic [3:0] in3 = 4'b0000;
    logic [3:0] in2 = 4'b0000;
    logic [3:0] in1 = 4'b0000;
    logic [3:0] in0 = 4'b0000;
    not(in2[1], i[1] );
    not(in2[0], i[0] );
    SevSeg_4digit speed(clk, in0, in1, in2, in3, s0, s1, s2, s3, s4, s5, s6, dp, an );
//    else if ( i[0] == 1'b1 && i[1] == 1'b0)
//        SevSeg_4digit moderate(clk, 4'b0000, 4'b0000, 4'b0010, 4'b0000, s0, s1, s2, s3, s4, s5, s6, dp, an );
//    else if ( i[0] == 1'b0 && i[1] == 1'b1)
//        SevSeg_4digit slowest(clk, 4'b0000, 4'b0000, 4'b0001, 4'b0000, s0, s1, s2, s3, s4, s5, s6, dp, an );
//    else if ( e|| (i[0] == 1'b1 && i[1] == 1'b1) )
//        SevSeg_4digit stops(clk, 4'b0000, 4'b0000, 4'b0000, 4'b0000, s0, s1, s2, s3, s4, s5, s6, dp, an );
endmodule    
