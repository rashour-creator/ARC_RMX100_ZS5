/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#ifndef _TOP_zebu_top_HH
#define _TOP_zebu_top_HH
#include "libZebu.hh"

typedef struct {
    struct {
        struct {
            struct {
                struct {
                    struct {
                        struct {
                            ZEBU::Memory *sqnod6249;
                        } sqnod12754;
                        struct {
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1438;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1439;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1440;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1441;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1442;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1443;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1444;
                            struct {
                                ZEBU::Memory *sqnod256809;
                            } sqnod1445;
                            ZEBU::Memory *sqnod1465;
                        } sqnod12755;
                    } slave_xtor;
                } i2_axi_slave;
            } ialb_mss_dummy_slave;
            struct {
                struct {
                    struct {
                        ZEBU::Memory *i_bdel_mem;
                        ZEBU::Memory *i_rdel_mem;
                    } u_mem_bus_lat;
                } u_rgon0_lat_inst;
                struct {
                    struct {
                        ZEBU::Memory *mem_r;
                    } u_alb_mss_mem_ram;
                } u_rgon0_mem_inst;
            } ialb_mss_mem;
            struct {
                struct {
                    struct {
                        struct {
                            ZEBU::Memory *mem_r;
                        } u_DCCM_sram;
                    } u_dccm_even;
                    struct {
                        struct {
                            ZEBU::Memory *mem_r;
                        } u_DCCM_sram;
                    } u_dccm_odd;
                    struct {
                        struct {
                            ZEBU::Memory *mem_r;
                        } u_ic_data_ram;
                    } u_ic_data_ram;
                    struct {
                        struct {
                            ZEBU::Memory *mem_r;
                        } u_ic_tag_ram;
                    } u_ic_tag_ram;
                    struct {
                        struct {
                            ZEBU::Memory *mem_r;
                        } u_iccm0_sram;
                    } u_iccm0_even;
                } iesrams_rl_srams;
            } iarchipelago;
            struct {
                struct {
                    struct {
                        ZEBU::Memory *sqnod2985;
                    } sqnod21800;
                    struct {
                        ZEBU::Memory *sqnod2985;
                    } sqnod21801;
                    struct {
                        struct {
                            ZEBU::Memory *sqnod845601;
                        } sqnod1818;
                    } sqnod21802;
                } master_node_i;
            } izebu_axi_xtor;
        } icore_sys;
    } core_chip_dut;
} ZEBU_zebu_top_Top;
extern ZEBU::Memory **zebu_top_memtbl;

extern ZEBU_zebu_top_Top zebu_top;

int ZEBU_zebu_top_Init(ZEBU::Board *zebu);

#endif
