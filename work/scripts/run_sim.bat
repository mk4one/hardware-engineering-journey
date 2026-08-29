@echo off
rem Quick CLI entry point: run_sim.bat <lab_name>
setlocal

if "%~1"=="" (
    echo Usage: run_sim.bat ^<lab_name^>
    exit /b 1
)

set "SCRIPT_DIR=%~dp0"
set "SIM_TCL=%SCRIPT_DIR%sim.tcl"
set "SIM_TCL=%SIM_TCL:\=/%"

if "%VSIM_EXE%"=="" (
    set "VSIM_EXE=vsim"
)

"%VSIM_EXE%" -c -do "source {%SIM_TCL%}; run_lab {%~1}; quit -f"
