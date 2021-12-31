`timescale 1ns / 1ps

module fsmTest(
    );
    logic A, B, clk, rst;
    logic [2:0] LA, LB;
    integer i;
    trafficLightControllerSim uut( .LA(LA),
                .LB(LB),
                .clk(clk),
                .rst(rst),
                .A(A),
                .B(B));
    initial begin
        clk = 0; rst = 0; A = 0; B = 0 ; 
        #10 rst = 1; clk = 1; #10;
        rst = 0; #10;
        for (i = 0; i < 4; i = i + 1) begin
            clk = ~clk; #10;
        end
        A = 1;
        for (i = 0; i < 24; i = i + 1) begin
            clk = ~clk; #10;
        end
        A = 0; B = 1;
        for (i = 0; i < 24; i = i + 1) begin
            clk = ~clk; #10;
        end
        for (i = 0; i < 4; i = i + 1) begin
            clk = ~clk; #10;
        end
        $stop;
    end
endmodule

// working just like in next state TT
module nextStateLogicTest(
    );
    logic [4:0] in;
    logic [2:0] S_next;
    integer i;
    nextStateLogic uut( .S_next(S_next),
                .S(in[4:2]),
                .A(in[1]),
                .B(in[0]));
    initial begin
        in = 0;
        for (i = 0; i < 32; i = i + 1) begin
            #10 in = in + 1;
        end
        $stop;
    end
endmodule

// working just like in output TT
module outputLogicTest(
    );
    logic [2:0] LA, LB, S;
    integer i;
    outputLogic uut( .LA(LA),
                .LB(LB),
                .S(S));
    initial begin
        S = 3'b0;
        for (i = 0; i < 8; i = i + 1) begin
            #10 S = S + 1;
        end
        $stop;
    end
endmodule

module registerTest(
    );
    parameter N = 5;
    logic [N - 1: 0] D;
    logic [N - 1: 0] Q;
    logic clk, rst;
    integer i;
    register#(N) uut( .Q(Q),
                .clk(clk),
                .rst(rst),
                .D(D));
    initial begin
        D = 5;
        clk = 1'b0;
        rst = 1'b1;
        #1 clk = ~clk;
        #1 clk = ~clk;
        #1 rst = 1'b0;
        for(i = 0; i < 2 ** (N - 1); i = i + 1) begin
            clk = ~clk;
            #1 D = D + 1;
        end
        $stop;
    end
endmodule

module decTest(
);
    parameter N = 3;
    logic [N - 1:0] A;
    logic [2**N - 1:0] Y;
    integer i;
    dec#(N) uut( .Y(Y),
                .A(A));
    initial begin
        A = 0; #10
        for (i = 0; i < 2**N; i = i + 1) begin
            #10 A = A + 1;
        end
        $stop;
    end
endmodule

module mux2Test(
);
    parameter N = 5;
    logic [1:0] [N - 1: 0] D;
    logic S;
    logic [N - 1: 0] Y;
    integer i, j, k;
    mux2_1#(N) uut( .Y(Y),
                .D(D),
                .S(S));
    initial begin
        for (k = 0; k < 2; k = k + 1) begin
            D[k] = {N{1'b0}};
        end
        S = 1'b0;
        for(i = 0; i < 4 * (2 ** (N - 1)); i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                #1 S = S + 1;
            end
            #1 D = D + 1;
        end
        $stop;
    end
endmodule

module mux4Test(
);
    parameter N = 5;
    logic [3:0] [N - 1: 0] D;
    logic [1:0] S;
    logic [N - 1: 0] Y;
    integer i, j, k;
    mux4_1#(N) uut( .Y(Y),
                .D(D),
                .S(S));
    initial begin
        for (k = 0; k < 4; k = k + 1) begin
            D[k] = {N{1'b0}};
        end
        S = 2'b0;
        for(i = 0; i < 16 * (2 ** (N - 1)); i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                #1 S = S + 1;
            end
            #1 D = D + 1;
        end
        $stop;
    end
endmodule

// testbench that completely tests any multiplexer
module muxTest(
);
    parameter M = 1, N = 3;
    logic [2**N - 1:0] [M - 1: 0] D;
    logic [N - 1:0] S;
    logic [M - 1: 0] Y;
    integer i, j, k;
    mux#(M, N) uut( .Y(Y),
                .D(D),
                .S(S));
    initial begin
        for (k = 0; k < 2**N; k = k + 1) begin
            D[k] = {N{1'b0}};
        end
        S = 2'b0;
        for(i = 0; i < (2**M) * (2**(2**N)); i = i + 1) begin
            for (j = 0; j < 2**N; j = j + 1) begin
                #1 S = S + 1;
            end
            #1 D = D + 1;
        end
        $stop;
    end
endmodule