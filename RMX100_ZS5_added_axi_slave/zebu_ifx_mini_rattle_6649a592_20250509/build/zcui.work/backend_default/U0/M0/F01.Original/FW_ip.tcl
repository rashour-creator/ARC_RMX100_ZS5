# File generated by zNetgen_XDC_SORTOR on Wed May 14 19:20:00 2025

#XDC=design_fw.zdc
puts "\[[info script]\] - INFO : Reading IP 'ddr4_MTA16ATF2G64HZ_2G3_VU19P.xcix'"
#XDC=design_fw.zdc
read_ip [zVivado_get_xilinx_ip_dir]/ddr4_MTA16ATF2G64HZ_2G3_VU19P.xcix
#XDC=design_fw.zdc
if { [get_param -quiet ips.ignoreSWVersionInCacheId] ne {} } {
#XDC=design_fw.zdc
  puts "\[[info script]\] - INFO : Set MIG Cache Parameter : ips.ignoreSWVersionInCacheId=true"
#XDC=design_fw.zdc
  set_param ips.ignoreSWVersionInCacheId true
#XDC=design_fw.zdc
}
