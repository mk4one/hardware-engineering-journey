module tb_adder_1bit;
    reg a, b, cin;
    wire sum, cout;
    integer i, j, k;
    integer errors;
    reg [1:0] expected;   // sum(1비트)+cout(1비트) = 2비트

    adder_1bit u_dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        errors = 0;
        
        for (i = 0; i < 2; i=i+1) begin
            for (j = 0; j < 2; j=j+1) begin
                for (k = 0; k < 2; k=k+1) begin
                    a = i;
                    b = j;
                    cin = k;
                    #10;
                    
                    // 여기부터 채워보세요:
                    // 1) expected 계산 (a+b+cin)
                    expected = a + b + cin;
                    // 2) {cout,sum}과 expected 비교
                    if ({cout, sum} !== expected) begin
                        errors = errors + 1;
                        $display("FAIL: a=%0d b=%0d cin=%0d -> got cout=%b sum=%0d, expected cout=%b sum=%0d",
                                  a, b, cin, cout, sum, expected[1], expected[0]);
                    end
                    // 3) 다르면 errors 증가, $display로 출력
                end
            end
        end

        if (errors == 0)
            $display("PASS: all %0d cases matched", 2 * 2 * 2);
        else
            $display("FAIL: %0d / %0d cases mismatched", errors, 2 * 2 * 2);

        // 마지막에 errors==0이면 PASS, 아니면 FAIL 출력
        
        $finish;
    end
endmodule