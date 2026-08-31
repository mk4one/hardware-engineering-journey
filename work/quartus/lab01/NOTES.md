# lab01 - 4bit Ripple Carry Adder

## 구현
- adder_1bit: full adder
- adder_4bit: rippe carry adder 4bit;

## 검증
- 전수 검증 512 케이스 (16 × 16 × 2)
- PASS

## 막혔던 것
- input 포트에 assign 시도 → input은 모듈 안에서 구동 불가
- cout을 [2:0]으로 잡아 최종 캐리 누락 → 출력 포트 vs 내부 wire 구분
- 포트 선언에서 세미콜론 사용 → 괄호 안은 쉼표

## 배운 것
- 모듈은 자기 입력값을 정하지 않는다. 부르는 쪽이 정한다
- cin이 입력인 이유: 8비트 확장, 뺄셈(+1)