# RISC-V RV32I Reference

> RV32I Base Integer Instruction Set — 기본 40개 명령어
> 찾아보는 표. 개념 설명과 "왜 이렇게 설계됐는가"는 `work/notes/PH_RISC_2.md`
>
> RV64 전용(`ld`, `sd`, `addiw`, `slliw` 등)과 확장(M/A/F/D, Zicsr, Zifencei)은 제외.

---

## 명령어 형식

```
 31           25 24    20 19    15 14  12 11         7 6      0
┌───────────────┬────────┬────────┬──────┬────────────┬────────┐
│ funct7        │ rs2    │ rs1    │funct3│ rd         │ opcode │  R
├───────────────┴────────┼────────┼──────┼────────────┼────────┤
│ imm[11:0]              │ rs1    │funct3│ rd         │ opcode │  I
├───────────────┬────────┼────────┼──────┼────────────┼────────┤
│ imm[11:5]     │ rs2    │ rs1    │funct3│ imm[4:0]   │ opcode │  S
├───────────────┼────────┼────────┼──────┼────────────┼────────┤
│ imm[12|10:5]  │ rs2    │ rs1    │funct3│ imm[4:1|11]│ opcode │  B
├───────────────┴────────┴────────┴──────┼────────────┼────────┤
│ imm[31:12]                             │ rd         │ opcode │  U
├────────────────────────────────────────┼────────────┼────────┤
│ imm[20|10:1|11|19:12]                  │ rd         │ opcode │  J
└────────────────────────────────────────┴────────────┴────────┘
```

**필드 위치는 형식과 무관하게 고정이다.**

| 필드 | 비트 | 비고 |
|---|---|---|
| opcode | `[6:0]` | 항상 `11`로 끝남 (32비트 명령어 표시) |
| rd | `[11:7]` | R, I, U, J |
| funct3 | `[14:12]` | R, I, S, B |
| rs1 | `[19:15]` | R, I, S, B |
| rs2 | `[24:20]` | R, S, B |
| funct7 | `[31:25]` | R |
| 즉시값 부호 비트 | `[31]` | 형식과 무관하게 항상 여기 |

---

## opcode 일람

| 형식 | opcode | 이름 | 소속 명령어 |
|---|---|---|---|
| R | `0110011` | OP | 레지스터 연산 10개 |
| I | `0010011` | OP-IMM | 즉시값 연산 9개 |
| I | `0000011` | LOAD | lb lh lw lbu lhu |
| I | `1100111` | JALR | jalr |
| I | `1110011` | SYSTEM | ecall ebreak |
| I | `0001111` | MISC-MEM | fence |
| S | `0100011` | STORE | sb sh sw |
| B | `1100011` | BRANCH | 분기 6개 |
| U | `0110111` | LUI | lui |
| U | `0010111` | AUIPC | auipc |
| J | `1101111` | JAL | jal |

---

## R-Type — OP `0110011`

| 명령어 | funct7 | funct3 | 동작 |
|---|---|---|---|
| add | `0000000` | `000` | rd = rs1 + rs2 |
| sub | `0100000` | `000` | rd = rs1 - rs2 |
| sll | `0000000` | `001` | rd = rs1 << rs2[4:0] |
| slt | `0000000` | `010` | rd = (rs1 < rs2) ? 1 : 0 — 부호 있음 |
| sltu | `0000000` | `011` | rd = (rs1 < rs2) ? 1 : 0 — 부호 없음 |
| xor | `0000000` | `100` | rd = rs1 ^ rs2 |
| srl | `0000000` | `101` | rd = rs1 >> rs2[4:0] — 0으로 채움 |
| sra | `0100000` | `101` | rd = rs1 >> rs2[4:0] — 부호 비트 복사 |
| or | `0000000` | `110` | rd = rs1 \| rs2 |
| and | `0000000` | `111` | rd = rs1 & rs2 |

시프트 양은 `rs2`의 **하위 5비트만** 쓴다 (32비트 레지스터이므로 0~31).
`sub`와 `sra`만 funct7이 `0100000`.

---

## I-Type — OP-IMM `0010011`

| 명령어 | funct3 | imm[11:5] | 동작 |
|---|---|---|---|
| addi | `000` | — | rd = rs1 + sext(imm) |
| slti | `010` | — | rd = (rs1 < sext(imm)) ? 1 : 0 — 부호 있음 |
| sltiu | `011` | — | rd = (rs1 < sext(imm)) ? 1 : 0 — 부호 없음 비교 |
| xori | `100` | — | rd = rs1 ^ sext(imm) |
| ori | `110` | — | rd = rs1 \| sext(imm) |
| andi | `111` | — | rd = rs1 & sext(imm) |
| slli | `001` | `0000000` | rd = rs1 << shamt |
| srli | `101` | `0000000` | rd = rs1 >> shamt — 0으로 채움 |
| srai | `101` | `0100000` | rd = rs1 >> shamt — 부호 비트 복사 |

- 시프트 세 개만 `[31:25]`를 쓴다. `shamt = inst[24:20]` (5비트, 0~31).
  남는 7비트로 `srli`/`srai`를 구분
- **RV32는 funct7(7비트).** RV64는 shamt가 6비트라 funct6
- `sltiu`는 즉시값을 **부호 확장한 뒤 부호 없는 값으로 비교**한다
- `subi`는 없다 — `addi rd, rs1, -imm`

---

## I-Type — LOAD `0000011`

| 명령어 | funct3 | 동작 |
|---|---|---|
| lb | `000` | rd = sext(mem8[rs1 + sext(imm)]) |
| lh | `001` | rd = sext(mem16[rs1 + sext(imm)]) |
| lw | `010` | rd = mem32[rs1 + sext(imm)] |
| lbu | `100` | rd = zext(mem8[rs1 + sext(imm)]) |
| lhu | `101` | rd = zext(mem16[rs1 + sext(imm)]) |

funct3 구조가 회로에 그대로 연결된다.

```
funct3[2]    0 = 부호 확장, 1 = 영 확장
funct3[1:0]  00 = byte, 01 = half, 10 = word
```

---

## I-Type — JALR `1100111`

| 명령어 | funct3 | 동작 |
|---|---|---|
| jalr | `000` | rd = PC + 4 ; PC = (rs1 + sext(imm)) & ~1 |

목적지 최하위 비트를 강제로 0으로 만든다. **PC 상대가 아니다** — 기준이 `rs1`.

---

## I-Type — SYSTEM `1110011` / MISC-MEM `0001111`

| 명령어 | funct3 | imm[11:0] | 기계어 | 동작 |
|---|---|---|---|---|
| ecall | `000` | `000000000000` | `0x00000073` | 환경 호출 (OS 진입) |
| ebreak | `000` | `000000000001` | `0x00100073` | 디버거 중단 |
| fence | `000` | pred/succ 필드 | — | 메모리 순서 보장 |

`ecall`/`ebreak`는 rs1 = rd = `00000`으로 고정이라 기계어가 상수 하나로 정해진다.
`fence`는 `[27:24]`=pred, `[23:20]`=succ, `[31:28]`=fm. 단일 코어 CPU에서는 `nop` 취급 가능.

---

## S-Type — STORE `0100011`

| 명령어 | funct3 | 동작 |
|---|---|---|
| sb | `000` | mem8[rs1 + sext(imm)] = rs2[7:0] |
| sh | `001` | mem16[rs1 + sext(imm)] = rs2[15:0] |
| sw | `010` | mem32[rs1 + sext(imm)] = rs2 |

**로드와 달리 부호 있는/없는 구분이 없다.** 저장은 하위 비트를 자르는 것이라 확장할 게 없다.

---

## B-Type — BRANCH `1100011`

| 명령어 | funct3 | 조건 |
|---|---|---|
| beq | `000` | rs1 == rs2 |
| bne | `001` | rs1 != rs2 |
| blt | `100` | rs1 < rs2 — 부호 있음 |
| bge | `101` | rs1 >= rs2 — 부호 있음 |
| bltu | `110` | rs1 < rs2 — 부호 없음 |
| bgeu | `111` | rs1 >= rs2 — 부호 없음 |

성립하면 `PC = PC + sext(imm)`, 아니면 `PC = PC + 4`.
`010`, `011`은 비어 있다 (확장용).
`bgt`, `ble`는 없다 — 피연산자를 뒤집어 `blt`, `bge`로 쓴다.

---

## U-Type

| 명령어 | opcode | 동작 |
|---|---|---|
| lui | `0110111` | rd = imm << 12 — 절대 |
| auipc | `0010111` | rd = PC + (imm << 12) — PC 상대 |

`<< 12`를 하드웨어가 수행하는 게 아니라 **즉시값이 `[31:12]`에 앉아 있어서** 그렇게 된다.
`lui x7, 0x1` → `x7 = 0x00001000` (16진수 000 세 자리가 뒤에 붙는다).

---

## J-Type

| 명령어 | opcode | 동작 |
|---|---|---|
| jal | `1101111` | rd = PC + 4 ; PC = PC + sext(imm) |

`rd`가 `ra`면 함수 호출, `x0`면 단순 점프. **같은 명령어가 rd 하나로 용도가 갈린다.**

---

## 즉시값 조립

명령어 비트 → 즉시값 비트 대응. 부호 확장은 항상 `inst[31]`을 복사한다.

| 형식 | 폭 | 대응 |
|---|---|---|
| I | 12 | `imm[11:0] = inst[31:20]` |
| S | 12 | `imm[11:5] = inst[31:25]`, `imm[4:0] = inst[11:7]` |
| B | 13 | `imm[12] = inst[31]`, `imm[10:5] = inst[30:25]`, `imm[4:1] = inst[11:8]`, `imm[11] = inst[7]`, `imm[0] = 0` |
| U | 32 | `imm[31:12] = inst[31:12]`, `imm[11:0] = 0` |
| J | 21 | `imm[20] = inst[31]`, `imm[10:1] = inst[30:21]`, `imm[11] = inst[20]`, `imm[19:12] = inst[19:12]`, `imm[0] = 0` |

**B와 J는 `imm[0]`을 저장하지 않는다.** 명령어는 항상 짝수 주소에 있어 최하위 비트가
언제나 0이므로, 12비트 저장으로 13비트 범위 / 20비트 저장으로 21비트 범위를 얻는다.

### 도달 범위 (RV32)

| 수단 | 즉시값 | 범위 | 명령어 수 | 기준 |
|---|---|---|---|---|
| beq 계열 | 13비트 | ±4KB | 1 | PC |
| jal | 21비트 | ±1MB | 1 | PC |
| lui + jalr | 32비트 | 4GB 전체 | 2 | 절대 |
| auipc + jalr | 32비트 | ±2GB | 2 | PC |
| lw + jalr | — | 제한 없음 | 2 | 메모리 |
| lw / sw 오프셋 | 12비트 | ±2KB | 1 | rs1 |

---

## 레지스터

| 번호 | ABI 이름 | 용도 | 저장 책임 |
|---|---|---|---|
| x0 | zero | 항상 0 (쓰기는 무시됨) | — |
| x1 | ra | 반환 주소 (return address) | Caller |
| x2 | sp | 스택 포인터 (stack pointer) | Callee |
| x3 | gp | 전역 포인터 (global pointer) | — |
| x4 | tp | 스레드 포인터 (thread pointer) | — |
| x5 | t0 | 임시 / 보조 링크 레지스터 | Caller |
| x6–x7 | t1–t2 | 임시 (temporary) | Caller |
| x8 | s0 / fp | 저장 레지스터 / 프레임 포인터 | Callee |
| x9 | s1 | 저장 레지스터 (saved) | Callee |
| x10–x11 | a0–a1 | 인자 / 반환값 | Caller |
| x12–x17 | a2–a7 | 인자 (argument) | Caller |
| x18–x27 | s2–s11 | 저장 레지스터 | Callee |
| x28–x31 | t3–t6 | 임시 | Caller |

- **Caller-saved** — 부르는 쪽이 저장. 호출을 건너 살아남지 않음
- **Callee-saved** — 불린 쪽이 저장. 호출 후에도 값이 유지됨
- `ra`는 `jal`이 덮어쓰므로 **자식을 부르는 함수는 반드시 저장**해야 한다
- `sp`는 16바이트 정렬을 유지한다
- 저장 책임은 하드웨어가 강제하지 않는 **규약(calling convention)**이다

---

## 의사 명령어 (Pseudo-instructions)

어셈블러가 실제 명령어로 풀어준다. 대부분 `x0`를 이용한다.

| 의사 명령어 | 실제 확장 |
|---|---|
| `nop` | `addi x0, x0, 0` |
| `li rd, imm` | `addi rd, x0, imm` (12비트 내) / `lui` + `addi` (초과 시) |
| `la rd, sym` | `auipc rd, %pcrel_hi(sym)` + `addi rd, rd, %pcrel_lo(...)` |
| `mv rd, rs` | `addi rd, rs, 0` |
| `not rd, rs` | `xori rd, rs, -1` |
| `neg rd, rs` | `sub rd, x0, rs` |
| `seqz rd, rs` | `sltiu rd, rs, 1` |
| `snez rd, rs` | `sltu rd, x0, rs` |
| `sltz rd, rs` | `slt rd, rs, x0` |
| `sgtz rd, rs` | `slt rd, x0, rs` |
| `beqz rs, off` | `beq rs, x0, off` |
| `bnez rs, off` | `bne rs, x0, off` |
| `blez rs, off` | `bge x0, rs, off` |
| `bgez rs, off` | `bge rs, x0, off` |
| `bltz rs, off` | `blt rs, x0, off` |
| `bgtz rs, off` | `blt x0, rs, off` |
| `bgt rs, rt, off` | `blt rt, rs, off` |
| `ble rs, rt, off` | `bge rt, rs, off` |
| `bgtu rs, rt, off` | `bltu rt, rs, off` |
| `bleu rs, rt, off` | `bgeu rt, rs, off` |
| `j off` | `jal x0, off` |
| `jal off` | `jal ra, off` |
| `jr rs` | `jalr x0, rs, 0` |
| `jalr rs` | `jalr ra, rs, 0` |
| `ret` | `jalr x0, ra, 0` |
| `call off` | `auipc ra, offHi` + `jalr ra, ra, offLo` |
| `tail off` | `auipc t1, offHi` + `jalr x0, t1, offLo` |

### lui + addi 캐리 보정

**하위 12비트의 bit 11이 1이면 상위 20비트에 1을 더한다.**

`addi`가 즉시값을 부호 확장하므로, bit 11이 1이면 정확히 4096을 뺀 셈이 된다.
상위 20비트에 1을 더하면 `<< 12` 되어 정확히 4096이 되므로 상쇄된다.

```
0xDEADBEEF
  보정 없이  lui 0xDEADB + addi 0xEEF  →  0xDEADAEEF   (상위 1 부족)
  보정 후    lui 0xDEADC + addi 0xEEF  →  0xDEADBEEF   ✓
```

보정 여부는 **상수 전체의 부호와 무관하다. bit 11 하나만 본다.**

---

## 검산 규칙

인코딩 표가 맞는지 눈으로 확인하는 법.

1. **모든 opcode는 `11`로 끝난다.** 32비트 명령어라는 표시.
   압축 명령어(RVC)는 `00`/`01`/`10`으로 끝난다. `11`이 아니면 그 표는 틀렸다
2. **같은 opcode + 같은 funct3를 가진 명령어가 둘 있으면 틀렸다**
3. 필드 폭: opcode 7, rd/rs1/rs2 각 5, funct3 3, funct7 7 → 합 32

### 혼동하기 쉬운 opcode

```
1100011  BRANCH        0110011  OP        0010011  OP-IMM
1100111  JALR          0110111  LUI       0010111  AUIPC
1101111  JAL
```

---

## 인코딩 예시

디코더를 만들 때 대조용. 아래 값은 스크립트로 교차 검증했다.

| 어셈블리 | 형식 | 기계어 |
|---|---|---|
| `add x5, x6, x7` | R | `0x007302B3` |
| `addi x5, x6, 100` | I | `0x06430293` |
| `lw x5, 8(x6)` | I (LOAD) | `0x00832283` |
| `beq x5, x6, 16` | B | `0x00628863` |
| `lui x5, 0x12345` | U | `0x123452B7` |
| `jal x1, 2048` | J | `0x001000EF` |
| `ecall` | I (SYSTEM) | `0x00000073` |
| `ebreak` | I (SYSTEM) | `0x00100073` |

`lui`는 즉시값이 상위 16진수 자리에 그대로 보인다 (`0x12345` → `0x12345___`).

---

## 명령어 수

| 형식 | 개수 |
|---|---|
| R (OP) | 10 |
| I (OP-IMM) | 9 |
| I (LOAD) | 5 |
| I (JALR) | 1 |
| I (SYSTEM) | 2 |
| I (MISC-MEM) | 1 |
| S (STORE) | 3 |
| B (BRANCH) | 6 |
| U (LUI, AUIPC) | 2 |
| J (JAL) | 1 |
| **합계** | **40** |

CSR 명령어 6개(`csrrw` 등)는 Zicsr, `fence.i`는 Zifencei 확장으로 분리되어
RV32I 기본에 포함되지 않는다.
