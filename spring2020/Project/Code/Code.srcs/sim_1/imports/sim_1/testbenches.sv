`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.05.2020 22:06:39
// Design Name: 
// Module Name: testTimer
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

module testRegister();
    localparam N = 4;
    logic clk, clr, ld;
    logic [N-1:0]I, Q;
    register#(N) test(clk, clr, ld, I, Q);
    initial begin
        clk = 0; clr = 1; ld = 1; I = 4'b0; #1; clk = 1; #1; clr = 0; clk = 0; #1;
        repeat(200) begin
            clk = ~clk; I = I + 1; #1;
        end    
        ld = 0;
        repeat(200) begin
            clk = ~clk; I = I + 1; #1;
        end
        $stop;
    end
endmodule

module testUpCounter();
    localparam N = 4;
    logic clk, clr, ld, tc;
    logic [N-1:0]C;
    upCounter#(N) test(clk, clr, ld, C, tc);
    initial begin
        clk = 0; clr = 1; ld = 1; #1; clk = 1; #1; clr = 0; clk = 0; #1;
        repeat(200) begin
            clk = ~clk; #1;
        end    
        ld = 0;
        repeat(200) begin
            clk = ~clk; #1;
        end
        $stop;
    end
endmodule


module testDownCounter();
    localparam N = 32;
    logic clk, clr, ld, cnt, tc;
    logic [N-1:0] L = 4;
    logic [N-1:0] C;
    downCounter#(N) test(clk, clr, ld, cnt, L, C, tc);
    initial begin
        clk = 1; clk = 0; clr = 1; ld = 1; cnt = 1; #1; clr = 0;
        repeat(200) begin
            clk = ~clk; #1;
        end    
        ld = 0; cnt = 1;
        repeat(200) begin
            clk = ~clk; #1;
        end
        ld = 0; cnt = 0;
        repeat(200) begin
            clk = ~clk; #1;
        end            
        ld = 1; cnt = 0;
        repeat(200) begin
            clk = ~clk; #1;
        end 
        $stop;
    end
endmodule

module testClockDivider();
    localparam N = 32;
    logic clk, en, tc;
    logic [N-1:0] M = 32'd100000;
    clockDivider#(N) test(clk, en, M, tc);
    initial begin
        clk = 0; en = 1;
        repeat(200020) begin
            clk = ~clk; #1;
        end
    $stop;
    end 
endmodule
    
module testController();
    logic clk, run, is_last_data;
    logic inc_clr, inc_ld;
    logic sum_clr, sum_ld;
    logic checksum_clr, checksum_ld;
    logic ctr_clr, ctr_ld;
    logic r_e;
    controller test(clk, run, is_last_data,    // Inputs 
                    inc_clr, inc_ld,           // Outputs
                    sum_clr, sum_ld, 
                    checksum_clr, checksum_ld, 
                    ctr_clr, ctr_ld, r_e);
    initial begin
        clk = 1; run = 0; is_last_data = 0;
        repeat(2) begin
            clk = ~clk; #1;
        end
        run = 1;
        repeat(20) begin
            clk = ~clk; #1;
        end
        is_last_data = 1;
        repeat(4) begin
            clk = ~clk; #1;
        end
        $stop;
    end                    
endmodule

module testDebouncer();
    logic clk, pb_in, pb_out;
    buttonDebouncer test(clk, pb_in, pb_out);
    
    always begin
        clk = ~clk; #1;
    end
    initial begin
        clk = 1; pb_in = 0; #20;
        repeat(7) begin
            pb_in = ~pb_in; #4;
        end
        pb_in = 1; #20;
        $stop;
    end
endmodule    

module testDisplayLogic();
    logic clk, run, disp_prev, disp_ctr, disp_next, r_e_1; 
    logic [3:0] w_a, r_a_1;
    logic [7:0] num_of_cycles, checksum, r_d_1;
    logic [4:0] in3, in2, in1, in0;
    sevenSegmentLogic test( clk, run, disp_prev, disp_ctr, disp_next, 
                            w_a, num_of_cycles, checksum, r_d_1, r_e_1,
                            r_a_1, in3, in2, in1, in0);
    
    always begin                     
        clk = ~clk; #1;
    end                            
    initial begin
        clk = 1; run = 0; disp_prev = 0; disp_ctr = 0; disp_next = 0;
        w_a = 4'b1111; num_of_cycles = 8'd16; checksum = 8'ha5; r_d_1 = 8'h82;
        #20; run = 1; #1; run = 0; #2020; // wait for clk to change 20 thousand times 
        $stop;                             // so that 10 seconds have passed
    end                               
endmodule

module testMain();
    logic clk, w_e, run, prev, cnt, next;
    logic [3:0] w_a, w_a_led;
    logic [7:0] w_d, w_d_led;
    logic a, b, c, d, e, f, g, dp;
    logic [3:0] an;
    logic [4:0] in3, in2, in1, in0;
    mainSim test(   clk, w_e, run, prev, cnt, next,
                    w_a, w_d, w_a_led, w_d_led,
                    a, b, c, d, e, f, g, dp,
                    in3, in2, in1, in0, 
                    an);
              
    always begin
        clk = ~clk; #1; // 500MHz
    end              
    initial begin
        clk = 1; run = 0; prev = 0; cnt = 0; next = 0;
        w_e = 0; w_a = 4'b0101; w_d = 7'b0; #100;
        
        run = ~run; #1; run = ~run; #1; run = ~run; #1; run = 1; #400; run = 0; #400;
        cnt = ~cnt; #1; cnt = ~cnt; #1; cnt = ~cnt; #1; cnt = 1; #400; cnt = 0; #400;
        next = ~next; #1; next = ~next; #1; next = ~next; #1; next = 1; #400; next = 0; #400;
        next = ~next; #1; next = ~next; #1; next = ~next; #1; next = 1; #400; next = 0; #400;
        $stop;
    end
endmodule 
