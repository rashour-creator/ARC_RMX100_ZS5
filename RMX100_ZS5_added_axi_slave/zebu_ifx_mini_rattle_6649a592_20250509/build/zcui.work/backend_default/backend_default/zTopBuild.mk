ZCOREBUILD ?= zCoreBuild
ZPAR       ?= zPar
ZTINA      ?= zTiNa
ZRDB       ?= zRDB
ZGG        ?= zGraphGenerator
DVE         = 
REMOTECMD  ?= time

ZRDB_EQUI_DB  = nofpga/zrdb/stamp.zrdb
ZRDB_EQUI_EDF ?= tools/zDB/zTopBuild_equi.edf.gz
ZRDB_EQUI_TCL ?= tools/zDB/zRDB_buildEqui_ztb.tcl

all : zpar $(ZRDB_EQUI_DB)

work.Part_0/zPar_cmds.tcl : $(DVE) work.Part_0/zCoreBuild_ztb.tcl work.Part_0/zebu_top.hash
	cd work.Part_0/; $(REMOTECMD) $(ZCOREBUILD) zCoreBuild_ztb.tcl

ztina : 
	cd work.Part_0/; 	for fpga in  U*_M*_F*/ ; do cd $$fpga; $(REMOTECMD) $(ZTINA) timing_analysis.tcl; cd ../ ; done 
	cd ../ ;


$(ZRDB_EQUI_DB) : $(ZRDB_EQUI_TCL)

zpar : edif/zebu_top.edf.gz zPar_design_conf.tcl zPar_zCui.tcl work.Part_0/zPar_cmds.tcl ztina
	$(REMOTECMD) $(ZPAR) zPar_zCui.tcl

