ZDB_FILES=\
     U0/M0/F00/zrdb/ZebuDB.zdb\
     U0/M0/F01/zrdb/ZebuDB.zdb
ISE_REMOTECMD ?=
REMOTECMD     ?= $(ISE_REMOTECMD)
RMAKE         ?= $(REMOTECMD) $(MAKE)
ZDB           ?= zDB
ZRDB          ?= zRDB
DEFAULT_LABEL ?= default
DESIGN         = design

all_zdb : $(ZDB_FILES)

U0/M0/F00/zrdb/ZebuDB.zdb : U0/M0/F00.$(DEFAULT_LABEL)/zrdb/ZebuDB.zdb 
	$(RMAKE) winner -C U0/M0 FX=F00 LABEL=$(DEFAULT_LABEL)

U0/M0/F01/zrdb/ZebuDB.zdb : U0/M0/F01.$(DEFAULT_LABEL)/zrdb/ZebuDB.zdb 
	$(RMAKE) winner -C U0/M0 FX=F01 LABEL=$(DEFAULT_LABEL)



U0/M0/F00.$(DEFAULT_LABEL)/zrdb/ZebuDB.zdb : U0/M0/F00.src/wrapper.edf.gz U0/M0/F00.src/design_zpar.zdc U0/M0/F00.src/fpga.edf.gz
	$(RMAKE) compil -C U0/M0 FX=F00 LABEL=$(DEFAULT_LABEL) && grep 'finished OK' U0/M0/F00.$(DEFAULT_LABEL)/xstep.cui 

U0/M0/F01.$(DEFAULT_LABEL)/zrdb/ZebuDB.zdb : U0/M0/F01.src/wrapper.edf.gz U0/M0/F01.src/design_zpar.zdc U0/M0/F01.src/fpga.edf.gz
	$(RMAKE) compil -C U0/M0 FX=F01 LABEL=$(DEFAULT_LABEL) && grep 'finished OK' U0/M0/F01.$(DEFAULT_LABEL)/xstep.cui 


clean : 
	$(RMAKE) clean -C U0/M0 FX=F00 LABEL=$(DEFAULT_LABEL)

	$(RMAKE) clean -C U0/M0 FX=F01 LABEL=$(DEFAULT_LABEL)

