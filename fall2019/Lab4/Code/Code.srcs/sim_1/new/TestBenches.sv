`timescale 1ns / 1ps


// Testbench for register
module registerTest();
    logic d[1:0], clk, q[1:0];
    TwoBitRegister dut(d[1:0], clk, q[1:0]);
    initial begin
        clk = 0; d[1] = 0; d[0] = 0; #20;
        clk = 1; #20;
        clk = 0; d[1] = 0; d[0] = 1; #20;
        clk = 1; #20;
        clk = 0;  d[1] = 1; d[0] = 0;  #20;
        clk = 1; #20;
        clk = 0;  d[1] = 1; d[0] = 1;  #20;
        clk = 1; #20;
    $stop;
    end
endmodule    

// Testbench for next state logic
module sNextTest();
    logic e, c, s[1:0], sNext[1:0];
    sNext dut(e, c, s[1:0], sNext[1:0]);
    initial begin
        e = 1; c = 1; s[1] = 0; s[0] = 0; #20;
        repeat (2) begin            
            repeat (2) begin            
                repeat (2) begin
                    repeat (2) begin
                        s[0] = ~s[0]; #20;
                    end
                    s[1] = ~s[1]; #20;
                end
                c = ~c; #20;
            end
            e = ~e; #20;
        end
    $stop;    
    end
endmodule

// Testbench for the driver
module driverFSMtest();
    logic e, c, clk, rst;
    logic [3:0]y;
    driverFSM FSM(e, c, clk, rst, y);
    initial begin
        clk = 0; e = 1; c = 1; rst = 1; #1; rst=0; #20;
        repeat(2) begin
            repeat(2) begin
                repeat(8) begin
                   clk = ~clk; #20;
                end
                c = ~c; #20;
            end
            e = ~e; #20;
        end
    $stop;
    end
endmodule

// Testbench for the car
module carTest();
    logic e, c, clk, rst, clk_prime, e_, c_;
    logic [1:0]i;
    logic [3:0]y;
    logic [3:0]y_;
    car carUUT(e, c, i, clk, rst, y, clk_prime, e_, c_, y_);
    initial begin
        clk = 0; e = 1; c = 1; i[1] = 0; i[0] = 0; rst = 1; #1; rst=0; #20;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    repeat(2) begin
                        repeat(160) begin
                           clk = ~clk; #1;
                        end
                        i[0] = ~i[0]; #20;
                    end
                    i[1] = ~i[1]; #20;
                end
                c = ~c; #20;
            end    
            e = ~e; #20;
        end
    $stop;
    end
endmodule
