// Library ARCv2_ZEBU_RDF-2.0.999999999

initial begin : FULL_DUT_DUMP
    (* qiwc, no_opt *) $dumpvars(0, zebu_top);
end

initial begin : FULL_DUT_DUMP_PORTS
    (* fwc, no_opt *) $dumpports(zebu_top.core_chip_dut.icore_sys.iarchipelago);
end

//initial begin : UPF_DUMP
//    (* upf *) $dumpvars(0, zebu_top);
//end
