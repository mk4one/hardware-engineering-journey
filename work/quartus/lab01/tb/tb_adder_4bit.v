`timescale 1ns/1ps

module tb_adder_4bit;
    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    integer i, j, k;
    integer errors;
    reg [4:0] expected;

    adder_4bit u_dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        errors = 0;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    a = i[3:0];
                    b = j[3:0];
                    cin = k[0];
                    #5;

                    expected = a + b + cin;
                    if ({cout, sum} !== expected) begin
                        errors = errors + 1;
                        $display("FAIL: a=%0d b=%0d cin=%0d -> got cout=%b sum=%0d, expected cout=%b sum=%0d",
                                  a, b, cin, cout, sum, expected[4], expected[3:0]);
                    end

                    #5;
                end
            end
        end

        if (errors == 0)
            $display("PASS: all %0d cases matched", 16 * 16 * 2);
        else
            $display("FAIL: %0d / %0d cases mismatched", errors, 16 * 16 * 2);

        $finish;
    end
endmodule
