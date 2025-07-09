#ifndef core_config_hpp
#define core_config_hpp

#include <cstdint>

    /* coverity[cert_dcl51_cpp_violation] */
    /* coverity[autosar_cpp14_a16_0_1_violation] */
    /* coverity[autosar_cpp14_a17_0_1_violation] */
#define _TOOL_CONFIG_VER 10108

namespace snps_arc {
    namespace core_config {

	/********  NOTE: Start of BCR/CIR Variables ******************
	 * The initial variables with "kBcr" or "kCir" in the macro name
	 * may appear and disappear as different hardware releases change the
	 * layout of configuration registers. Additionally, the semantics of
	 * a "kBcr" or "KCir" variable value is subject to change.
	 * For these reasons it is recommended to avoid dependency on symbols
	 * which have "kBcr" or "kCir" in the name (and request alternative
	 * variables as needed).
	 **********************************************************/
	    /* value for misa */
	static constexpr std::uint32_t kCirMisa{0x40901105UL};
	    /* value for misa.a */
	static constexpr std::uint32_t kCirMisaA{1UL};
	    /* value for misa.b */
	static constexpr std::uint32_t kCirMisaB{0UL};
	    /* value for misa.c */
	static constexpr std::uint32_t kCirMisaC{1UL};
	    /* value for misa.d */
	static constexpr std::uint32_t kCirMisaD{0UL};
	    /* value for misa.e */
	static constexpr std::uint32_t kCirMisaE{0UL};
	    /* value for misa.f */
	static constexpr std::uint32_t kCirMisaF{0UL};
	    /* value for misa.h */
	static constexpr std::uint32_t kCirMisaH{0UL};
	    /* value for misa.i */
	static constexpr std::uint32_t kCirMisaI{1UL};
	    /* value for misa.m */
	static constexpr std::uint32_t kCirMisaM{1UL};
	    /* value for misa.s */
	static constexpr std::uint32_t kCirMisaS{0UL};
	    /* value for misa.u */
	static constexpr std::uint32_t kCirMisaU{1UL};
	    /* value for misa.v */
	static constexpr std::uint32_t kCirMisaV{0UL};
	    /* value for misa.x */
	static constexpr std::uint32_t kCirMisaX{1UL};
	    /* value for mstatush */
	static constexpr std::uint32_t kCirMstatush{0x00000400UL};
	    /* value for tdata1 */
	static constexpr std::uint32_t kCirTdata1{0xF0000000UL};
	    /* value for tinfo */
	static constexpr std::uint32_t kCirTinfo{0x010080C0UL};
	    /* value for miccm_ctl */
	static constexpr std::uint32_t kCirMiccmCtl{0x00000001UL};
	    /* value for miccm_ctl.e0 */
	static constexpr std::uint32_t kCirMiccmCtlE0{1UL};
	    /* value for miccm_ctl.r0 */
	static constexpr std::uint32_t kCirMiccmCtlR0{0UL};
	    /* value for miccm_ctl.d0 */
	static constexpr std::uint32_t kCirMiccmCtlD0{0UL};
	    /* value for miccm_ctl.e1 */
	static constexpr std::uint32_t kCirMiccmCtlE1{0UL};
	    /* value for miccm_ctl.r1 */
	static constexpr std::uint32_t kCirMiccmCtlR1{0UL};
	    /* value for miccm_ctl.d1 */
	static constexpr std::uint32_t kCirMiccmCtlD1{0UL};
	    /* value for miccm_ctl.iccm1_base */
	static constexpr std::uint32_t kCirMiccmCtlIccm1Base{0UL};
	    /* value for miccm_ctl.iccm0_base */
	static constexpr std::uint32_t kCirMiccmCtlIccm0Base{0UL};
	    /* value for mdccm_ctl */
	static constexpr std::uint32_t kCirMdccmCtl{0x80000001UL};
	    /* value for mdccm_ctl.e */
	static constexpr std::uint32_t kCirMdccmCtlE{1UL};
	    /* value for mdccm_ctl.r */
	static constexpr std::uint32_t kCirMdccmCtlR{0UL};
	    /* value for mdccm_ctl.d */
	static constexpr std::uint32_t kCirMdccmCtlD{0UL};
	    /* value for mdccm_ctl.dccm_base */
	static constexpr std::uint32_t kCirMdccmCtlDccmBase{2048UL};
	    /* value for arcv_per0_base */
	static constexpr std::uint32_t kCirArcvPer0Base{0xF0000000UL};
	    /* value for arcv_per0_base.per0_base */
	static constexpr std::uint32_t kCirArcvPer0BasePer0Base{3840UL};
	    /* value for arcv_per0_size */
	static constexpr std::uint32_t kCirArcvPer0Size{0x00000001UL};
	    /* value for arcv_per0_size.per0_size */
	static constexpr std::uint32_t kCirArcvPer0SizePer0Size{1UL};
	    /* value for mcache_ctl */
	static constexpr std::uint32_t kCirMcacheCtl{0x00000003UL};
	    /* value for mwdt_passwd */
	static constexpr std::uint32_t kCirMwdtPasswd{0x00000000UL};
	    /* value for pma_addr0 */
	static constexpr std::uint32_t kCirPmaAddr0{0x000001FFUL};
	    /* value for pma_addr1 */
	static constexpr std::uint32_t kCirPmaAddr1{0x000001FFUL};
	    /* value for pma_addr2 */
	static constexpr std::uint32_t kCirPmaAddr2{0x000001FFUL};
	    /* value for pma_addr3 */
	static constexpr std::uint32_t kCirPmaAddr3{0x000001FFUL};
	    /* value for pma_addr4 */
	static constexpr std::uint32_t kCirPmaAddr4{0x000001FFUL};
	    /* value for pma_addr5 */
	static constexpr std::uint32_t kCirPmaAddr5{0x000001FFUL};
	    /* value for msfty_passwd */
	static constexpr std::uint32_t kCirMsftyPasswd{0x00000001UL};
	    /* value for msfty_ctrl */
	static constexpr std::uint32_t kCirMsftyCtrl{0x55555555UL};
	    /* value for msfty_diag */
	static constexpr std::uint32_t kCirMsftyDiag{0x55555555UL};
	    /* value for msfty_stl_ctrl */
	static constexpr std::uint32_t kCirMsftyStlCtrl{0x00000001UL};
	    /* value for marchid */
	static constexpr std::uint32_t kCirMarchid{0x80000401UL};
	    /* value for marchid.family */
	static constexpr std::uint32_t kCirMarchidFamily{1UL};
	    /* value for marchid.m */
	static constexpr std::uint32_t kCirMarchidM{0UL};
	    /* value for marchid.v */
	static constexpr std::uint32_t kCirMarchidV{0UL};
	    /* value for marchid.f */
	static constexpr std::uint32_t kCirMarchidF{1UL};
	    /* value for mimpid */
	static constexpr std::uint32_t kCirMimpid{0x00010100UL};
	    /* value for mimpid.product */
	static constexpr std::uint32_t kCirMimpidProduct{1UL};
	    /* value for mimpid.major_rev */
	static constexpr std::uint32_t kCirMimpidMajorRev{1UL};
	    /* value for mimpid.minor_rev */
	static constexpr std::uint32_t kCirMimpidMinorRev{0UL};
	    /* value for mhartid */
	static constexpr std::uint32_t kCirMhartid{0x00000000UL};
	    /* value for mconfigptr */
	static constexpr std::uint32_t kCirMconfigptr{0x00000000UL};
	    /* value for arcv_mwdt_build */
	static constexpr std::uint32_t kBcrArcvMwdtBuild{0x8FA13C01UL};
	    /* value for arcv_mwdt_build.version */
	static constexpr std::uint32_t kBcrArcvMwdtBuildVersion{1UL};
	    /* value for arcv_mwdt_build.nt */
	static constexpr std::uint32_t kBcrArcvMwdtBuildNt{0UL};
	    /* value for arcv_mwdt_build.sizes */
	static constexpr std::uint32_t kBcrArcvMwdtBuildSizes{15UL};
	    /* value for arcv_mwdt_build.scale */
	static constexpr std::uint32_t kBcrArcvMwdtBuildScale{4UL};
	    /* value for arcv_mwdt_build.freq */
	static constexpr std::uint32_t kBcrArcvMwdtBuildFreq{2000UL};
	    /* value for arcv_mwdt_build.c */
	static constexpr std::uint32_t kBcrArcvMwdtBuildC{1UL};
	    /* value for arcv_mmio_build */
	static constexpr std::uint32_t kBcrArcvMmioBuild{0x00000E00UL};
	    /* value for arcv_mmio_build.core_mmio_base */
	static constexpr std::uint32_t kBcrArcvMmioBuildCoreMmioBase{3584UL};
	    /* value for arcv_hpm_build */
	static constexpr std::uint32_t kBcrArcvHpmBuild{0x00080601UL};
	    /* value for arcv_hpm_build.version */
	static constexpr std::uint32_t kBcrArcvHpmBuildVersion{1UL};
	    /* value for arcv_hpm_build.s */
	static constexpr std::uint32_t kBcrArcvHpmBuildS{2UL};
	    /* value for arcv_hpm_build.i */
	static constexpr std::uint32_t kBcrArcvHpmBuildI{1UL};
	    /* value for arcv_hpm_build.c */
	static constexpr std::uint32_t kBcrArcvHpmBuildC{8UL};
	    /* value for arcv_msfty_build */
	static constexpr std::uint32_t kBcrArcvMsftyBuild{0x44000001UL};
	    /* value for arcv_msfty_build.version */
	static constexpr std::uint32_t kBcrArcvMsftyBuildVersion{1UL};
	    /* value for arcv_msfty_build.sb */
	static constexpr std::uint32_t kBcrArcvMsftyBuildSb{0UL};
	    /* value for arcv_msfty_build.asil */
	static constexpr std::uint32_t kBcrArcvMsftyBuildAsil{0UL};
	    /* value for arcv_msfty_build.sbe_dpt */
	static constexpr std::uint32_t kBcrArcvMsftyBuildSbeDpt{1UL};
	    /* value for arcv_msfty_build.stl */
	static constexpr std::uint32_t kBcrArcvMsftyBuildStl{0UL};
	    /* value for arcv_msfty_build.hei */
	static constexpr std::uint32_t kBcrArcvMsftyBuildHei{1UL};
	    /* value for arcv_msfty_build.hyb */
	static constexpr std::uint32_t kBcrArcvMsftyBuildHyb{0UL};
	    /* value for arcv_timer_build */
	static constexpr std::uint32_t kBcrArcvTimerBuild{0xE0010001UL};
	    /* value for arcv_timer_build.version */
	static constexpr std::uint32_t kBcrArcvTimerBuildVersion{1UL};
	    /* value for arcv_timer_build.s */
	static constexpr std::uint32_t kBcrArcvTimerBuildS{0UL};
	    /* value for arcv_timer_build.base */
	static constexpr std::uint32_t kBcrArcvTimerBuildBase{917520UL};
	    /* value for arcv_bcr_build */
	static constexpr std::uint32_t kBcrArcvBcrBuild{0x00000001UL};
	    /* value for arcv_bcr_build.version */
	static constexpr std::uint32_t kBcrArcvBcrBuildVersion{1UL};
	    /* value for arcv_pmp_build */
	static constexpr std::uint32_t kBcrArcvPmpBuild{0x000A1001UL};
	    /* value for arcv_pmp_build.version */
	static constexpr std::uint32_t kBcrArcvPmpBuildVersion{1UL};
	    /* value for arcv_pmp_build.regions */
	static constexpr std::uint32_t kBcrArcvPmpBuildRegions{16UL};
	    /* value for arcv_pmp_build.s */
	static constexpr std::uint32_t kBcrArcvPmpBuildS{0UL};
	    /* value for arcv_pmp_build.granularity */
	static constexpr std::uint32_t kBcrArcvPmpBuildGranularity{5UL};
	    /* value for arcv_pma_build */
	static constexpr std::uint32_t kBcrArcvPmaBuild{0x00000601UL};
	    /* value for arcv_pma_build.version */
	static constexpr std::uint32_t kBcrArcvPmaBuildVersion{1UL};
	    /* value for arcv_pma_build.regions */
	static constexpr std::uint32_t kBcrArcvPmaBuildRegions{6UL};
	    /* value for arcv_dccm_build */
	static constexpr std::uint32_t kBcrArcvDccmBuild{0x00020901UL};
	    /* value for arcv_dccm_build.version */
	static constexpr std::uint32_t kBcrArcvDccmBuildVersion{1UL};
	    /* value for arcv_dccm_build.size */
	static constexpr std::uint32_t kBcrArcvDccmBuildSize{9UL};
	    /* value for arcv_dccm_build.cycles */
	static constexpr std::uint32_t kBcrArcvDccmBuildCycles{1UL};
	    /* value for arcv_icache_build */
	static constexpr std::uint32_t kBcrArcvIcacheBuild{0x00013101UL};
	    /* value for arcv_icache_build.version */
	static constexpr std::uint32_t kBcrArcvIcacheBuildVersion{1UL};
	    /* value for arcv_icache_build.assoc */
	static constexpr std::uint32_t kBcrArcvIcacheBuildAssoc{1UL};
	    /* value for arcv_icache_build.size */
	static constexpr std::uint32_t kBcrArcvIcacheBuildSize{3UL};
	    /* value for arcv_icache_build.bsize */
	static constexpr std::uint32_t kBcrArcvIcacheBuildBsize{1UL};
	    /* value for arcv_icache_build.c */
	static constexpr std::uint32_t kBcrArcvIcacheBuildC{0UL};
	    /* value for arcv_icache_build.d */
	static constexpr std::uint32_t kBcrArcvIcacheBuildD{0UL};
	    /* value for arcv_iccm_build */
	static constexpr std::uint32_t kBcrArcvIccmBuild{0x00000801UL};
	    /* value for arcv_iccm_build.version */
	static constexpr std::uint32_t kBcrArcvIccmBuildVersion{1UL};
	    /* value for arcv_iccm_build.iccm0_size */
	static constexpr std::uint32_t kBcrArcvIccmBuildIccm0Size{8UL};
	    /* value for arcv_iccm_build.iccm1_size */
	static constexpr std::uint32_t kBcrArcvIccmBuildIccm1Size{0UL};
	    /* value for arcv_clint_build */
	static constexpr std::uint32_t kBcrArcvClintBuild{0x10000113UL};
	    /* value for arcv_clint_build.stsp */
	static constexpr std::uint32_t kBcrArcvClintBuildStsp{1UL};
	    /* value for arcv_clint_build.snvi */
	static constexpr std::uint32_t kBcrArcvClintBuildSnvi{1UL};
	    /* value for arcv_clint_build.sstc */
	static constexpr std::uint32_t kBcrArcvClintBuildSstc{0UL};
	    /* value for arcv_clint_build.sswi */
	static constexpr std::uint32_t kBcrArcvClintBuildSswi{0UL};
	    /* value for arcv_clint_build.mjpri */
	static constexpr std::uint32_t kBcrArcvClintBuildMjpri{1UL};
	    /* value for arcv_clint_build.version */
	static constexpr std::uint32_t kBcrArcvClintBuildVersion{1UL};
	    /* value for arcv_imsic_build */
	static constexpr std::uint32_t kBcrArcvImsicBuild{0x10010001UL};
	    /* value for arcv_imsic_build.mfsz */
	static constexpr std::uint32_t kBcrArcvImsicBuildMfsz{1UL};
	    /* value for arcv_imsic_build.sifsz */
	static constexpr std::uint32_t kBcrArcvImsicBuildSifsz{0UL};
	    /* value for arcv_imsic_build.gifsz */
	static constexpr std::uint32_t kBcrArcvImsicBuildGifsz{0UL};
	    /* value for arcv_imsic_build.gifnum */
	static constexpr std::uint32_t kBcrArcvImsicBuildGifnum{0UL};
	    /* value for arcv_imsic_build.eidlv */
	static constexpr std::uint32_t kBcrArcvImsicBuildEidlv{1UL};
	    /* value for arcv_imsic_build.version */
	static constexpr std::uint32_t kBcrArcvImsicBuildVersion{1UL};
	    /* value for arcv_triggers_build */
	static constexpr std::uint32_t kBcrArcvTriggersBuild{0x00000201UL};
	    /* value for arcv_triggers_build.version */
	static constexpr std::uint32_t kBcrArcvTriggersBuildVersion{1UL};
	    /* value for arcv_triggers_build.trig_num */
	static constexpr std::uint32_t kBcrArcvTriggersBuildTrigNum{2UL};
	    /* value for arcv_sec_build */
	static constexpr std::uint32_t kBcrArcvSecBuild{0x80002001UL};
	    /* value for arcv_sec_build.version */
	static constexpr std::uint32_t kBcrArcvSecBuildVersion{1UL};
	    /* value for arcv_sec_build.num_wids */
	static constexpr std::uint32_t kBcrArcvSecBuildNumWids{32UL};
	    /* value for arcv_sec_build.fixed_wid */
	static constexpr std::uint32_t kBcrArcvSecBuildFixedWid{0UL};
	    /* value for arcv_sec_build.m */
	static constexpr std::uint32_t kBcrArcvSecBuildM{1UL};
	    /* value for arcv_dmp_per_build */
	static constexpr std::uint32_t kBcrArcvDmpPerBuild{0x00000101UL};
	    /* value for arcv_dmp_per_build.version */
	static constexpr std::uint32_t kBcrArcvDmpPerBuildVersion{1UL};
	    /* value for arcv_dmp_per_build.per0_size */
	static constexpr std::uint32_t kBcrArcvDmpPerBuildPer0Size{1UL};
	    /* value for arcv_isa_opts_build */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuild{0x03341BE1UL};
	    /* value for arcv_isa_opts_build.version */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildVersion{1UL};
	    /* value for arcv_isa_opts_build.zcb */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZcb{1UL};
	    /* value for arcv_isa_opts_build.zcmp */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZcmp{1UL};
	    /* value for arcv_isa_opts_build.zcmt */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZcmt{1UL};
	    /* value for arcv_isa_opts_build.zba */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZba{1UL};
	    /* value for arcv_isa_opts_build.zbb */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZbb{1UL};
	    /* value for arcv_isa_opts_build.zbc */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZbc{0UL};
	    /* value for arcv_isa_opts_build.zbs */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZbs{1UL};
	    /* value for arcv_isa_opts_build.zicond */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZicond{1UL};
	    /* value for arcv_isa_opts_build.zfinx */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZfinx{0UL};
	    /* value for arcv_isa_opts_build.zdinx */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZdinx{0UL};
	    /* value for arcv_isa_opts_build.zfa */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZfa{0UL};
	    /* value for arcv_isa_opts_build.zfh */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZfh{0UL};
	    /* value for arcv_isa_opts_build.zk */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZk{0UL};
	    /* value for arcv_isa_opts_build.zca */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZca{1UL};
	    /* value for arcv_isa_opts_build.zhinx */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZhinx{0UL};
	    /* value for arcv_isa_opts_build.zicbom */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZicbom{1UL};
	    /* value for arcv_isa_opts_build.zicbop */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZicbop{1UL};
	    /* value for arcv_isa_opts_build.ziccamoa */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZiccamoa{0UL};
	    /* value for arcv_isa_opts_build.zic64rs */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZic64rs{0UL};
	    /* value for arcv_isa_opts_build.zicsr */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildZicsr{1UL};
	    /* value for arcv_isa_opts_build.n */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildN{1UL};
	    /* value for arcv_isa_opts_build.res */
	static constexpr std::uint32_t kBcrArcvIsaOptsBuildRes{0UL};
	    /* value for arcv_ras_build */
	static constexpr std::uint32_t kBcrArcvRasBuild{0x000C3601UL};
	    /* value for arcv_ras_build.version */
	static constexpr std::uint32_t kBcrArcvRasBuildVersion{1UL};
	    /* value for arcv_ras_build.dp */
	static constexpr std::uint32_t kBcrArcvRasBuildDp{6UL};
	    /* value for arcv_ras_build.ip */
	static constexpr std::uint32_t kBcrArcvRasBuildIp{6UL};
	    /* value for arcv_ras_build.dcp */
	static constexpr std::uint32_t kBcrArcvRasBuildDcp{0UL};
	    /* value for arcv_ras_build.icp */
	static constexpr std::uint32_t kBcrArcvRasBuildIcp{6UL};
	    /* value for arcv_ras_build.l2cp */
	static constexpr std::uint32_t kBcrArcvRasBuildL2cp{0UL};
	    /* value for arcv_ras_build.mmu */
	static constexpr std::uint32_t kBcrArcvRasBuildMmu{0UL};
	    /* value for arcv_sr_epc */
	static constexpr std::uint32_t kCirArcvSrEpc{0x00000000UL};
	/************* End of BCR/CIR Macros **********************/
	    // coverity[autosar_cpp14_a3_9_1_violation]
	    /* value for family_name */
	static constexpr char const* const kFamilyName{"av5rmx"};
	    /* value for family */
	static constexpr std::uint32_t kFamily{1UL};
	    /* value for core_version */
	static constexpr std::uint32_t kCoreVersion{1UL};
	    /* value for za */
	static constexpr std::uint32_t kZa{1UL};
	    /* value for zca */
	static constexpr std::uint32_t kZca{1UL};
	    /* value for zc */
	static constexpr std::uint32_t kZc{1UL};
	    /* value for zm */
	static constexpr std::uint32_t kZm{1UL};
	    /* value for zu */
	static constexpr std::uint32_t kZu{1UL};
	    /* value for zcb */
	static constexpr std::uint32_t kZcb{1UL};
	    /* value for zcmp */
	static constexpr std::uint32_t kZcmp{1UL};
	    /* value for zcmt */
	static constexpr std::uint32_t kZcmt{1UL};
	    /* value for zba */
	static constexpr std::uint32_t kZba{1UL};
	    /* value for zbb */
	static constexpr std::uint32_t kZbb{1UL};
	    /* value for zbs */
	static constexpr std::uint32_t kZbs{1UL};
	    /* value for zicond */
	static constexpr std::uint32_t kZicond{1UL};
	    /* value for zicbom */
	static constexpr std::uint32_t kZicbom{1UL};
	    /* value for zicbop */
	static constexpr std::uint32_t kZicbop{1UL};
	    /* value for Xunaligned */
	static constexpr std::uint32_t kXunaligned{1UL};
	    /* value for zifencei */
	static constexpr std::uint32_t kZifencei{1UL};
	    /* value for zihintpause */
	static constexpr std::uint32_t kZihintpause{1UL};
	    /* value for zicsr */
	static constexpr std::uint32_t kZicsr{1UL};
	    /* value for reset_pc */
	static constexpr std::uint32_t kResetPc{0x0UL};
	    /* value for reset_pc_ext */
	static constexpr std::uint32_t kResetPcExt{1UL};
	    /* value for Xmpy_cycles */
	static constexpr std::uint32_t kXmpyCycles{10UL};
	    /* value for iccm0.present */
	static constexpr std::uint32_t kIccm0Present{1UL};
	    /* value for iccm0.base */
	static constexpr std::uint32_t kIccm0Base{0x0UL};
	    /* value for iccm0.size */
	static constexpr std::uint32_t kIccm0Size{0x80000UL};
	    /* value for dccm.present */
	static constexpr std::uint32_t kDccmPresent{1UL};
	    /* value for dccm.base */
	static constexpr std::uint32_t kDccmBase{0x80000000UL};
	    /* value for dccm.size */
	static constexpr std::uint32_t kDccmSize{0x100000UL};
	    /* value for dccm_mem_cycles */
	static constexpr std::uint32_t kDccmMemCycles{1UL};
	    /* value for icache.present */
	static constexpr std::uint32_t kIcachePresent{1UL};
	    /* value for icache.size */
	static constexpr std::uint32_t kIcacheSize{0x4000UL};
	    /* value for icache.line_size */
	static constexpr std::uint32_t kIcacheLineSize{32UL};
	    /* value for icache.ways */
	static constexpr std::uint32_t kIcacheWays{2UL};
	    /* value for icache_version */
	static constexpr std::uint32_t kIcacheVersion{1UL};
	    /* value for mmio_base */
	static constexpr std::uint32_t kMmioBase{0xE0000000UL};
	    /* value for rtia_hart_major_width */
	static constexpr std::uint32_t kRtiaHartMajorWidth{64UL};
	    /* value for rtia_stsp */
	static constexpr std::uint32_t kRtiaStsp{1UL};
	    /* value for rtia_snvi */
	static constexpr std::uint32_t kRtiaSnvi{1UL};
	    /* value for smrnmi */
	static constexpr std::uint32_t kSmrnmi{1UL};
	    /* value for rnmi_vec_ext */
	static constexpr std::uint32_t kRnmiVecExt{1UL};
	    /* value for rnmi_int_vec */
	static constexpr std::uint32_t kRnmiIntVec{0x100UL};
    } // namespace core_config

} // namespace snps_arc

#endif /* core_config_hpp */


