`timescale 1ns / 1ps

// Testbench for the master_slave module
module master_slaveTest();
    logic clk, master_switch, slave_switch, enable_m, enable_s, rst,
                          master_mode_led, slave_mode_led, master_led, slave_led,
                          s0, s1, s2, s3, s4, s5, s6, dp;
    logic [3:0]an;
    master_slave modeUUT( clk, master_switch, slave_switch, enable_m, enable_s, rst,
                          master_mode_led, slave_mode_led, master_led, slave_led,
                          s0, s1, s2, s3, s4, s5, s6, dp, an);
    initial begin
        clk = 0; master_switch = 0; slave_switch = 0; enable_m = 0; enable_s = 0; rst = 0; #1;
        repeat(2) begin
            repeat(2) begin
                repeat(250) begin
                    clk = ~clk; #1;
                end
                master_switch = ~master_switch; #1;
            end
            slave_switch = ~slave_switch; #1;
        end
    $stop;
    end
endmodule
