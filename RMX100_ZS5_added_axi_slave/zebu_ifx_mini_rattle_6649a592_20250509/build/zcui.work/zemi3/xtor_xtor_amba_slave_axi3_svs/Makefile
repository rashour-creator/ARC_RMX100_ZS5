help_lib:
	@echo ""
	@echo "######################################################"
	@echo "# creation of the dynamic library of the transactor  #"
	@echo "# 'xtor_amba_slave_axi3_svs'                         #"
	@echo "######################################################"
	@echo "# Available targets:                                 #"
	@echo "#  -> comp                                           #"
	@echo "#  -> install                                        #"
	@echo "#  -> clean                                          #"
	@echo "######################################################"
	@echo "# Some useful overrides:                             #"
	@echo "#  CXXFLAGS=-O                                       #"
	@echo "#  LINKFLAGS=                                        #"
	@echo "#  CXX=                                              #"
	@echo "#                                                    #"
	@echo "#  These can also be set in the environment          #"
	@echo "######################################################"
	@echo ""

XTOR_NAME    := xtor_amba_slave_axi3_svs

XTOR_DIR     ?= .
OBJ_DIR      ?= $(XTOR_DIR)
INSTALL_DIR  ?= $(XTOR_DIR)

ZEMI3_LIB    ?= ZebuZEMI3
XTOR_LIB     ?= $(XTOR_NAME).so
ifneq ($(ZFAST_ROOT),)
INCL_PATH     = -I$(ZFAST_ROOT)/include -I$(ZEBU_ROOT)/include -I$(XTOR_DIR)
LD_LIBS       = $(ZFAST_ROOT)/lib/lib$(ZEMI3_LIB).so
else
INCL_PATH     = -I$(ZEBU_ROOT)/include -I$(XTOR_DIR)
LD_LIBS       = -L$(ZEBU_ROOT)/lib -l$(ZEMI3_LIB)
endif

CXX          ?= g++
CXXFLAGS     ?= -O
ALL_CXXFLAGS  = $(CXXFLAGS) $(INCL_PATH) -fPIC -fexceptions -Wall
LINKFLAGS    ?=
ALL_LINKFLAGS = -fPIC $(LINKFLAGS)

$(OBJ_DIR):
	mkdir -p $@

ifneq ($(OBJ_DIR),$(INSTALL_DIR))
$(INSTALL_DIR):
	mkdir -p $@

endif

$(OBJ_DIR)/$(XTOR_LIB) : $(OBJ_DIR)/$(XTOR_NAME).o
	$(CXX) $(ALL_LINKFLAGS) -shared -o $@ $< $(LD_LIBS)

$(OBJ_DIR)/$(XTOR_NAME).o : $(XTOR_DIR)/$(XTOR_NAME).cc
	$(CXX) $(ALL_CXXFLAGS) -c -o $@ $<

objcomp : $(OBJ_DIR) $(OBJ_DIR)/$(XTOR_NAME).o

comp : $(OBJ_DIR) $(OBJ_DIR)/$(XTOR_NAME).so

install : comp $(INSTALL_DIR)

	if ( [ ! -e $(INSTALL_DIR)/$(XTOR_LIB) ] || ( ! (cmp -s $(OBJ_DIR)/$(XTOR_LIB) $(INSTALL_DIR)/$(XTOR_LIB) ) ) ); then \
		cp $(OBJ_DIR)/$(XTOR_LIB) $(INSTALL_DIR)/$(XTOR_LIB) ; \
	fi
	if ( [ ! -e $(INSTALL_DIR)/$(XTOR_NAME).h ] || ( ! ( cmp -s $(XTOR_DIR)/$(XTOR_NAME).h $(INSTALL_DIR)/$(XTOR_NAME).h ) ) ); then \
		cp $(XTOR_DIR)/$(XTOR_NAME).h $(INSTALL_DIR)/$(XTOR_NAME).h ; \
	fi
clean :
	rm -f $(OBJ_DIR)/$(XTOR_NAME).o $(OBJ_DIR)/$(XTOR_NAME).so

.PHONY :: objcomp comp install clean

# header file dependencies

$(OBJ_DIR)/$(XTOR_NAME).o : $(XTOR_DIR)/$(XTOR_NAME).h
