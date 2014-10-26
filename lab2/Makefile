#
# ECE 18-447 Makefile.
#
# - History:
#   - 2011: Joshua Wise
#   - 2013: Yoongu Kim
#   - 2014: Xiao Bo Zhao
#


###################################################################
### Setup
###################################################################

TIMESTAMP := outputs/$(shell date +%m%d-%H%M%S)
OUTPUT ?= $(TIMESTAMP)

INPUT ?= 447inputs/addiu.s
REGDUMP := $(INPUT:.s=.reg)

BATCH ?= 447inputs/addiu.s

SYNTHDIR = dc
SYNTH = lab
TB = testbench

###################################################################
### Constants
###################################################################

# text attributes: normal, bold, underline
n=\e[0m
b=\e[1m
u=\e[4m

# bold+green
g=\e[1;32m

# bold+red
r=\e[1;31m

# debug message
m=$g18-477 Makefile: $n


###################################################################
### Help Screen
###################################################################

default:
	@echo  "HELP SCREEN"
	@echo  ""
	@echo  "USAGE:"
	@echo  "\tmake TARGET [VARIABLE]..."
	@echo  ""
	@echo  ""
	@echo  "TARGET:"
	@echo  "\tsim"
	@echo  "\t    compiles Verilog found in src directory;"
	@echo  "\t    simulates Verilog using INPUT as input;"
	@echo  "\t    places all outputs (logs, waveforms, regdump, etc.) in OUTPUT"
	@echo  ""
	@echo  "\tverify"
	@echo  "\t    compiles Verilog found in src directory;"
	@echo  "\t    simulates Verilog using INPUT as input;"
	@echo  "\t    places all outputs (logs, waveforms, regdump, etc.) in OUTPUT"
	@echo  "\t    verifies the simulation register-dump against the reference"
	@echo  ""
	@echo  "\tbatch-verify"
	@echo  "\t    similar to verify, but uses BATCH as input"
	@echo  ""
	@echo  "\tsynth"
	@echo  "\t    compiles Verilog found in src directory;"
	@echo  "\t    synthesizes Verilog"
	@echo  "\t    places all outputs (reports, schematics, etc.) in OUTPUT"
	@echo  ""
	@echo  "\tauto"
	@echo  "\t    automatically \"wires\" up Verilog modules found in src/*.v;"
	@echo  "\t    (not mandatory -- merely for your convenience)"
	@echo  ""
	@echo  ""
	@echo  "VARIABLE:"
	@echo  "\tINPUT=ASSEMBLY"
	@echo  "\t    for sim and verify, specifies an input ARM assemply file;"
	@echo  "\t    if unspecified, defaults to 447inputs/addiu.s"
	@echo  ""
	@echo  "\tBATCH=ASSEMBLY FILES"
	@echo  "\t    for batch-verify, specifies one or more input ARM assemply files;"
	@echo  "\t    if unspecified, defaults to 447inputs/addiu.s"
	@echo  ""
	@echo  "\tOUTPUT=DIR"
	@echo  "\t    for all targets, specifies the output directory;"
	@echo  "\t    if unspecified, defaults to outputs/current-timestamp;"
	@echo  ""
	@echo  ""
	@echo  "EXAMPLES:"
	@echo  "\tmake sim"
	@echo  "\tmake sim INPUT=inputs/mytest.s OUTPUT=outputs/myoutput"
	@echo  "\tmake verify"
	@echo  "\tmake verify INPUT=inputs/mytest.s OUTPUT=outputs/myoutput"
	@echo  "\tmake batch-verify BATCH=447inputs/*.s"
	@echo  "\tmake batch-verify BATCH=447inputs/*.s OUTPUT=outputs/myoutput"
	@echo  "\tmake synth"
	@echo  "\tmake synth OUTPUT=outputs/myoutput"
	@echo  ""
	@echo  "(END)"
	@exit 0


###################################################################
### Compile Verilog
###################################################################

compile:
	@echo -e "Copying Verilog into $(OUTPUT)..."
	@mkdir -p $(OUTPUT)/sim/src
	@cp `find src 447src -iname '*.sv' -o -iname '*.v' -o -iname '*.vh'`	$(OUTPUT)/sim/src
	@echo -e "Compiling Verilog..."
	cd $(OUTPUT)/sim
	# $(shell source /mgc/Setup.bash)
	vlib work
	vmap work
	vlog -sv -work work -novopt +incdir+./src -nocovercells ./src/*.sv
	vlog +incdir+./src/ ./src/arm_mem.v
	# ncvlog -sv -linedebug -messages -incdir src src/*.v src/*.sv
	# @if grep '*W' $(OUTPUT)/sim/ncvlog.log >/dev/null; \
		then echo -e 'Compiler log has warnings!'; fi
	# @echo -e "Elaborating Verilog..."
	# cd $(OUTPUT)/sim; ncelab +access+rwc -messages worklib.$(TB)
	# @if grep '*W' $(OUTPUT)/sim/ncelab.log >/dev/null; \
		then echo -e 'Elaborator log has warnings!'; fi


###################################################################
### Assemble ARM Assembly Input
###################################################################

assemble:
	@echo -e "Copying $(INPUT) into $(OUTPUT)..."
	@mkdir -p $(OUTPUT)/sim
	@([ -f $(INPUT) ] && cp $(INPUT) $(OUTPUT)/sim) || \
		(echo -e "ERROR -- test input not found: $(INPUT)"; exit 1)
	@echo -e "Assemblying input in $(OUTPUT)..."
	arm2hex $(INPUT) $(OUTPUT)/sim/mem;


###################################################################
### Simulate Verilog
###################################################################

sim: compile assemble
	@echo -e "$mCopying NCSim configuration into $(OUTPUT)..."
	@cp ncsim/* $(OUTPUT)/sim
	@cp 447ncsim/* $(OUTPUT)/sim
	@echo -e "$mSimulating Verilog in $(OUTPUT)..."
	cd $(OUTPUT)/sim; ncsim worklib.$(TB):module -input 447ncsim.tcl -input ncsim.tcl
	@if grep '*W' $(OUTPUT)/sim/ncsim.log >/dev/null; \
		then echo -e '$m$rSimulator log has warnings!$n'; fi
	@echo -e "$mSimulation of $(INPUT) has completed in $(OUTPUT)."
	@echo -e "$mTo view waveforms, execute the following command: $bsimvision $(OUTPUT)/sim/waveforms.shm$n"


###################################################################
### Verify Simulation
###################################################################

verify: sim
	@([ -f $(REGDUMP) ] && cp $(REGDUMP) $(OUTPUT)/sim) || \
		(echo -e "$mERROR -- reference register-dump not found: $(REGDUMP)"; exit 1)
	447util/tester.pl $(OUTPUT)/sim/$(notdir $(REGDUMP)) $(OUTPUT)/sim/regdump.txt
	@echo -e "$mVerification of $(INPUT) has completed in $(OUTPUT)."
	@echo -e "$mTo view the simulation register-dump, execute the following command: $bcat $(OUTPUT)/sim/regdump.txt$n"

batch-verify:
	for i in $(BATCH); do \
		make verify INPUT=$$i OUTPUT=$(OUTPUT); \
	done


###################################################################
### Synthesize Verilog
###################################################################

synth:
	@mkdir -p $(OUTPUT)/synth/src
	@mkdir -p $(OUTPUT)/synth/447src
	@cp `find src -iname '*.v' -o -iname '*.sv' -o -iname '*.vh'` $(OUTPUT)/synth/src
	@cp `find 447src -iname '*.v' -o -iname '*.sv' -o -iname '*.vh'` $(OUTPUT)/synth/447src
	@cp $(SYNTHDIR)/$(SYNTH).dc $(OUTPUT)/synth
	@cd $(OUTPUT)/synth; dc_shell-xg-t -f $(SYNTH).dc
	@echo -e "$mSynthesis has completed in $(OUTPUT)."
	@echo -e "Timing results can be found at $(OUTPUT)/synth/timing_arm_core.rpt"


###################################################################
### Misc.
###################################################################

auto:
	@emacs -l /afs/ece/class/ece447/elisp/quicklaunch.el -l /afs/ece/class/ece447/elisp/verilog-mode.el --batch `find src -iname '*.v' -o -iname '*.sv'` -f verilog-batch-auto
