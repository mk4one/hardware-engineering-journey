## 실습 워크플로우

새 Lab을 시작할 때부터 검증까지의 흐름입니다.

| 목적 | 위치 | 명령/메뉴 |
|---|---|---|
| 새 랩 폴더 생성 | WSL bash | `mkdir -p work/quartus/[lab_name]/{rtl,tb}` |
| Quartus 프로젝트 생성 | Quartus GUI | `File > New Project Wizard` |
| RTL/TB 작성 | VS Code | `rtl/*.v`, `tb/tb_*.v` |
| 문법 체크 | Quartus GUI | `Processing > Start > Start Analysis & Elaboration` |
| 기능 검증 (PASS/FAIL) | WSL bash | `cmd.exe /c "$(wslpath -w work/scripts/run_sim.bat) [lab_name] [tb_name]"` |
| 파형 확인 | WSL bash | `cmd.exe /c "$(wslpath -w work/scripts/run_wave.bat) [lab_name] [tb_name]"` |

**참고**
- work/scripts/sim.tcl로 Questa를 직접 호출한다. 소스 수정 후에도 항상 최신 파일을 다시 컴파일하므로 별도 준비 없이 바로 쓸 수 있다.<br>
이 스크립트는`rtl/*.v`, `tb/tb_*.v`를 매 실행 시 파일시스템에서 직접 읽어 컴파일하므로 캐시가 낡을 일이 없고, `vsim`과 `run -all`까지 한 번에 수행한다. - Claude Code를 통해 작성
- Quartus GUI는 문법 체크(Analysis & Elaboration)와 추후 FPGA 보드 업로드 용도로만 사용.
- `run_sim.bat`은 헤드리스로 PASS/FAIL만 출력, `run_wave.bat`은 Questa GUI를 열어 파형까지 확인.
- 한 랩에 테스트벤치가 여러 개면(`tb_adder_1bit.v`, `tb_adder_4bit.v`처럼) `[tb_name]`으로
  어떤 걸 돌릴지 지정한다 (`run_sim.bat lab01 tb_adder_1bit`). 생략하면 `tb/` 안에서 처음
  찾은 파일이 자동 선택되므로, 테스트벤치가 둘 이상이면 반드시 명시하는 걸 권장.
- 문법 검사는 Quartus가 아니라 `vlog`(컴파일 단계)가 담당한다. RTL이든 테스트벤치든
  `run_sim.bat`/`run_wave.bat` 실행 시 컴파일 에러가 나면 파일 경로와 줄 번호까지 출력된다.
  Quartus의 Analysis & Elaboration은 합성 가능한 RTL 문법만 검사하며, 테스트벤치(비합성
  구문 포함)는 애초에 검사 대상이 아니다.
