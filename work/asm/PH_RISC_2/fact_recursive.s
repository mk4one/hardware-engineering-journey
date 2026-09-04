# fact_recursive.s
# 재귀 팩토리얼 - RISC-V (RV32I + M extension for mul)
#
# int fact(int n) {
#     if (n <= 1) return 1;
#     return n * fact(n-1);
# }
#
# 레지스터 할당
#   a0 (x10) : 인자 / 반환값 (ABI 규약)
#   ra (x1)  : 복귀 주소 (ABI 규약)
#   sp (x2)  : 스택 포인터 (ABI 규약)
#   s2 (x18) : n 보관용 (callee-saved, 재귀 호출을 건너뛰어 살아남아야 함)
#   t0 (x5)  : 비교용 상수 1 (caller-saved, 짧게 쓰고 버림)

main:
    li   a0, 3              # 인자 n = 3 을 a0에 전달
    jal  ra, fact           # ra <- PC+4 (돌아올 주소), PC <- fact
    # 여기 도착 시 a0 = 6

    li   a7, 10             # 시스템 콜 번호 10 = exit
    ecall

fact:
    # ---- 프롤로그 ----
    addi sp, sp, -16        # 스택 프레임 확보 (스택은 아래로 자람, 16바이트 정렬)
    sw   ra, 12(sp)         # 복귀 주소 대피 (재귀 호출 시 ra가 덮어써지므로)
    sw   s2,  8(sp)         # s2의 "이전 값" 대피 (callee-saved 규약)

    addi s2, a0, 0          # 받은 인자 n을 s2에 보관 (= mv s2, a0)

    # ---- 종료 조건: n <= 1 ----
    li   x5, 1
    ble  s2, x5, Done_base  # n <= 1 이면 기저 경로로

    # ---- 재귀 호출 ----
    addi a0, s2, -1         # 인자로 n-1 준비 (a0은 jal이 건드리지 않음)
    jal  ra, fact           # fact(n-1). 반환 후 a0에 결과, s2는 복구되어 살아있음

    mul  a0, s2, a0         # n * fact(n-1)
    j    Done               # 기저 경로를 건너뛰고 에필로그로

Done_base:
    li   a0, 1              # 기저 조건 반환값

Done:
    # ---- 에필로그 (프롤로그의 역순) ----
    lw   s2,  8(sp)         # s2 복구
    lw   ra, 12(sp)         # 복귀 주소 회수
    addi sp, sp, 16         # 스택 프레임 반환
    jalr x0, ra, 0          # ra로 복귀 (= ret). rd=x0이라 저장은 무효화