/**
 * Title: Simple Processor Datapath
 * Author: Zubeyir Bodur
 * ID: 21702382
 * Section: 4
 * Lab : 5
 * Description: Testbenches
 */
`timescale 1ns / 1ps

module datapathSimTest(
    );
    logic [3:0] ALUResult;
    logic clk, wr_en;
    logic [1:0] ALUSel;
    logic [2:0] AddrSrc1, AddrSrc2, AddrDest;
    logic isExternal;
    logic [3:0] EXTDATA;
    integer i, j;
    
    datapathSim uut(.ALUResult(ALUResult),
                    .clk(clk),
                    .wr_en(wr_en),
                    .ALUSel(ALUSel),
                    .AddrSrc1(AddrSrc1),
                    .AddrSrc2(AddrSrc2),
                    .AddrDest(AddrDest),
                    .isExternal(isExternal),
                    .EXTDATA(EXTDATA));
                    
    initial begin
        wr_en = 0; clk = 0; AddrSrc1 = 0; AddrSrc2 = 3'b111;
        AddrDest = 0; EXTDATA = 0; ALUSel = 2'b0; isExternal = 0; #10;
        for (i = 0; i < 32; i = i + 1) begin
            #1 clk = ~clk;
        end
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                #1 clk = ~clk; #1 clk = ~clk;
                ALUSel = ALUSel + 1;
            end
            AddrSrc1 = AddrSrc1 + 1;
            AddrSrc2 = AddrSrc2 - 1; 
        end
        #5 EXTDATA = 4'b1111; AddrDest = 3'b101; isExternal = 1;
        for (i = 0; i < 6; i = i + 1) begin
            #1 clk = ~clk;
        end 
        #5 wr_en = 1;
        for (i = 0; i < 6; i = i + 1) begin
            #1 clk = ~clk;
        end
        #5 wr_en = 0;
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                #1 clk = ~clk; #1 clk = ~clk;
                ALUSel = ALUSel + 1;
            end
            AddrSrc1 = AddrSrc1 + 1;
            AddrSrc2 = AddrSrc2 - 1; 
        end
        $stop;
    end
endmodule

// simple testbench for a register file
module registerFileTest(
    );
    logic [3:0] rdd1, rdd2;
    logic [2:0] rda1, rda2;
    logic [2:0] wra;
    logic [3:0] wrd;
    logic wr_en, clk;
    integer i;
    
    registerFile RF(.rdd1(rdd1),
                    .rdd2(rdd2),
                    .rda1(rda1),
                    .rda2(rda2),
                    .wra(wra),
                    .wrd(wrd),
                    .wr_en(wr_en),
                    .clk(clk));
                    
    initial begin
        wr_en = 0; clk = 0; rda1 = 0; rda2 = 3'b111; wra = 0; wrd = 0; #10
        for (i = 0; i < 32; i = i + 1) begin
            #1 clk = ~clk;
        end
        for (i = 0; i < 32; i = i + 1) begin
            #1 clk = ~clk; #1 clk = ~clk;
            rda1 = rda1 + 1;
            rda2 = rda2 - 1; 
        end
        #5 wrd = 4'b1111; wra = 3'b101; #5 wr_en = 1;
        for (i = 0; i < 4; i = i + 1) begin
            #1 clk = ~clk;
        end
        #5 wr_en = 0;
        for (i = 0; i < 32; i = i + 1) begin
            #1 clk = ~clk; #1 clk = ~clk;
            rda1 = rda1 + 1;
            rda2 = rda2 - 1;
        end
        $stop;
    end
endmodule

// working ALU
module aluTest(
    );
    parameter N = 4;
    logic [N - 1:0] A, B, ALUResult;
    logic [1:0] ALUSel;
    integer i, j, k;
    alu#(N) uut(.res(ALUResult),
                .A(A),
                .B(B),
                .sel(ALUSel));
    initial begin
        A = 0; B = 0; ALUSel = 0; #10
        for (i = 0; i < 4 ; i = i + 1) begin
            for (j = 0; j < 2**N ; j = j + 1) begin
                for (k = 0; k < 2**N ; k = k + 1) begin
                    #10 B = B + 1;
                end
                #10 A = A + 1;
            end
            #10 ALUSel = ALUSel + 1;
        end
        $stop;
    end
endmodule

// testbench for register with SYNCHRONOUS reset, & preferrably load
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
