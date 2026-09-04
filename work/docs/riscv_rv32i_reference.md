# RISC-V RV32I Reference

## 명령어 형식
(R/I/S/B/U/J 비트 배치 표)

## R-Type (opcode: 0110011)
| 명령어 | funct7 | funct3 | 동작 |
|--------|---------|--------|------|
| add | 0000000 | 000 | rd = rs1 + rs2 |
| sub | 0100000 | 000 | rd = rs1 - rs2 |
| sll | 0000000 | 001 | rd = rs1 << rs2 |
## I-Type (산술, opcode: 0010011)
| 명령어 | funct3 | 동작 |
|--------|---------|--------|
| addi | 000 | rd = rs1 + constant |
| 
## I-Type (로드, opcode: 0000011)
| 명령어 | funct3 | 동작 |
|--------|---------|--------|
| lw | 010 | rd = address[rs1 + imm] |

## S-Type (opcode: 0100011)
...

## B-Type (opcode: 1100011)
...

## U/J-Type
...

## Pseudo-instructions
| 의사 명령어 | 실제 확장 |

## 레지스터 이름
| x번호 | ABI 이름 | 용도 | 저장 책임 |