// 이것부터 짜보세요
module mux2 (
    input  a, b,
    input  sel,
    output y
);
    assign y = sel ? b : a;
    // 채우기
endmodule

// 그다음 이걸 3개 인스턴스화해서 4:1 만들기
module mux4 (
    input  a, b, c, d,
    input  [1:0] sel,
    output y
);
    wire [1:0] mux_wire;
    mux2 mux2_0 (.a(a), .b(b), .sel(sel[0]), .y(mux_wire[0]));
    mux2 mux2_1 (.a(c), .b(d), .sel(sel[0]), .y(mux_wire[1]));
    mux2 mux2_2 (.a(mux_wire[0]), .b(mux_wire[1]), .sel(sel[1]), .y(y));
    // 채우기
endmodule

module op_practice (
    input  [7:0] a,
    output all_ones,      // a의 모든 비트가 1이면 1
    output any_bit_set,   // a에 1이 하나라도 있으면 1
    output [7:0] inverted // 전체 반전
);
    // 채우기
    assign all_ones = &a;
    assign any_bit_set = |a;
    assign inverted = ~a;
endmodule

module vec_practice (
    input  [7:0] a,
    output [3:0] upper_nibble,   // a의 상위 4비트
    output [3:0] lower_nibble,   // a의 하위 4비트
    output [15:0] sign_extended, // a를 16비트로 부호 확장
    output [15:0] swapped        // upper와 lower를 뒤바꿔서 16비트로: {lower, upper}
);
    // 채우기
    assign upper_nibble = a[7:4];
    assign lower_nibble = a[3:0];
    assign sign_extended = {{8{a[7]}}, a};
    assign swapped = {lower_nibble, upper_nibble};

endmodule

module assign_practice (
    input  [3:0] a,
    input  [3:0] b,
    output eq,        // a == b 이면 1
    output gt,         // a > b 이면 1
    output [3:0] max   // a와 b 중 큰 값
);
    // 채우기
    assign eq = (a == b) ? 1 : 0;
    assign gt = (a > b) ? 1 : 0;
    assign max = (a > b) ? a : b;
endmodule