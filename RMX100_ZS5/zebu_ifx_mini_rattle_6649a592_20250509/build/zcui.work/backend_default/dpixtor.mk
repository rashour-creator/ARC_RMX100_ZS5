#written by VCS
ifeq ($(CUSTOM_ZEMI3_DIR), 1)
export OBJ_DIR = $(PWD)/zebu_zemi3_libs
endif

all:
ifeq ($(CUSTOM_ZEMI3_DIR), 1)
	make -C ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher" comp
	cp ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher"/*.h $(OBJ_DIR)
	cp ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher"/*.zsym $(OBJ_DIR)
	make -C ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs" comp
	cp ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs"/*.h $(OBJ_DIR)
	cp ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs"/*.zsym $(OBJ_DIR)
	make -C ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs" comp
	cp ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs"/*.h $(OBJ_DIR)
	cp ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs"/*.zsym $(OBJ_DIR)
else
	make -C ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher" comp
	cp ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher"/*.h .
	cp ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher"/*.so .
	cp ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher"/*.zsym .
	make -C ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs" comp
	cp ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs"/*.h .
	cp ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs"/*.so .
	cp ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs"/*.zsym .
	make -C ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs" comp
	cp ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs"/*.h .
	cp ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs"/*.so .
	cp ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs"/*.zsym .
	cp ../vcs_splitter/zemi3.h .
endif
install:
	make -C ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher" install
	make -C ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs" install
	make -C ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs" install
clean:
	make -C ../"xtor_rl_ifu_fetcher/zxtor/rl_ifu_fetcher" clean
	make -C ../"xtor_xtor_amba_master_axi3_svs/zxtor/xtor_amba_master_axi3_svs" clean
	make -C ../"xtor_xtor_t32Jtag_svs/zxtor/xtor_t32Jtag_svs" clean
