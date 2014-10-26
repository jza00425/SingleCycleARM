vlib work
vmap work
vlog -sv -work work -novopt +incdir+./src/ -nocovercells ./src/*.sv
vlog  -work work -novopt +incdir+./src/ -nocovercells ./447src/*.v
vsim work.testbench
# run -all
