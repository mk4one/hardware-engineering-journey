`timescale 1ns/1ps

module tb_adder_4bit;

    // TODO: DUT 연결 신호 선언 (reg / wire 구분)
    reg [3:0] a;
    reg [3:0] b;
    reg cin;
    wire [3:0] sum;
    wire cout;

    // TODO: 검증에 필요한 변수
    integer i,j,k;
    reg [4:0] expected;
    integer errors;
    // TODO: DUT 인스턴스
    adder_4bit DUT(
        .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
    );
    initial begin
        // TODO: 모든 입력 조합 인가 + 검사
        errors = 0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    a = i;
                    b = j;
                    cin = k;
                    #10;
                    expected = a + b + cin;
                    if (expected != {cout, sum}) begin
                        errors = errors + 1;
                        $display("FAIL: a=%0d b=%0d cin=%0d -> got cout=%b sum=%0d, expected cout=%b sum=%0d", a, b, cin, cout, sum, expected[4], expected[3:0]);
                    end
                end
            end
        end
        if (errors == 0) begin
            $display("PASS");
        end
        else begin
            $display("FAIL");
        end
        $finish;
    end

endmodule