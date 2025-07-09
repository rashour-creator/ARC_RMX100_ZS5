include additional_makefiles/makefile_operating_system_abstraction.linux


DESIGN_PATH	      = /remote/us01sgnfs00727/arc_fpga/moyanz/Ratter3/template/dw_dbp/zebu_ifx_mini_rattle_6649a592_20250509/build
USER_LIBRARY_NAME     = user
SRC		      = .
USER_SOURCE_PATH      = $(DESIGN_PATH)/$(SRC)/verilog/
USER_LIBRARY_DIR_NAME = $(SIMULATOR_DIR_PREFIX)USER
USER_LIBRARY_PATH     = $(DESIGN_PATH)/$(USER_LIBRARY_DIR_NAME)


ifeq ($(ARCHITECT_ROOT),)
$(error environment variable "ARCHITECT_ROOT" not set)
endif

ifeq ($(DEFAULT_MAKEFILE_TARGET),)
# This allows setting DEFAULT_MAKEFILE_TARGET=waves_vpd in the environment, for example.
DEFAULT_MAKEFILE_TARGET=compile
endif

# Must put this here to make it the default action in the makefile.
build:	$(DEFAULT_MAKEFILE_TARGET)

include additional_makefiles/makefile_header_verilog
include additional_makefiles/makefile_interface_vcs_verilog

pre_compile_vcs.txt:
	@$(MESSAGE) Preparing for vcs compile.
	make install
	make designware_libraries
	@$(MESSAGE) pre_compile for vcs complete > pre_compile_vcs.txt


common_vcs = @$(ANALYZE)  $(ANALYZE_FLAGS) +v2k -lca -kdb -l vcs.log -debug_acc+all -debug_region+cell+encrypt -sverilog \
	-assert svaext -assert dve -assert enable_diag \
	-o board.simv \
	-P scripts/arc_vcs_pli_table  \
	-L$(ARCHITECT_ROOT)/lib/linux \
	-larc-vcs-pli-verilog \
	 \
	+incdir+$(SRC)/verilog/RTL/include+$(SRC)/verilog/RTL/+$(SRC)/verilog/ -f $(SRC)/verilog/RTL/compile_manifest -f $(SRC)/verilog/compile_manifest

common_remove = @echo "To remove wave file generation, type 'make compile'."

compile: pre_compile_vcs.txt
	$(common_vcs)
	@echo "To produce waves from command line, type 'make waves'."
	@echo "To produce waves/MDA from command line, type 'make waves_fsdb' or 'make waves_vpd'."

waves: pre_compile_vcs.txt
	$(common_vcs) \
	-debug_access+nomemcbk \
	+vcs+vcdpluson
	$(common_remove)

gen_vcdplusmemon: pre_compile_vcs.txt
	-rm -rf vcdplusmemon.v
	touch vcdplusmemon.v
	echo "module tb_vcdplusmemon;" >> vcdplusmemon.v
	echo "initial begin" >> vcdplusmemon.v
	echo '$$vcdplusmemon;' >> vcdplusmemon.v
	echo "end" >> vcdplusmemon.v
	echo "endmodule">> vcdplusmemon.v

waves_vpd: gen_vcdplusmemon
	$(common_vcs) \
	+vcs+vcdpluson vcdplusmemon.v
	$(common_remove)

waves_fsdb: pre_compile_vcs.txt
	$(common_vcs) \
	+vcs+fsdbon
	$(common_remove)

verdi:
	@echo "Starting fsdb waveform"
	verdi -nologo -ssf *.fsdb &

dve:
	@echo "Starting vpd waveform"
	dve -vpd vcdplus.vpd &

clean:
	rm -rf board.simv*
	rm -rf csrc
	rm -rf vnc_logs

files := $(shell cat $(SRC)/verilog/RTL/compile_manifest $(SRC)/verilog/compile_manifest )

define vlog
    vlogan $1 +incdir+$(SRC)/verilog/RTL/include+$(SRC)/verilog/RTL/+$(SRC)/verilog/ -sverilog
    endef

vlogan_setup:
	# vlogan requires this setup file.
	@echo "WORK > DEFAULT" > synopsys_sim.setup
	@echo "DEFAULT: ./work" >> synopsys_sim.setup

separate_compile: vlogan_setup
	# This target will stop at the first error.
	@echo "all: " > separate.make
	@for X in $(files); do echo  -e "\t" $(call vlog, $$X) >> separate.make; done
	$(MAKE) -f separate.make

separate_compile_nonstop: vlogan_setup
	# This target will analyze all the files, and not stop at an error.
	# You must capture the output and inspect for any error messages.
	@for X in $(files); do  $(call vlog, $$X) ; done


# Phony targets
.PHONY: compile waves

