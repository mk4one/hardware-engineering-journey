# Reusable Questa runner for this repo's labs (Quartus NativeLink-free).
# Called from run_sim.bat / run_wave.bat, or manually from a `vsim` prompt:
#   source work/scripts/sim.tcl
#   run_lab lab01       ;# headless, prints PASS/FAIL, exits
#   run_lab_gui lab01   ;# opens the waveform, stays open after the run
#
# Compiles every rtl/*.v and tb/*.v under work/quartus/<lab_name>, then
# simulates the module whose file is tb/tb_*.v (first match). Each lab
# gets its own throwaway work library at <lab>/sim_build/work so labs
# never share compiled state.

# Captured now, at source-time: inside a proc, [info script] would
# instead resolve to whatever script Questa is executing when that proc is
# later called (not this file), which points at the wrong directory.
set SIM_TCL_DIR [file dirname [file normalize [info script]]]

proc compile_lab {lab_name} {
    set quartus_dir [file normalize "$::SIM_TCL_DIR/../quartus"]
    set lab_dir     "$quartus_dir/$lab_name"

    if {![file isdirectory $lab_dir]} {
        error "Lab directory not found: $lab_dir"
    }

    set worklib "$lab_dir/sim_build/work"
    if {[file exists $worklib]} {
        vdel -lib $worklib -all
    }
    file mkdir "$lab_dir/sim_build"
    vlib $worklib
    vmap work $worklib

    set rtl_files [glob -nocomplain "$lab_dir/rtl/*.v"]
    set tb_files  [glob -nocomplain "$lab_dir/tb/tb_*.v"]

    if {[llength $rtl_files] == 0} {
        error "No RTL files found in $lab_dir/rtl"
    }
    if {[llength $tb_files] == 0} {
        error "No testbench found in $lab_dir/tb (expected tb/tb_*.v)"
    }

    vlog -work work +incdir+$lab_dir/rtl {*}$rtl_files
    vlog -work work +incdir+$lab_dir/tb  {*}$tb_files

    set tb_names {}
    foreach f $tb_files {
        lappend tb_names [file rootname [file tail $f]]
    }
    return $tb_names
}

# tb_name is optional: leave it blank to run the first tb_*.v found (fine
# while a lab has exactly one testbench). Once a lab has more than one
# (e.g. tb_adder_1bit + tb_adder_4bit), pass the one you want by name:
#   run_lab lab01 tb_adder_1bit
proc run_lab {lab_name {tb_name ""}} {
    set tb_names [compile_lab $lab_name]
    if {$tb_name eq ""} {
        set tb_name [lindex $tb_names 0]
    }
    vsim -c -voptargs=+acc work.$tb_name
    run -all
}

proc run_lab_gui {lab_name {tb_name ""}} {
    set tb_names [compile_lab $lab_name]
    if {$tb_name eq ""} {
        set tb_name [lindex $tb_names 0]
    }
    vsim -voptargs=+acc work.$tb_name
    add wave -r /*
    run -all
    wave zoom full
}
