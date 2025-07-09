help_lib:
	@echo ""
	@echo "######################################################"
	@echo "# creation of the dynamic library of the dpi wrapper #"
	@echo "# 'grp0'                                             #"
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

GROUP_NAME   := grp0_ccall

GROUP_DIR    ?= .
OBJ_DIR      ?= $(GROUP_DIR)
INSTALL_DIR  ?= $(GROUP_DIR)

CCALL_LIB    ?= ZebuCCall
GROUP_LIB    ?= $(GROUP_NAME).so

ifneq ($(ZFAST_ROOT),)
INCL_PATH     = -I$(ZFAST_ROOT)/include -I$(ZEBU_ROOT)/include -I$(GROUP_DIR)
LD_LIBS       = $(ZFAST_ROOT)/lib/lib$(CCALL_LIB).so
else
INCL_PATH     = -I$(ZEBU_ROOT)/include -I$(GROUP_DIR)
LD_LIBS       = -L$(ZEBU_ROOT)/lib -l$(CCALL_LIB)
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

$(OBJ_DIR)/$(GROUP_LIB) : $(OBJ_DIR)/$(GROUP_NAME).o
	$(CXX) $(ALL_LINKFLAGS) -shared -o $@ $< $(LD_LIBS)

$(OBJ_DIR)/$(GROUP_NAME).o : $(GROUP_DIR)/$(GROUP_NAME).cc
	$(CXX) $(ALL_CXXFLAGS) -c -o $@ $<

objcomp : $(OBJ_DIR) $(OBJ_DIR)/$(GROUP_NAME).o

comp : $(OBJ_DIR) $(OBJ_DIR)/$(GROUP_NAME).so

install : comp $(INSTALL_DIR)

	if ( [ ! -e $(INSTALL_DIR)/$(GROUP_LIB) ] || ( ! (cmp -s $(OBJ_DIR)/$(GROUP_LIB) $(INSTALL_DIR)/$(GROUP_LIB) ) ) ); then \
		cp $(OBJ_DIR)/$(GROUP_LIB) $(INSTALL_DIR)/$(GROUP_LIB) ; \
	fi
	if ( [ ! -e $(INSTALL_DIR)/$(GROUP_NAME).h ] || ( ! ( cmp -s $(GROUP_DIR)/$(GROUP_NAME).h $(INSTALL_DIR)/$(GROUP_NAME).h ) ) ); then \
		cp $(GROUP_DIR)/$(GROUP_NAME).h $(INSTALL_DIR)/$(GROUP_NAME).h ; \
	fi
clean :
	rm -f $(OBJ_DIR)/$(GROUP_NAME).o $(OBJ_DIR)/$(GROUP_NAME).so

.PHONY :: objcomp comp install clean

# header file dependencies

$(OBJ_DIR)/$(GROUP_NAME).o : $(GROUP_DIR)/$(GROUP_NAME).h
