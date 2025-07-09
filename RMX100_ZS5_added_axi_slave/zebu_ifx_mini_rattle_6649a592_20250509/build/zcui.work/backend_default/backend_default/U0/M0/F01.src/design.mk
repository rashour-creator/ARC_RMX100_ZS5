# EMULATION and VERIFICATION ENGINEERING (c) - 2004-2006
# ------------------------------------------------------
# Makefile to compile the firmware

.NOTPARALLEL:

FPGA      = xcvu19p-fsva3824-1-e
DESIGN   = design

INCR_SCRIPT = zNetgen_incremental.tcl

PROPERTY_DB = zNetgen_property.db

FWC_CONSTRAINTS = design_fwc.zdc

CORE_FILE = fpga.edf.gz

BITSTREAM_STRING = ZS5_ZS5_VU19P_12C_F01-2014.12-4752006

TOP_NAME = zebu_top

FPGA_NUM = 1

UNIT_NUM = 0

MOD_NUM = 0

DB_FPGA_INDEX = 7

DB_DEV_INDEX  = 30

FPGA_PATH = U0/M0/F01.src

FPGA_CORE = U0_M0_F1.U0_M0_F1_core

BITGEN_COMPIL_OPTIONS = -w -g DriveDONE:Yes -g persist:x32 -g StartUpClk:CCLK -g OverTempPowerDown:Enable

ZEBU_HYDRA_ENABLE = 1

ZEBU_ROOT ?= 

include $(ZEBU_ROOT)/etc/vivado_zs5/design_constant.vivado_zs5.mk
