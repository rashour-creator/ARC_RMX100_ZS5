	BOARD ?= zs5
# Check prerequisites
make_required := 3.81
ifneq "$(make_required)" "$(firstword $(sort $(MAKE_VERSION) $(make_required)))"
  $(error [ERROR] Required make version is $(make_required) or higher, but actual is $(MAKE_VERSION))
endif

# Set default variables
ARCH_BUILD          ?= $(dir $(lastword $(MAKEFILE_LIST)))
WORK_DIR            ?= $(CURDIR)
SCRIPT_DIR          ?= $(ARCH_BUILD)
override ARCH_BUILD := $(realpath $(abspath $(ARCH_BUILD)))
override WORK_DIR   := $(abspath $(WORK_DIR))
override SCRIPT_DIR := $(abspath $(SCRIPT_DIR))
GUI                 ?= yes
USE_GRID            ?= yes
ZEBU_SIMV_NAME      ?= zebu_simv
ZCUI                ?= $(WORK_DIR)/zcui.work
SYN_LEVEL           ?= rtl
IS_RTL              := $(if $(findstring $(SYN_LEVEL), rtl rtl_seif),yes)
IS_NETLIST          := $(if $(findstring $(SYN_LEVEL), pre-layout post-layout),yes)
HAS_SEIF            := $(if $(findstring $(SYN_LEVEL), rtl),,yes)
TB_JTAG             :=
CCFLAGS    += -m64
CCFLAGS    += -fPIC
CCFLAGS    += -Wno-long-long
CCFLAGS    += -I.
CCFLAGS    += -I$(ZEBU_IP_ROOT)/include
CCFLAGS    += -I$(ZEBU_ROOT)/include
CCFLAGS    += $(MORE_CCFLAGS)
CCFLAGS    += -D_GLIBCXX_USE_C++11_ABI=1
ifdef ZEBU
  CCFLAGS    += -DZEMI
  CCFLAGS    += -DZEBU_XTOR
  VCSFLAGS   += +define+$(CLOCK_TYPE)
endif
LDFLAGS    += -L$(ZEBU_IP_ROOT)/lib
LDFLAGS    += -L$(ZEBU_ROOT)/lib
LDFLAGS    += $(MORE_LDFLAGS)

LIBS       += -lxtor_amba_master_svs
LIBS       += -lZebuXtor
LIBs       += ${ARCH_BUILD}/zcui.work/zebu.work/xtor_t32Jtag_svs.so
LIBs       += ${ARCH_BUILD}/zcui.work/zebu.work/xtor_amba_master_axi3_svs.so
LIBs       += ${ARCH_BUILD}/zcui.work/zebu.work/xtor_amba_slave_axi3_svs.so
ifdef ZEBU
#libZebuVpi.so is being used for timestamp and only for Zebu platform
  LIBS      += -lZebuVpi
endif
C_OBJS   += TB.o
C_OBJS   += $(MORE_C_OBJS)

# Check variables
ifeq "$(findstring $(SYN_LEVEL), rtl)" ""
 $(error [ERROR] SYN_LEVEL=$(SYN_LEVEL) must be set to "rtl"})
endif
ifeq "$(findstring $(GUI), yes no 0 1)" ""
 $(error [ERROR] GUI=$(GUI) must be set to one of {yes, 1, no, 0})
endif
ifeq "$(findstring $(USE_GRID), yes no)" ""
 $(error [ERROR] USE_GRID=$(USE_GRID) must be set to one of {yes, no})
endif
ifeq "$(USE_GRID)" "yes"
  ifndef SUBMITCMDSH
    $(error [ERROR] Please, define $$SUBMITCMDSH for grid usage (see "grid_cmd" in ZeBu documentation) or use option USE_GRID=no)
  endif
endif

# Print setup
$(foreach var,$(.VARIABLES), $(if $(filter-out default automatic environment,$(origin $(var))), $(info [INFO] makefile variable $(var)=$($(var))) ))

# Declare file names
MEMORY_WRAPPERS   := $(wildcard $(ARCH_BUILD)/verilog/mem_*_wrapper.v )
NETLIST_MEMORIES  := $(filter-out $(MEMORY_WRAPPERS), $(wildcard $(ARCH_BUILD)/verilog/mem_*.v ))
ZEBU_MEMORIES     := $(addprefix $(WORK_DIR)/memory/, $(notdir $(NETLIST_MEMORIES)))
GATE_MODELS       := $(WORK_DIR)/sglib/std/typical_spyglass_lc.v
MEM_MODELS_DB     := $(WORK_DIR)/spg_results/spyglass/archipelago/power/power_factor_conditions/spyglass_reports/power_est/pe_power_profiler_memory_conditions.db
TRIGGERS          := $(WORK_DIR)/verilog/zebu_triggers.v
DUMPVARS          := $(WORK_DIR)/verilog/zebu_dumpvars.v
ZEBU_SIMV         := $(WORK_DIR)/$(ZEBU_SIMV_NAME)
FW_SAIF           := $(WORK_DIR)/saif/fw_ram.saif
HIER_DESIGNS      := archipelago archipelago_sub alb_cpu_top cnn_engine_top

# Compilation defines
COMMON_DEFINES := \
	-full64 -sverilog +v2k -kdb \
	-timescale=1ns/10ps \
	-debug_access+all -debug_region+cell+encrypt \
	-skip_translate_body \
	+define+SYNTHESIS +define+FPGA_INFER_MEMORIES \
	+define+NO_2CYC_CHECKER +define+NO_3CYC_CHECKER \
	+incdir+$(WORK_DIR)/verilog \
	+incdir+$(WORK_DIR)/verilog/RTL \
	-f $(WORK_DIR)/verilog/compile_manifest \
	$(if $(IS_RTL), -f $(WORK_DIR)/verilog/RTL/compile_manifest ) \
	$(if $(HAS_SEIF), -f $(WORK_DIR)/mapped/compile_manifest  ) \
	$(if $(HAS_SEIF), -f $(WORK_DIR)/memory/compile_manifest ) \
	$(if $(IS_RTL), -assert svaext) \
	$(if $(IS_NETLIST), +delay_mode_zero) \
	$(WORK_DIR)/verilog/zebu_top.v

# Make targets

.PHONY: all sources add_tb_jtag copy_files finalize_sources compile_vcs compile_zebu testbench reduce_size clean_all print info

all: sources compile_zebu

sources: copy_files $(if $(TB_JTAG), add_tb_jtag) $(if $(HAS_SEIF), $(ZEBU_MEMORIES)) $(if $(IS_NETLIST), $(MEM_MODELS_DB)) finalize_sources

copy_files: $(WORK_DIR)/.copy_done
$(WORK_DIR)/.copy_done:
  ifneq "$(ARCH_BUILD)" "$(WORK_DIR)"
	# Create WORK_DIR dirs
	mkdir -p $(WORK_DIR)/verilog/RTL/

	# Create link to the original ARChitect build
	rm -f $(WORK_DIR)/build
	ln -sfn `readlink -f $(ARCH_BUILD)` $(WORK_DIR)/build

	# Copy build configuration information
	cp -f  $(ARCH_BUILD)/build_*      $(WORK_DIR)/

	# Copy archipelago RTL or netlist
    ifeq "$(SYN_LEVEL)" "post-layout"
    else ifeq "$(SYN_LEVEL)" "pre-layout"
    else
	cp -rf $(ARCH_BUILD)/verilog/RTL/*          $(WORK_DIR)/verilog/RTL/
	sed -i -e's|$(ARCH_BUILD)|.|'               $(WORK_DIR)/verilog/RTL/compile_manifest
    endif

	# Copy MSS and RTL memory wrappers
	find $(ARCH_BUILD)/verilog/ -maxdepth 1 -type f -exec cp {} $(WORK_DIR)/verilog/ \;
	sed -i -e's|$(ARCH_BUILD)|.|'               $(WORK_DIR)/verilog/compile_manifest

	# Copy memory DBs for synthesized builds
    ifneq "$(SYN_LEVEL)" "rtl"
	cp -rf $(ARCH_BUILD)/lib*                   $(WORK_DIR)/
    endif

	# Copy other useful files
	cp -rf $(ARCH_BUILD)/tool_config            $(WORK_DIR)/
	cp -rf $(ARCH_BUILD)/User                   $(WORK_DIR)/
	cp -rf $(ARCH_BUILD)/constraints            $(WORK_DIR)/
	cp -rf $(ARCH_BUILD)/additional_makefiles   $(WORK_DIR)/
	cp -rf $(ARCH_BUILD)/fix_manifest_paths.sh  $(WORK_DIR)/
	cp -rf $(ARCH_BUILD)/current_directory.txt  $(WORK_DIR)/
	cp -f  $(ARCH_BUILD)/verilog/*defines.v     $(WORK_DIR)/verilog/
	cp -f  $(ARCH_BUILD)/verilog/RTL/*defines.v $(WORK_DIR)/verilog/RTL/
	cp -f  $(ARCH_BUILD)/verilog/RTL/*defs.v    $(WORK_DIR)/verilog/RTL/
	-cp -rf $(ARCH_BUILD)/verilog/config        $(WORK_DIR)/verilog/
	-cp -rf $(ARCH_BUILD)/ev                    $(WORK_DIR)/
	-cp -rf $(ARCH_BUILD)/tests                 $(WORK_DIR)/

  endif # ARCH_BUILD != WORK_DIR
  ifneq "$(SCRIPT_DIR)" "$(WORK_DIR)"
	# Copy ZeBu scripts
	cp -rf $(SCRIPT_DIR)/scripts                $(WORK_DIR)/
	cp -f  $(SCRIPT_DIR)/zebu_mdb               $(WORK_DIR)/
	cp -f  $(SCRIPT_DIR)/arczebu*makefile       $(WORK_DIR)/

  endif # SCRIPT_DIR != WORK_DIR

	touch $(WORK_DIR)/.copy_done

add_tb_jtag: $(WORK_DIR)/.jtag_done
$(WORK_DIR)/.jtag_done: $(WORK_DIR)/.copy_done
	# Patch MSS to add JTAG2BVCI module
	test -e $(WORK_DIR)/verilog/core_sys.v.old || \
	  cp $(WORK_DIR)/verilog/core_sys.v $(WORK_DIR)/verilog/core_sys.v.old
	$(WORK_DIR)/scripts/zebu_scripts/add_jtag2bvci_to_tb.py $(WORK_DIR)/verilog/core_sys.v 
	touch $(WORK_DIR)/.jtag_done

$(ZEBU_MEMORIES): $(WORK_DIR)/.copy_done
	# Create FPGA-friendly memories to replace memory macros
	mkdir -p $(WORK_DIR)/memory/
	$(WORK_DIR)/scripts/zebu_scripts/generate_zebu_memory_model.pl $(NETLIST_MEMORIES) $(WORK_DIR)/memory/

$(GATE_MODELS): $(WORK_DIR)/.copy_done
	# Generate standard cell models
	mkdir -p $(WORK_DIR)/sglib/std
	cd $(WORK_DIR) && $(WORK_DIR)/scripts/zebu_scripts/generate_lib2compile.csh std typ $(WORK_DIR)/scripts/options.tcl | sort -u > $(WORK_DIR)/sglib/stdlib2compile.f
	cd $(WORK_DIR) && spyglass_lc -f $(WORK_DIR)/sglib/stdlib2compile.f -decompile_lib_models -outsglib typical.sglib -wdir $(dir $(GATE_MODELS))
	test -e $(GATE_MODELS)

finalize_sources: $(WORK_DIR)/.sources_done
$(WORK_DIR)/.sources_done: $(WORK_DIR)/.copy_done $(if $(HAS_SEIF), $(ZEBU_MEMORIES) $(GATE_MODELS))
  ifeq "$(HAS_SEIF)" "yes"
	# Create netlists manifest
	mkdir -p $(WORK_DIR)/mapped
	-cd $(WORK_DIR) && ls -1 ./mapped/*.{v,v.gz}    > $(WORK_DIR)/mapped/compile_manifest
	echo $(GATE_MODELS) | sed 's|$(WORK_DIR)/|./|' >> $(WORK_DIR)/mapped/compile_manifest
  endif
  ifeq "$(HAS_SEIF)" "yes"
	# Create memory manifest
	cd $(WORK_DIR) && ls -1 ./memory/*.v            > $(WORK_DIR)/memory/compile_manifest
  endif
  ifeq "$(SYN_LEVEL)" "rtl"
	# Patch missing CNN memories in old cnn_engine iplibs
	-test -e $(WORK_DIR)/verilog/cnn_fpga_sp_ram.v && \
	   grep -q cnn_fpga $(WORK_DIR)/verilog/RTL/compile_manifest || \
	   ls -1 $(WORK_DIR)/verilog/cnn_fpga* >> $(WORK_DIR)/verilog/RTL/compile_manifest
  endif
  ifeq "$(IS_NETLIST)" "yes"
	# Patch safety monitor in MSS (if it exists)
	-cp -f $(ARCH_BUILD)/verilog/RTL/DWbb*.v $(WORK_DIR)/verilog/
	-cd $(WORK_DIR) && ls -1 ./verilog/DWbb*.v >> $(WORK_DIR)/verilog/compile_manifest
  endif
	# Patch critical path in MSS memory for performance
	sed -i -e's|SYNC_OUT   (0)|SYNC_OUT   (1)|'       $(WORK_DIR)/verilog/alb_mss_mem_model.v
	touch  $(WORK_DIR)/.sources_done

$(MEM_MODELS_DB): $(WORK_DIR)/.sources_done
	# Generate memory cell models
	mkdir -p $(WORK_DIR)/sglib/mem
	cd $(WORK_DIR) && $(WORK_DIR)/scripts/zebu_scripts/generate_lib2compile.csh mem typ $(WORK_DIR)/scripts/options.tcl | sort -u > $(WORK_DIR)/sglib/memlib2compile.f
	cd $(WORK_DIR) && spyglass_lc -f $(WORK_DIR)/sglib/memlib2compile.f -include_power_data -outsglib typical.sglib -wdir $(dir $(GATE_MODELS))/../mem
	# Create power profiler memory conditions
	cd $(WORK_DIR) && spyglass -batch -project $(WORK_DIR)/scripts/zebu_scripts/spyglass.prj -goal power/power_factor_conditions -enable_zebu
	test -e $(MEM_MODELS_DB)

compile_vcs: $(ZEBU_SIMV)
$(ZEBU_SIMV): $(WORK_DIR)/.sources_done
	# Compile design with VCS
	@echo -e "$(ZEBU_IP_ROOT)/vlog/vcs/xtor_amba_master_axi3_svs.sv"                             >> $(WORK_DIR)/verilog/compile_manifest
	@echo -e "$(ZEBU_IP_ROOT)/vlog/vcs/xtor_amba_slave_axi3_svs.sv"                             >> $(WORK_DIR)/verilog/compile_manifest
	cd $(WORK_DIR) && vcs -top zebu_top -l zebu_vcs.log +define+SIMULATE_ONLY -o $(ZEBU_SIMV_NAME) \
	                      +incdir+$(SYNOPSYS)/dw/sim_ver+ -y $(SYNOPSYS)/dw/sim_ver +libext+.v+ $(COMMON_DEFINES)

$(FW_SAIF):
	# Create FW SAIF for memories
	mkdir -p $(WORK_DIR)/saif/
	cd $(WORK_DIR) && dcnxt_shell -f scripts/zebu_scripts/generate_fw_ram.tcl
	-rm $(WORK_DIR)/command.log

$(DUMPVARS): $(ZEBU_SIMV)
	# Extract power dumpvars
	cd $(WORK_DIR) && $(ZEBU_SIMV) -ucli -do scripts/zebu_scripts/extract_dumpvars.do

$(TRIGGERS): $(ZEBU_SIMV)
	# Extract power triggers
	cd $(WORK_DIR) && $(ZEBU_SIMV) -ucli -do scripts/zebu_scripts/extract_triggers.do

compile_zebu: $(TRIGGERS) $(if $(IS_NETLIST), $(FW_SAIF) $(MEM_MODELS_DB) $(DUMPVARS))
	# Create ZeBu compilation script
	@echo -e "#!/bin/csh -fx \n"                                                       > $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "vlogan -syn_dw+dump_dir=zebu_dw -l zcui_comp.log \\"                    >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "  $(ZEBU_IP_ROOT)/vlog/vcs/xtor_t32Jtag_svs.v  \\"                          >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "  $(ZEBU_IP_ROOT)/vlog/vcs/xtor_amba_master_axi3_svs.sv \\"                             >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "  $(ZEBU_IP_ROOT)/vlog/vcs/xtor_amba_slave_axi3_svs.sv \\"                             >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "  $(COMMON_DEFINES) \n"                                                 >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "vcs -j8 -full64 -kdb -top zebu_top -l zcui_elab.log \\"                 >> $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "   -xzebu -xzebu_flow=zebu_scm -hw_top=zebu_top \\" >> $(WORK_DIR)/zcui_vcs_cmd.csh
	$(if $(IS_NETLIST), @echo -e "  -swave=gls -swave=forwardsaiffile:$(FW_SAIF) \\"  >> $(WORK_DIR)/zcui_vcs_cmd.csh)
	$(if $(IS_NETLIST), @echo -e "  -swave=sequenceinfofile:$(MEM_MODELS_DB) \\"      >> $(WORK_DIR)/zcui_vcs_cmd.csh)
	@echo -e "  -syn_dw+dump_dir=zebu_dw -timescale=1ns/10ps -debug_access+all "      >> $(WORK_DIR)/zcui_vcs_cmd.csh
	chmod u+x $(WORK_DIR)/zcui_vcs_cmd.csh
	@echo -e "WORK > DEFAULT\nDEFAULT" > $(WORK_DIR)/synopsys_sim.setup

	# Set grid usage
  ifeq "$(USE_GRID)" "yes"
	sed -i 's|^#grid_cmd|grid_cmd|' $(WORK_DIR)/scripts/zebu_scripts/project.utf
	sed -i 's|^#grid_cmd|grid_cmd|' $(WORK_DIR)/scripts/zebu_scripts/project_zs5.utf
  else
	sed -i 's|^grid_cmd|#grid_cmd|' $(WORK_DIR)/scripts/zebu_scripts/project.utf
	sed -i 's|^grid_cmd|#grid_cmd|' $(WORK_DIR)/scripts/zebu_scripts/project_zs5.utf
  endif

	# Compile design for ZeBu
ifeq "$(BOARD)" "zs5"
	cd $(WORK_DIR) && time zCui $(if $(filter no 0,$(GUI)),--nogui,) -c -w $(ZCUI) -u $(WORK_DIR)/scripts/zebu_scripts/project_zs5.utf
else
	cd $(WORK_DIR) && time zCui $(if $(filter no 0,$(GUI)),--nogui,) -c -w $(ZCUI) -u $(WORK_DIR)/scripts/zebu_scripts/project.utf
endif

	zRscManager -nc -compilationstatus $(ZCUI) | tee $(ZCUI)/compilation_status.log
	make -C ${ZCUI}/backend_default -f dpixtor.mk
	make -f arczebu.makefile testbench
	bash collect_utilization.sh $(WORK_DIR)

#testbench: $(WORK_DIR)/scripts/zebu_runtime/TB.cpp $(ZCUI)
#	g++ -std=c++11  -L $(ZEBU_ROOT)/lib -I $(ZEBU_ROOT)/include -L $(ZEBU_IP_ROOT)/lib -I $(ZEBU_IP_ROOT)/include -I $(WORK_DIR)/zebu.work \
#	   -l Zebu -l ZebuXtor -l xtor_jtag_t32_svs  -l xtor_amba_master_svs -l xtor_uart_svs -L zebu.work -fpic -rdynamic -c \
#	   $(WORK_DIR)/scripts/zebu_runtime/TB.cpp -o $(WORK_DIR)/scripts/zebu_runtime/TB.o
#	g++ -std=c++11  -L $(ZEBU_ROOT)/lib -I $(ZEBU_ROOT)/include -L $(ZEBU_IP_ROOT)/lib -I $(ZEBU_IP_ROOT)/include -I $(WORK_DIR)/zebu.work \
#	   -l Zebu -l ZebuXtor  -l xtor_jtag_t32_svs  -l xtor_amba_master_svs -l xtor_uart_svs -L zebu.work -shared -g -fPIC -rdynamic \
#	   $(WORK_DIR)/scripts/zebu_runtime/TB.o -o $(WORK_DIR)/scripts/zebu_runtime/TB.so
testbench: 
	g++ -std=c++14 $(CCFLAGS) $(LDFLAGS)  $(LIBS) -I $(WORK_DIR)/zebu.work -l Zebu -l ZebuXtor -l  xtor_jtag_t32_svs  -l xtor_amba_master_svs -l xtor_uart_svs   -L zebu.work -fpic -rdynamic -c $(WORK_DIR)/scripts/zebu_runtime/TB.cpp -o  $(WORK_DIR)/zcui.work -o $(WORK_DIR)/scripts/zebu_runtime/TB.o 
	g++ -std=c++14 $(CCFLAGS) $(LDFLAGS) $(LIBS) -I $(WORK_DIR)/zebu.work  -l Zebu -l ZebuXtor -l  xtor_jtag_t32_svs  -l xtor_amba_master_svs -l xtor_uart_svs  -L zebu.work   -g -shared -fPIC -rdynamic   $(WORK_DIR)/scripts/zebu_runtime/TB.o  -o $(WORK_DIR)/scripts/zebu_runtime/TB.so

run: $(WORK_DIR)/scripts/zebu_runtime/TB.so
	cp $(WORK_DIR)/scripts/zebu_runtime/TB.so  ./
	ZEBU_VERSION=$(ZEBU_VERSION) LD_LIBRARY_PATH=$$ZEBU_IP_ROOT/third_party_sw/lib:$$ZEBU_IP_ROOT/lib:$$LD_LIBRARY_PATH && zRci ./zRci.tcl -- trivial_test |& tee trivial_test.log

reduce_size:
	# Remove easy to regenerate big intermediate files
	@echo "From: `du -sh $(WORK_DIR)`"
	@-rm -rf $(WORK_DIR)/sglib $(WORK_DIR)/spg_results $(ZEBU_SIMV)* $(WORK_DIR)/zebu_dw $(WORK_DIR)/csrc $(WORK_DIR)/work.lib++ $(WORK_DIR)/AN.DB
	@echo "To:   `du -sh $(WORK_DIR)`"

clean_all:
	@-rm -rf $(WORK_DIR)/memory $(WORK_DIR)/zebu_vcs.log $(WORK_DIR)/zcui_vcs_cmd.csh $(WORK_DIR)/synopsys_sim.setup
	@-rm -rf $(WORK_DIR)/zcui_comp.log $(WORK_DIR)/zcui_elab.log  $(WORK_DIR)/t32_jtag_xtor_templates $(ZCUI) $(WORK_DIR)/AN.DB
	@-rm -rf $(WORK_DIR)/.copy_done $(WORK_DIR)/.sources_done $(WORK_DIR)/.jtag_done $(WORK_DIR)/zGenerateRhinoFsdb.log
	@-rm -rf $(WORK_DIR)/sglib $(WORK_DIR)/spg_results $(ZEBU_SIMV)* $(WORK_DIR)/zebu_dw $(WORK_DIR)/csrc $(WORK_DIR)/work.lib++ 
	@-rm -rf $(WORK_DIR)/WORK $(WORK_DIR)/saif $(WORK_DIR)/lib2compile.f $(WORK_DIR)/ucli.key $(WORK_DIR)/User $(WORK_DIR)/vc_hdrs.h
	@echo "Cleaning completed"

print info:
