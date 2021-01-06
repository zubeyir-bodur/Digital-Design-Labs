`timescale 1ns / 1ps

// Testbench for 3:8 decoder
module test3to8decoder();
    logic [2:0]a;
    logic [7:0]y;
    threeTo8decoder test( a, y);
    initial begin
        a = 3'b0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    a[0] = ~a[0]; #10;
                end
                a[1] = ~a[1]; #10;
             end
             a[2] = ~a[2]; #10;
        end
    $stop;
    end
endmodule

// Testbench for 8:1 MUX
module test8to1mux();
    logic [2:0]s;
    logic [7:0]d;
    logic y;
    eightTo1mux test( s, d, y);
    initial begin
        s = 3'b0; d = 8'b0; #1;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    repeat(2) begin
                        repeat(2) begin
                            repeat(2) begin
                                repeat(2) begin
                                    repeat(2) begin
                                        repeat(2) begin
                                            repeat(2) begin
                                                repeat(2) begin
                                                    d[0] = ~d[0]; #1;
                                                end
                                                d[1] = ~d[1]; #1;
                                            end
                                            d[2] = ~d[2]; #1;
                                        end
                                        d[3] = ~d[3]; #1;
                                    end
                                    d[4] = ~d[4]; #1;
                                end
                                d[5] = ~d[5]; #1;
                            end
                            d[6] = ~d[6]; #1;
                        end
                        d[7] = ~d[7]; #1;
                    end
                    s[0] = ~s[0]; #1;
                end
                s[1] = ~s[1]; #1;
            end
            s[2] = ~s[2]; #1;
        end
    $stop;                            
    end                                 
endmodule

// Testbench for boolean function F(A,B,C,D)
// =  ?(1, 2, 7, 8, 9, 10, 12, 13)
module testfunctionF();
    logic a, b, c, d, y;
    functionF test(a, b, c, d, y);
    initial begin
        a = 0; b = 0; c = 0; d = 0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    repeat(2) begin
                        d = ~d; #10;
                    end
                    c = ~c; #10;
                end
                b = ~b; #10;
            end
            a = ~a; #10;
        end
    $stop;
    end
endmodule