`timescale 1ns / 1ps
// LED positions inside 7-segment :
//   A
// F   B
//   G
// E   C
//   D 
// DP
// digit positions on Basys3 :
// in3(left), in2, in1, in0(right)
module SevSeg_4digit( input clk,
                      input [4:0] in0, in1, in2, in3, // 4 values for 4 digits (decimal value)
                      output a, b, c, d, e, f, g, dp, //individual LED output for the 7-segment along with the digital point
                      output [3:0] an // anode: 4-bit enable signal (active low)
    );
    // divide system clock (100Mhz for Basys3) by 2^N using a counter, which allows us to multiplex at lower speed
    localparam N = 18;
    logic [N-1:0] count = {N{1'b0}}; //initial value 
    
    always_ff @(posedge clk) begin
        count <= count + 1;
    end
    
    logic [4:0]digit_val; // 7-bit register to hold the current data on output 
    logic [3:0]digit_en; //register for enable vector 
    
    always_comb begin
        digit_en = 4'b1111; //default
        digit_val = in0; //default
        case(count[N-1:N-2]) //using only the 2 MSB's of the counter
        
            2'b00 : begin //select first 7Seg.
                digit_val = in0;
                digit_en = 4'b1110;
            end
        
            2'b01: begin //select second 7Seg.
                digit_val = in1;
                digit_en = 4'b1101;
            end
        
            2'b10: begin //select third 7Seg.
                digit_val = in2;
                digit_en = 4'b1011;
            end
            
            2'b11: begin //select forth 7Seg.
                digit_val = in3;
                digit_en = 4'b0111;
            end
        endcase
    end
    
    //Convert digit number to LED vector. LEDs are active low.
    logic [6:0] sseg_LEDs;
    always_comb begin
        sseg_LEDs = 7'b1111111; //default
        case(digit_val)
            5'd0 : sseg_LEDs = 7'b1000000; //to display 0
            5'd1 : sseg_LEDs = 7'b1111001; //to display 1
            5'd2 : sseg_LEDs = 7'b0100100; //to display 2
            5'd3 : sseg_LEDs = 7'b0110000; //to display 3
            5'd4 : sseg_LEDs = 7'b0011001; //to display 4
            5'd5 : sseg_LEDs = 7'b0010010; //to display 5
            5'd6 : sseg_LEDs = 7'b0000010; //to display 6
            5'd7 : sseg_LEDs = 7'b1111000; //to display 7
            5'd8 : sseg_LEDs = 7'b0000000; //to display 8
            5'd9 : sseg_LEDs = 7'b0010000; //to display 9
            5'd10 : sseg_LEDs = 7'b0001000; //to display A
            5'd11 : sseg_LEDs = 7'b0000011; //to display B
            5'd12 : sseg_LEDs = 7'b1000110; //to display C
            5'd13 : sseg_LEDs = 7'b0100001; //to display D
            5'd14 : sseg_LEDs = 7'b0000110; //to display E
            5'd15 : sseg_LEDs = 7'b0001110; //to display F
            5'd16 : sseg_LEDs = 7'b0111111; // to display -
            5'd17 : sseg_LEDs = 7'b0110111; // to display =
            5'd18 : sseg_LEDs = 7'b0100111; // to display c
        endcase
    end
    assign an = digit_en;
    assign {g, f, e, d, c, b, a} = sseg_LEDs;
    assign dp = 1'b1; //turn dp off
endmodule