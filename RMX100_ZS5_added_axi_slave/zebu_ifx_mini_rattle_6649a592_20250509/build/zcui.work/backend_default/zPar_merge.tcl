read_edif tools/zPar/debug_netlists/global_merge.edf.gz
read_edif work.Part_0/edif/U0_M0_F0.edf.gz
read_edif work.Part_0/edif/U0_M0_F1.edf.gz
set_top design_lib:zebu_top
write_edif merged.edf.gz
