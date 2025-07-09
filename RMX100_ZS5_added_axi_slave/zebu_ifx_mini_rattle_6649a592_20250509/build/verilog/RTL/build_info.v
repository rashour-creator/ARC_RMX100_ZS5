
`ifdef VPP_JS
<script>
var core_table = 
  {
  cores: 	
    [
      {
      prefix: 	"",
      define_prefix: 	"",
      arcnum: 	0,
      arcnums: 	
        []
      ,
      instances: 	
        [0,]
      ,
      }
    ,
    ]
  ,
  instances: 	
    [
      {
      type_prefix: 	"",
      define_prefix: 	"",
      signal_prefix: 	"",
      clk_prefix: 	"",
      arcnum: 	0,
      core: 	0,
      }
    ,
    ]
  ,
  }

</script>
`endif

// ARChitect values:
`define ARCHITECT_OS	"linux"
`define ARCHITECT_BUILD_DIRECTORY	"/remote/sdgedt/tools/reem/ZebuS5_newslave/zebu_ifx_mini_rattle_6649a592_20250509/build/"
`define ARCHITECT_BUILD_DIRECTORY_WIN32	"\\remote\\sdgedt\\tools\\reem\\ZebuS5_newslave\\zebu_ifx_mini_rattle_6649a592_20250509\\build\\"

// Options on component zebu_ifx_mini_rattle_6649a592_20250509:
`define PROJECT_BUILD_HTML_DOCS	0
`define PROJECT_BUILD_SOFTWARE	0
`define PROJECT_BUILD_TEST_CODE	0
`define PROJECT_BUILD_SCRIPTS	1
`define PROJECT_BUILD_HDL	1
`define PROJECT_COMPILE_TEST_CODE	0
`define PROJECT_GENERATE_STRUCTURAL_HDL	1
`define PROJECT_COMPILE_HDL_FOR_SIMULATION	0
`define PROJECT_BUILD_XCAM	0
`define PROJECT_RUN_ARCSYN	0
`define PROJECT_RUN_SEIF	0
`define PROJECT_RUN_ARCRAMS	0
`define PROJECT_RUN_ARCFORMAL	0
`define PROJECT_RUN_ARCPOWER	0
`define PROJECT_COMPILE_NSIM_USER_EXTENSION	0
`define PROJECT_COMPILE_TRANSLATED_NSIM_EXTENSIONS	0

// Options on component System:
`define SYSTEM_SIM64	0
`define SYSTEM_EXPORT_SRAMS_TO	"archipelago"
`define SYSTEM_COPY_PREFIX	0

// Options on component Implementation:
`define IMPLEMENTATION_EXECUTION_TRACE_LEVEL	"stats"
`define IMPLEMENTATION_UNIQUE_CLK	1
`define IMPLEMENTATION_IPXACT_DYNAMIC_AUX_REGS	1
`define IMPLEMENTATION_PIPEMON_INIT_BITS	4'b0011; // Enable debug instrs(0); - (0); Suppress transcript (1); enable statistics gathering (1).
`define IMPLEMENTATION_PIPEMON_TO_FILE	0 /*(1<<9) sends output to a file*/
`define IMPLEMENTATION_PIPEMON_FILE_NAME	"trace.txt"

// Below is a sequence of defines of the form XXX_PRESENT
// for each VPP-based system component present in the build that wishes to
// indicate its presence.
`define ARCV_DM_PRESENT	1
`define ALB_MSS_FAB_PRESENT	1
`define ALB_MSS_CLKCTRL_PRESENT	1
`define DW_DBP_PRESENT	1
`define ALB_MSS_DUMMY_SLAVE_PRESENT	1
`define ALB_MSS_PERFCTRL_PRESENT	1
`define ALB_MSS_MEM_PRESENT	1
`define RV_SAFETY_PRESENT	1
`define ZEBU_AXI_XTOR_PRESENT	1
`define ZEBU_BOX_PRESENT	1

// Below are defines for every component not contained 
// within a core, using the ARChitect type to denote the component.
`define COM_ARC_HARDWARE_ARC_SOC_TRACE_ARCV_DM_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2MSS_BUSFABRIC_PRESENT	1
`define COM_ARC_HARDWARE_EM_CPU_ISLE_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2MSS_CLKCTRL_PRESENT	1
`define COM_ARC_HARDWARE_DW_DBP_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2MSS_DUMMYSLV_PRESENT	1
`define COM_ARC_HARDWARE_IMPLEMENTATION_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2MSS_PROFILER_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2MSS_SRAMCTRL_PRESENT	1
`define COM_ARC_HARDWARE_RV_SAFETY_MANAGER_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2_ZEBU_RDF_ZEBU_AXI_XTOR_PRESENT	1
`define COM_ARC_HARDWARE_ARCV2_ZEBU_RDF_ZEBU_BOX_PRESENT	1

 
