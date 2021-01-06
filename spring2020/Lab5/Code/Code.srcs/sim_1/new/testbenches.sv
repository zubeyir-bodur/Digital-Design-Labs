`timescale 1ns / 1ps

module testTrafficLightController();

    logic s_a, s_b, clk, rst; 
    logic [2:0]l_a; 
    logic [2:0]l_b; 

    trafficLightControllerSimulation test( s_a, s_b, clk, rst, l_a, l_b); 
    initial begin
        s_a = 0; s_b = 0; clk = 0; rst = 1; #1; rst = 0;
        repeat (2) begin
            repeat (2) begin
                repeat (40) begin
                    clk = ~clk; #1;
                end
                s_b = ~s_b; #1;
            end
            s_a = ~s_a; #1;
        end
        $stop;
    end
endmodule
