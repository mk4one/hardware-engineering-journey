@echo off
rem Same as run_sim.bat but opens the Questa GUI with the waveform loaded
rem and leaves it open: run_wave.bat <lab_name> [tb_name]
setlocal

if "%~1"=="" (
    echo Usage: run_wave.bat ^<lab_name^> [tb_name]
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "SIM_TCL=%SCRIPT_DIR%sim.tcl"
set "SIM_TCL=%SIM_TCL:\=/%"

if "%VSIM_EXE%"=="" (
    set "VSIM_EXE=vsim"
)

"%VSIM_EXE%" -do "source {%SIM_TCL%}; run_lab_gui {%~1} {%~2}"
