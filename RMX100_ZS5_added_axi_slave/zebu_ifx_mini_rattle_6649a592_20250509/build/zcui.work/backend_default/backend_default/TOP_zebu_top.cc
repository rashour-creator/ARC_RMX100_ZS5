/* -----------------------------------------------
   LEGAL NOTICE: This file is the sole property of 
   EMULATION AND VERIFICATION ENGINEERING (EVE).

   This file is  provided under  a Product License 
   Agreement between EVE and a Licensee.

   Licensee shall not make this  file available in 
   any  form or  disclose or permit  disclosure of 
   file to third parties.
   ----------------------------------------------- */

#include <unistd.h>
#include "TOP_zebu_top.hh"

ZEBU_zebu_top_Top zebu_top;

ZEBU::Memory **zebu_top_memtbl;

int ZEBU_zebu_top_Init(ZEBU::Board *zebu) {
    if(zebu == NULL) {
        return 1;
    }

    zebu_top_memtbl = new ZEBU::Memory*[22];
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12754.sqnod6249 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12754.sqnod6249");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1438.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1438.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1439.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1439.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1440.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1440.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1441.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1441.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1442.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1442.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1443.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1443.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1444.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1444.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1445.sqnod256809 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1445.sqnod256809");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1465 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1465");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_bdel_mem = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_bdel_mem");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_rdel_mem = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_rdel_mem");
    zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_mem_inst.u_alb_mss_mem_ram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_mem_inst.u_alb_mss_mem_ram.mem_r");
    zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_even.u_DCCM_sram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_even.u_DCCM_sram.mem_r");
    zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_odd.u_DCCM_sram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_odd.u_DCCM_sram.mem_r");
    zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_data_ram.u_ic_data_ram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_data_ram.u_ic_data_ram.mem_r");
    zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_tag_ram.u_ic_tag_ram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_tag_ram.u_ic_tag_ram.mem_r");
    zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_iccm0_even.u_iccm0_sram.mem_r = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_iccm0_even.u_iccm0_sram.mem_r");
    zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21800.sqnod2985 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21800.sqnod2985");
    zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21801.sqnod2985 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21801.sqnod2985");
    zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21802.sqnod1818.sqnod845601 = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21802.sqnod1818.sqnod845601");
    zebu_top_memtbl[0] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12754.sqnod6249");
    zebu_top_memtbl[1] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1438.sqnod256809");
    zebu_top_memtbl[2] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1439.sqnod256809");
    zebu_top_memtbl[3] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1440.sqnod256809");
    zebu_top_memtbl[4] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1441.sqnod256809");
    zebu_top_memtbl[5] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1442.sqnod256809");
    zebu_top_memtbl[6] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1443.sqnod256809");
    zebu_top_memtbl[7] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1444.sqnod256809");
    zebu_top_memtbl[8] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1445.sqnod256809");
    zebu_top_memtbl[9] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_dummy_slave.i2_axi_slave.slave_xtor.sqnod12755.sqnod1465");
    zebu_top_memtbl[10] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_bdel_mem");
    zebu_top_memtbl[11] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_lat_inst.u_mem_bus_lat.i_rdel_mem");
    zebu_top_memtbl[12] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.ialb_mss_mem.u_rgon0_mem_inst.u_alb_mss_mem_ram.mem_r");
    zebu_top_memtbl[13] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_even.u_DCCM_sram.mem_r");
    zebu_top_memtbl[14] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_dccm_odd.u_DCCM_sram.mem_r");
    zebu_top_memtbl[15] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_data_ram.u_ic_data_ram.mem_r");
    zebu_top_memtbl[16] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_ic_tag_ram.u_ic_tag_ram.mem_r");
    zebu_top_memtbl[17] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.iarchipelago.iesrams_rl_srams.u_iccm0_even.u_iccm0_sram.mem_r");
    zebu_top_memtbl[18] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21800.sqnod2985");
    zebu_top_memtbl[19] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21801.sqnod2985");
    zebu_top_memtbl[20] = zebu->getMemory("zebu_top.core_chip_dut.icore_sys.izebu_axi_xtor.master_node_i.sqnod21802.sqnod1818.sqnod845601");
    zebu_top_memtbl[21] = NULL;
    return 0;
}
