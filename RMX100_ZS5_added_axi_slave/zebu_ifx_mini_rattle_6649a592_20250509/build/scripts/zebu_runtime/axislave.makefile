SRCDIR= ./zebu_connection/sw/src

SRC= $(wildcard $(SRCDIR)/*.cpp)

OBJDIR=./zebu_connection/obj

OBJS= $(patsubst $(SRCDIR)/%.cpp,$(OBJDIR)/%.o,$(SRC))


INCLUDE= -I $(ZEBU_IP_ROOT)/JTAG_T32/include
INCLUDE+= -I $(ZEBU_IP_ROOT)/include
INCLUDE+= -I $(ZEBU_IP_ROOT)/xtor_amba_slave_svs/include
INCLUDE+= -I $(ZEBU_ROOT)/include
INCLUDE+= -I ./zcui.work/zebu.work
INCLUDE+= -I ./zebu_connection/sw/include

LIBS=  -L $(ZEBU_IP_ROOT)/JTAG_T32/lib
LIBS+= -L $(ZEBU_IP_ROOT)/UART/lib
LIBS+= -L $(ZEBU_IP_ROOT)/xtor_amba_slave_svs/lib
LIBS+= -L $(ZEBU_ROOT)/lib/
LIBS+= -L ./zcui.work/zebu.work/
LDFLAGS    += -L$(ZEBU_IP_ROOT)/lib
LDFLAGS    += -L$(ZEBU_ROOT)/lib
LDFLAGS    += $(MORE_LDFLAGS)
LDFLAGS+=  -l Zebu
LDFLAGS+= -l ZebuXtor
LDFLAGS+= -l xtor_jtag_t32_svs
LDFLAGS+= -l xtor_uart_svs
LDFLAGS+= -l ZebuZEMI3
LDFLAGS+= -l ZebuVpi
LDFLAGS+= -l xtor_amba_master_svs
LDFLAGS+= -l xtor_amba_slave_svs




CPPFLAGS=	-std=c++14 \
			-m64 \
			-Wno-long-long \
			-fPIC \
			-Wunused-variable \
			-D_GLIBCXX_USE_CXX11_ABI=1

$(OBJDIR): 
	mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.cpp | $(OBJDIR)
	@echo "compiling src code $<"
	@g++ $(CPPFLAGS) -rdynamic $(INCLUDE) -DZEMI -DZEBU_XTOR -c $^ -o $@

testbench: $(OBJS)
	@echo "Linking Phase"
	@g++ $(CPPFLAGS) -shared -g -fPIC -rdynamic $^ $(INCLUDE) $(LIBS) $(LDFLAGS) -o ./tb_lib/TB.so  
	@echo "==> Testbech compiled and TB.so generated successfully in ./tb_lib/ "
	@rm -fr ./zebu_connection/obj

clean-all:
	rm -f /remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/scripts/zebu_runtime/TB.so 


