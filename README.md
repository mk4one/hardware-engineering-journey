## 실습 워크플로우

새 Lab을 시작할 때부터 검증까지의 흐름입니다.

| 목적 | 위치 | 명령/메뉴 |
|---|---|---|
| 새 랩 폴더 생성 | WSL bash | `mkdir -p work/quartus/lab02/{rtl,tb}` |
| Quartus 프로젝트 생성 | Quartus GUI | `File > New Project Wizard` |
| RTL/TB 작성 | VS Code | `rtl/*.v`, `tb/tb_*.v` |
| 문법 체크 | Quartus GUI | `Processing > Start > Start Analysis & Elaboration` |
| 기능 검증 (PASS/FAIL) | WSL bash | `cmd.exe /c "$(wslpath -w work/scripts/run_sim.bat) projectName"` |
| 파형 확인 | WSL bash | `cmd.exe /c "$(wslpath -w work/scripts/run_wave.bat) projectName"` |

**참고**
- Quartus의 `Tools > Run Simulation Tool`(NativeLink)은 이 프로젝트에서 라이브러리 생성과
  컴파일까지만 수행하고 `vsim`/`run`은 실행하지 않는다 (테스트벤치가 EDA Tool Settings에
  등록되지 않아서 발생).
  또한 파일 목록을 `.qsf`가 아닌 마지막 Analysis & Synthesis 결과에서
  가져오므로, 소스를 수정해도 재컴파일 없이는 최신 내용이 반영되지 않는다.
  이 두 가지 이유로 NativeLink 대신 `work/scripts/sim.tcl`을 사용한다: 이 스크립트는
  `rtl/*.v`, `tb/tb_*.v`를 매 실행 시 파일시스템에서 직접 읽어 컴파일하므로 캐시가 낡을 일이
  없고, `vsim`과 `run -all`까지 한 번에 수행한다. - Claude Code를 통해 작성
- Quartus GUI는 문법 체크(Analysis & Elaboration)와 추후 FPGA 보드 업로드 용도로만 사용.
- `run_sim.bat`은 헤드리스로 PASS/FAIL만 출력, `run_wave.bat`은 Questa GUI를 열어 파형까지 확인. - Claude Code를 통해 작성
