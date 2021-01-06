`timescale 1ns / 1ps

// 16x8 register file
module regFile( input logic clk, w_e, r_e_0, r_e_1,
                input logic [3:0] w_a,
                input logic [3:0] r_a_0, r_a_1,
                input logic [7:0] w_d,
                output logic [7:0] r_d_0, r_d_1
    );
    logic [7:0] RAM [15:0];
    typedef enum logic {init, read_write} statetype;
    statetype state, nextstate;
    
    always_ff @(posedge clk)
        state <= nextstate;     

    always_comb
        case (state)
            init :      nextstate = read_write;
            read_write: nextstate = read_write;
            default :   nextstate = init;
        endcase
            
    always_ff @(posedge clk)
        case (state)
            read_write: begin
                if (r_e_0) r_d_0 <= RAM[r_a_0];
                if (r_e_1) r_d_1 <= RAM[r_a_1];
                if (w_e)   RAM[w_a] <= w_d;
            end
            init : RAM <= { 8'h0f, 8'h0e, 8'h0d, 8'h0c,
                            8'h0b, 8'h0a, 8'h09, 8'h08,
                            8'h07, 8'h06, 8'h05, 8'h04,
                            8'h03, 8'h02, 8'h01, 8'h00};
        endcase
endmodule

// N-bit 2-1 mux
module mux2
   #(parameter N = 4)
    (input logic [N-1:0] I1, I0,
     input logic sel,
     output logic [N-1:0] Q
    );
    assign Q = sel ? I1 : I0;
endmodule

// N-bit 4:1 mux
module mux4
   #(parameter N = 4)
    (input logic [N-1:0] I3, I2, I1, I0,
     input logic [1:0] sel,
     output logic [N-1:0] Q
    );
    logic [N-1:0] low, high;
    
    mux2#(N) highmux(I3, I2, sel[0], high);
    mux2#(N) lowmux(I1, I0, sel[0], low);
    mux2#(N) outmux(high, low, sel[1], Q);    
endmodule

// N-bit register
module register
   #(parameter N = 4)
    (input logic clk, clr, ld,
     input logic [N-1:0] I,
     output logic [N-1:0] Q
    );
    always_ff@(posedge clk) begin
        if (clr) Q <= {N{1'b0}};
        else if (ld) Q <= I;
    end
endmodule    

// N-bit up-counter
module upCounter
   #(parameter N = 4)
    (input logic clk, clr, ld,
     output logic [N-1:0] C,
     output logic tc
    );
    logic [N-1:0] I;
    register#(N) reg1_N (clk, clr, ld, I, C);
    assign I = C + 1;
    assign tc = &C;
endmodule

// N-bit down-counter with  parallel load
module downCounter
   #(parameter N = 32)
    (input logic clk, clr, ld, cnt,
     input logic [N-1:0] L,
     output logic [N-1:0] C,
     output logic tc
    );
    logic [N-1:0] I;
    register#(N) reg1_N (clk, clr, ld | cnt, I, C);
    always_comb begin
        if (ld) I = L;
        else I = C - 1;
    end        
    assign tc = ~|C;
endmodule

// N-bit clock divider
module clockDivider
   #(parameter N = 32)
    (input logic clk, en,
     input logic [N-1:0] M,
     output logic tc
    );
    logic clr;
    logic [N-1:0] C;
    typedef enum logic {init, divide} statetype;
    statetype state, nextstate;
    
    always_ff @(posedge clk)
        state <= nextstate;
    
    always_comb
        case (state)
            init: begin
                clr = 1;
                nextstate = divide;
            end
            divide: begin
                clr = 0;
                nextstate = divide;
            end
            default: nextstate = init;
        endcase
    downCounter#(N) clockDivider(clk, clr, tc, en, M - 1, C, tc);
endmodule

// Simple button debouncer, source below:
// https://www.fpga4student.com/2017/04/simple-debouncing-verilog-code-for.html
module buttonDebouncer( input logic clk, pb_in,
                        output logic  pb_out
    );
    logic q_0_d_1, q_1_not;
    always_ff @(posedge clk)
        q_0_d_1 <= pb_in ;
        
    always_ff @(posedge clk)
        q_1_not <= ~q_0_d_1 ; 
        
    assign pb_out = q_1_not & q_0_d_1;
    
endmodule

// Datapath for the checksum algorithm
// 1- Takes 8 bit data each clock cycle, adds them 
// and takes the complement of the sum.
// 2- Counts number of clock cycles during the checksum operation
module datapath(    input logic clk, 
                    input logic i_clr, i_ld, 
                    input logic sum_clr, sum_ld,
                    input logic checksum_clr, checksum_ld,
                    input logic ctr_clr, ctr_ld,
                    input logic [7:0] D,
                    output logic [3:0] r_a_0,
                    output logic [7:0] checksum, num_of_cycles, 
                    output logic is_last_data
    );
    logic i_tc;
    logic [4:0] i;
    logic [7:0] sum, sum_reg, checksum_reg, ctr_C;
    
    assign r_a_0 = i;
    assign is_last_data = ~(i < 16);
    upCounter#(5) iCtr1( clk, i_clr, i_ld, i, i_tc); // iterates the read address
    
    assign sum_reg =  sum + D;
    register#(8) sum_reg1(clk, sum_clr, sum_ld, sum_reg, sum);// sum := sum_reg
    
    assign checksum_reg = ~sum + 1;
    register#(8) checksum_reg1(clk, checksum_clr, checksum_ld, checksum_reg, checksum); // checksum := checksum_reg;
    
    assign num_of_cycles = ctr_C;
    upCounter#(8) ctr1(clk, ctr_clr, ctr_ld, ctr_C); // counts the number of data processed(16).
endmodule

// Controller for the checksum algorithm.
module controller(  input logic clk, run, is_last_data,
                    output logic i_clr, i_ld,
                    output logic sum_clr, sum_ld,
                    output logic checksum_clr, checksum_ld,
                    output logic ctr_clr, ctr_ld,
                    output logic r_e_0, over
    );
    typedef enum logic [2:0] {start, clear, compare, sum, complement, inform} statetype;
    statetype state, nextstate;
    
    always_ff @(posedge clk) // no reset needed as the default case will be  
        state <= nextstate;  // used if we don't know the current state
        
    always_comb begin
        case (state)
            start: begin
                if  (run)           nextstate = clear;
                else                nextstate = start;
                
                i_clr        = 0;        i_ld   = 0;
                sum_clr      = 0;        sum_ld = 0;
                checksum_clr = 0;   checksum_ld = 0;
                ctr_clr      = 0;        ctr_ld = 0;
                r_e_0        = 0;          over = 0;
            end
            clear: begin               
                nextstate = compare;
                
                i_clr        = 1;        i_ld   = 0;
                sum_clr      = 1;        sum_ld = 0;
                checksum_clr = 1;   checksum_ld = 0;
                ctr_clr      = 1;        ctr_ld = 0;
                r_e_0        = 0;          over = 0;
            end
            compare: begin               
                if (~is_last_data)   nextstate = sum;
                else                 nextstate = complement;
                
                i_clr         = 0;        i_ld   = 0;
                sum_clr       = 0;        sum_ld = 0;
                checksum_clr  = 0;   checksum_ld = 0;
                ctr_clr       = 0;        ctr_ld = 0;
                r_e_0         = 1;          over = 0;
            end
            sum: begin
                nextstate = compare;
                
                i_clr         = 0;        i_ld   = 1;
                sum_clr       = 0;        sum_ld = 1;
                checksum_clr  = 0;   checksum_ld = 0;
                ctr_clr       = 0;        ctr_ld = 1;
                r_e_0         = 0;          over = 0;
            end
            complement: begin
                nextstate = inform;
                
                i_clr        = 0;        i_ld   = 0;
                sum_clr      = 0;        sum_ld = 0;
                checksum_clr = 0;   checksum_ld = 1;
                ctr_clr      = 0;        ctr_ld = 0;
                r_e_0        = 0;          over = 0;
            end
            inform: begin
                nextstate = start;
                
                i_clr        = 0;        i_ld   = 0;
                sum_clr      = 0;        sum_ld = 0;
                checksum_clr = 0;   checksum_ld = 0;
                ctr_clr      = 0;        ctr_ld = 0;
                r_e_0        = 0;          over = 1;
            end
            default: nextstate = start;
        endcase
    end
endmodule 

// HLSM module for displaying different values in sevent segment display
module sevenSegmentLogic(   input logic clk, w_e, run, prev, cnt, next, over, 
                            input logic [3:0] w_a,
                            input logic [7:0] num_of_cycles, checksum, r_d_1,
                            output logic r_e_1,
                            output logic [3:0] r_a_1,
                            output logic [4:0] in3, in2, in1, in0
                            
    );
    typedef enum logic [3:0] {  init, inc_r_a, dec_r_a, en_read, read_data, disp, 
                                wait_dp, read_csum, disp_csum, read_ctr, disp_ctr} statetype;
    statetype state, nextstate;
    
    // Controlller Datapath I/O
    logic ten_clr, ten_ld;                  // Up counter load&clear signals
    logic in_ld;                            // Seven segment load signal
    logic r_a_1_ld;                         // Read address load signal
    logic [1:0] in_sel, read_sel;           // Select signals for 4:1 multiplexers
    logic ten_sec_passed;                   // Signal coming from comparator in the datapath
    
    // Datapath local variables
    logic ten_tc;
    logic [31:0] ten_C;
    logic [3:0] r_a_1_reg;
    logic [4:0] in3_reg, in2_reg, in1_reg, in0_reg;
    
    // DATAPATH
    register#(5) in_reg3        (clk, 0, in_ld, in3_reg, in3);
    register#(5) in_reg2        (clk, 0, in_ld, in2_reg, in2);
    register#(5) in_reg1        (clk, 0, in_ld, in1_reg, in1);
    register#(5) in_reg0        (clk, 0, in_ld, in0_reg, in0);
    
    register#(4) r_a_1_reg0     (clk, 0, r_a_1_ld, r_a_1_reg, r_a_1);
    
    // Simply, if read_sel == 3, it will switch to memory display mode
    //         if read_sel == 2, previous data is pushed
    //         if read_sel == 1, next data is pushed
    //         if read_sel == 0, program is idle.
    mux4#(4)r_a_1_mux(w_a, r_a_1 - 1, r_a_1 + 1, r_a_1, read_sel, r_a_1_reg);
    
    // Simply, if in_sel == 3, it will switch to memory display mode
    //         if in_sel == 2, display counter is pushed
    //         if in_sel == 1, run is pushed and checksum is ready to display
    //         if in_sel == 0, program is idle.
    mux4#(5) in3_mux(5'(r_a_1)      , 5'd18,                    5'd12,              in3, in_sel, in3_reg);
    mux4#(5) in2_mux(5'd16          , 5'd17,                    5'd17,              in2, in_sel, in2_reg);
    mux4#(5) in1_mux(5'(r_d_1[7:4]) , 5'(num_of_cycles[7:4]),   5'(checksum[7:4]),  in1, in_sel, in1_reg);
    mux4#(5) in0_mux(5'(r_d_1[3:0]) , 5'(num_of_cycles[3:0]),   5'(checksum[3:0]),  in0, in_sel, in0_reg);
                           
    upCounter#(32) ten_ctr1( clk, ten_clr, ten_ld, ten_C, ten_tc);
    assign ten_sec_passed = (ten_C == 32'd200000000);
    
    // CONTROLLER
    always_ff @(posedge clk)
        state <= nextstate;
    
    always_comb begin
        case(state)
            init: begin
                nextstate = en_read;
                
                r_a_1_ld = 1; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd3;
            end
            inc_r_a: begin
                nextstate = en_read;
                
                r_a_1_ld = 1; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd1;
            end
            dec_r_a: begin
                nextstate = en_read;
                
                r_a_1_ld = 1; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd2;
            end
            en_read: begin
                nextstate = read_data;
                
                r_a_1_ld = 0; r_e_1    = 1; 
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd0;
            end
            read_data: begin
                nextstate = disp;
                
                r_a_1_ld = 0;    r_e_1    = 0;
                ten_clr  = 0;    ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd0;
            end
            disp: begin
                if      (next)      nextstate = inc_r_a;
                else if (prev)      nextstate = dec_r_a;
                else if (w_e)       nextstate = en_read;
                else if (run)       nextstate = wait_dp;
                else if (cnt)       nextstate = read_ctr;
                else                nextstate = disp;
                
                r_a_1_ld = 0; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 1;
                in_sel   = 2'd3; read_sel = 2'd0;
            end
            wait_dp: begin
                if (over)   nextstate = read_csum;
                else        nextstate = wait_dp;
                
                r_a_1_ld = 0; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd0;
            end
            read_csum: begin
                nextstate = disp_csum;
                
                r_a_1_ld = 0; r_e_1    = 0;
                ten_clr  = 1; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd0;
            end
            disp_csum: begin
                if (ten_sec_passed | next | prev)   nextstate = init;
                else if (run)                       nextstate = wait_dp;
                else if (cnt)                       nextstate = read_ctr;
                else                                nextstate = disp_csum;
                
                r_a_1_ld = 0; r_e_1    = 0;
                ten_clr  = 0; ten_ld   = 1;
                in_ld   = 1;
                in_sel   = 2'd1; read_sel = 2'd0;
            end
            read_ctr: begin
                nextstate = disp_ctr;
                
                r_a_1_ld = 0; r_e_1    = 0;
                ten_clr  = 1; ten_ld   = 0;
                in_ld   = 0;
                in_sel   = 2'd0; read_sel = 2'd0;
            end
            disp_ctr: begin
                if (ten_sec_passed | next | prev)   nextstate = init;
                else if (run)                       nextstate = wait_dp;
                else if (cnt)                       nextstate = read_ctr;
                else                                nextstate = disp_ctr;
                
                r_a_1_ld = 0; r_e_1    = 0;               
                ten_clr  = 0; ten_ld   = 1;
                in_ld   = 1;
                in_sel   = 2'd2; read_sel = 2'd0;
            end
            default: nextstate = init;
        endcase
    end
endmodule

module main(    input logic clk, w_e, run, prev, cnt, next,
                input logic [3:0] w_a,
                input logic [7:0] w_d,
                output logic [3:0] w_a_led,
                output logic [7:0] w_d_led,
                output logic a, b, c, d, e, f, g, dp,
                output logic [3:0] an
    );
    // Between controller & datapath
    logic i_clr, i_ld;
    logic sum_clr, sum_ld;
    logic checksum_clr, checksum_ld;
    logic ctr_clr, ctr_ld;
    logic is_last_data, r_e_0, r_e_1;
    
    // External otputs & memory 
    logic over;
    logic [3:0] r_a_0, r_a_1;
    logic [7:0] checksum, num_of_cycles, r_d_0, r_d_1;
    
    // Debounced push button values
    logic w_e_pulse, run_pulse, next_pulse;
    logic cnt_pulse, prev_pulse;
    
    // Variables for dividing the clock
    logic slow_clk;
    logic [31:0] D = 32'd5;
    
    // Varibles for each digit in seven segment display
    logic [4:0] in3, in2, in1, in0;
    
    // use slower clk for the project, 
    // last synthesis says maximum delay was 5.037 + 0.051 = 5.088 ns
    // so use about 20MHz (Tc = 50 ns). D will be 100/20 = 5.
    clockDivider#(32) divide1( clk, 1, D, slow_clk);
    
    buttonDebouncer dbncer1( slow_clk, w_e, w_e_pulse);
    buttonDebouncer dbncer2( slow_clk, run, run_pulse);
    buttonDebouncer dbncer3( slow_clk, prev, prev_pulse);
    buttonDebouncer dbncer4( slow_clk, cnt, cnt_pulse);
    buttonDebouncer dbncer5( slow_clk, next, next_pulse);
    
    controller controller1( slow_clk, run_pulse, is_last_data,    // Inputs 
    
                            i_clr, i_ld,                      // Outputs
                            sum_clr, sum_ld, 
                            checksum_clr, checksum_ld, 
                            ctr_clr, ctr_ld, r_e_0, over);
                            
    datapath datapath1( slow_clk,                                 // Inputs
                        i_clr, i_ld, 
                        sum_clr, sum_ld, 
                        checksum_clr, checksum_ld, 
                        ctr_clr, ctr_ld, r_d_0,
                                                            
                        r_a_0, checksum,                          // Outputs
                        num_of_cycles, is_last_data);
                        
    regFile regFile1(   slow_clk, w_e_pulse, r_e_0, r_e_1, w_a, r_a_0, r_a_1, w_d, r_d_0, r_d_1);
    
    SevSeg_4digit displayScreen(    clk, in0, in1, in2, in3, a, b, c, d, e, f, g, dp, an);
    
    sevenSegmentLogic displayLogic( slow_clk, w_e_pulse, run_pulse, prev_pulse, cnt_pulse, next_pulse, over, 
                                    w_a, num_of_cycles, checksum, r_d_1, r_e_1,
                                    r_a_1, in3, in2, in1, in0);
    
    always_comb begin
        w_a_led = w_a;
        w_d_led = w_d;
    end
endmodule

module mainSim( input logic clk, w_e, run, prev, cnt, next,
                input logic [3:0] w_a,
                input logic [7:0] w_d,
                output logic [3:0] w_a_led,
                output logic [7:0] w_d_led,
                output logic a, b, c, d, e, f, g, dp,
                output logic [4:0] in3, in2, in1, in0,
                output logic [3:0] an
    );
    // Between controller & datapath
    logic i_clr, i_ld;
    logic sum_clr, sum_ld;
    logic checksum_clr, checksum_ld;
    logic ctr_clr, ctr_ld;
    logic is_last_data, r_e_0, r_e_1;
    
    // External otputs & memory 
    logic over;
    logic [3:0] r_a_0, r_a_1;
    logic [7:0] checksum, num_of_cycles, r_d_0, r_d_1;
    
    // Debounced push button values
    logic w_e_pulse, run_pulse, next_pulse;
    logic cnt_pulse, prev_pulse;
    
//    // Variables for dividing the clock
//    logic slow_clk;
//    logic [31:0] D = 32'd1;
    
    // don't use slower clk for the simulation
    // In testbench, clock cycle has a period Tc = 2 ns.
    // So it will be 500MHz, and checksum and counter screens 
    // will be shown up to 500/200 = 2.5 seconds
//    clockDivider#(32) divide1( clk, 1, D, slow_clk);
    
    buttonDebouncer dbncer1( clk, w_e, w_e_pulse);
    buttonDebouncer dbncer2( clk, run, run_pulse);
    buttonDebouncer dbncer3( clk, prev, prev_pulse);
    buttonDebouncer dbncer4( clk, cnt, cnt_pulse);
    buttonDebouncer dbncer5( clk, next, next_pulse);
    
    controller controller1( clk, run_pulse, is_last_data,    // Inputs 
    
                            i_clr, i_ld,                 // Outputs
                            sum_clr, sum_ld, 
                            checksum_clr, checksum_ld, 
                            ctr_clr, ctr_ld, r_e_0, over);
                            
    datapath datapath1( clk,                                 // Inputs
                        i_clr, i_ld, 
                        sum_clr, sum_ld, 
                        checksum_clr, checksum_ld, 
                        ctr_clr, ctr_ld, r_d_0,
                                                            
                        r_a_0, checksum,                     // Outputs
                        num_of_cycles, is_last_data);
                        
    regFile regFile1(   clk, w_e_pulse, r_e_0, r_e_1, w_a, r_a_0, r_a_1, w_d, r_d_0, r_d_1);
    
    SevSeg_4digit displayScreen(    clk, in0, in1, in2, in3, a, b, c, d, e, f, g, dp, an);
    
    sevenSegmentLogic displayLogic( clk, w_e_pulse, run_pulse, prev_pulse, cnt_pulse, next_pulse, over, 
                                    w_a, num_of_cycles, checksum, r_d_1, r_e_1,
                                    r_a_1, in3, in2, in1, in0);
    
    always_comb begin
        w_a_led = w_a;
        w_d_led = w_d;
    end
endmodule
