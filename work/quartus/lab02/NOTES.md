# lab02 - MUX, Assembly (RV32I)

## 구현
- 2 to 1 MUX
- 2 to 1 MUX to 4 to 1 MUX
- Assembly -> Binary practice

## 막혔던 것
- B-format 즉시값 배치 (20분)
  → imm[0]이 생략되는 이유를 몰라서
  → 명령어는 항상 짝수 주소 → 최하위 비트 항상 0

| 뜻 | 용어 | 설명 |
|----|------|-----|
| 스택 인자 | stack arguments | 인자가 8개 넘으면 나머지는 스택으로 전달 |
| 호출 규약 | calling convention | 인자/반환값 위치, 레지스터 저장 책임을 정한 약속 |
| 스필 | spill | 레지스터 부족으로 지역 변수를 스택에 밀어내는 것 |