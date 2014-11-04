onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic :testbench:core:ctrl:exc_en
add wave -noupdate -format Logic :testbench:core:ctrl:is_imm
add wave -noupdate -format Logic :testbench:core:register:pc_we
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:pc_out
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:pc_in
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:inst
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rn_num
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rn_data
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rm_num
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rm_data
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rs_num
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rd_num
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:rd_data
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:alu_out
add wave -noupdate -format Logic :testbench:core:is_alu_for_mem_addr
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:data_result
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:operand2
add wave -noupdate -format Literal -radix hexadecimal -expand :testbench:core:register:mem
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:register:cpsr
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:cpsr_in
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:tmp_cpsr
add wave -noupdate -format Literal -radix binary :testbench:core:final_cpsr_mask
add wave -noupdate -format Literal -radix binary :testbench:core:alu_cpsr
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:shifter:inst
add wave -noupdate -format Logic -radix hexadecimal :testbench:rst_b
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:shifter:shift_amount
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:shifter:shift_type
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:mem_addr
add wave -noupdate -format Literal -radix hexadecimal :testbench:core:mem_data_in
add wave -noupdate -format Literal :testbench:core:mem_write_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1083 fs} 0}
configure wave -namecolwidth 244
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {1268 fs} {1828 fs}
