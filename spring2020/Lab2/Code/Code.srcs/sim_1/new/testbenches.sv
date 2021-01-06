`timescale 1ns / 1ps

module testAdder();
    logic a, b, c_in, c_out, sum;
    oneBitFullAdder test( a, b, c_in, c_out, sum);
    initial begin
        a = 0; b = 0; c_in = 0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    c_in = ~c_in; #10;
                end
                b = ~b; #10;
             end
             a = ~a; #10;
        end
    $stop;
    end
endmodule

module testFullAdder();
    logic a, b, c_in, c_out, sum;
    fullAdder test( a, b, c_in, c_out, sum);
    initial begin
        a = 0; b = 0; c_in = 0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    c_in = ~c_in; #10;
                end
                b = ~b; #10;
             end
             a = ~a; #10;
        end
    $stop;
    end
endmodule   

module testFullSubstractor();
    logic a, b, b_in, dif, b_out;
    fullSubs test( a, b, b_in, b_out, dif);
    initial begin
        a = 0; b = 0; b_in = 0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    b_in = ~b_in; #10;
                end
                b = ~b; #10;
             end
             a = ~a; #10;
        end
    $stop;
    end
endmodule       

module testTwoBitAdder();
    logic a_1, a_0, b_1, b_0, c_in,  c_out, sum_1, sum_0;
    TwoBitAdder test( a_1, a_0, b_1, b_0, c_in, c_out, sum_1, sum_0 );
    initial begin
        a_1 = 0; a_0 = 0 ; b_1 = 0; b_0 = 0; c_in = 0; #10;
        repeat(2) begin
            repeat(2) begin
                repeat(2) begin
                    repeat(2) begin
                        repeat(2) begin
                            b_0 = ~b_0; #10;
                        end
                        b_1 = ~b_1; #10;
                    end
                    a_0 = ~a_0; #10;
                 end
                 a_1 = ~a_1; #10;
             end    
             c_in = ~c_in; #10;
        end
    $stop;
    end
endmodule