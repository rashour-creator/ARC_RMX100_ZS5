`define hpm_s 2
`define hpm_i 1
`define hpm_ver 1
  `define PCT_HAS_ISA_MAJ_REV_3 0
  `define PCT_HAS_ISA_MAJ_REV_2 1
  `define PCT_HAS_ZOL           1
  `define PCT_HAS_32BIT_CORE    1
`define EVT_NEVER      6'd0  //  never                  hex = 64'h00000072_6576656e
`define EVT_BSTALL      6'd1  //  bstall                  hex = 64'h00006c6c_61747362
`define EVT_BISSUE      6'd2  //  bissue                  hex = 64'h00006575_73736962
`define EVT_BMEMRW      6'd3  //  bmemrw                  hex = 64'h00007772_6d656d62
`define EVT_BEXEC      6'd4  //  bexec                  hex = 64'h00000063_65786562
`define EVT_BSYNCSTALL      6'd5  //  bsyncstall                  hex = 64'h61747363_6e797362
`define EVT_BTRAP      6'd6  //  btrap                  hex = 64'h00000070_61727462
`define EVT_BICMSTALL      6'd7  //  bicmstall                  hex = 64'h6c617473_6d636962
`define EVT_BDMP      6'd8  //  bdmp                  hex = 64'h00000000_706d6462
`define EVT_BESTRUCT      6'd9  //  bestruct                  hex = 64'h74637572_74736562
`define EVT_BDEPSTALL      6'd10  //  bdepstall                  hex = 64'h6c617473_70656462
`define EVT_BIFSYNC      6'd11  //  bifsync                  hex = 64'h00636e79_73666962
`define EVT_BDFSYNC      6'd12  //  bdfsync                  hex = 64'h00636e79_73666462
`define EVT_BAUXFLSH      6'd13  //  bauxflsh                  hex = 64'h68736c66_78756162
`define EVT_BFIRQEX      6'd14  //  bfirqex                  hex = 64'h00786571_72696662
`define EVT_BDEBUG      6'd15  //  bdebug                  hex = 64'h00006775_62656462
`define EVT_BDSTRHAZ      6'd16  //  bdstrhaz                  hex = 64'h7a616872_74736462
`define EVT_BDREPLAY      6'd17  //  bdreplay                  hex = 64'h79616c70_65726462
`define EVT_BDQSTALL      6'd18  //  bdqstall                  hex = 64'h6c6c6174_73716462
`define EVT_BDCSTALL      6'd19  //  bdcstall                  hex = 64'h6c6c6174_73636462
`define EVT_BDMPCWB      6'd20  //  bdmpcwb                  hex = 64'h00627763_706d6462
`define EVT_BDMPLSQ      6'd21  //  bdmplsq                  hex = 64'h0071736c_706d6462
`define EVT_ICSR      6'd22  //  icsr                  hex = 64'h00000000_72736369
`define EVT_I2BYTE      6'd23  //  i2byte                  hex = 64'h00006574_79623269
`define EVT_I4BYTE      6'd24  //  i4byte                  hex = 64'h00006574_79623469
`define EVT_IWFI      6'd25  //  iwfi                  hex = 64'h00000000_69667769
`define EVT_IECALL      6'd26  //  iecall                  hex = 64'h00006c6c_61636569
`define EVT_IPROPCMOIC      6'd27  //  ipropcmoic                  hex = 64'h6f6d6370_6f727069
`define EVT_IALLJMP      6'd28  //  ialljmp                  hex = 64'h00706d6a_6c6c6169
`define EVT_IJMPC      6'd29  //  ijmpc                  hex = 64'h00000063_706d6a69
`define EVT_IJMPU      6'd30  //  ijmpu                  hex = 64'h00000075_706d6a69
`define EVT_IJMPTAK      6'd31  //  ijmptak                  hex = 64'h006b6174_706d6a69
`define EVT_ICALL      6'd32  //  icall                  hex = 64'h0000006c_6c616369
`define EVT_ICALLRET      6'd33  //  icallret                  hex = 64'h7465726c_6c616369
`define EVT_IMEMRD      6'd34  //  imemrd                  hex = 64'h00006472_6d656d69
`define EVT_IMEMWR      6'd35  //  imemwr                  hex = 64'h00007277_6d656d69
`define EVT_ILR      6'd36  //  ilr                  hex = 64'h00000000_00726c69
`define EVT_ISC      6'd37  //  isc                  hex = 64'h00000000_00637369
`define EVT_IMEMATOMIC      6'd38  //  imematomic                  hex = 64'h6d6f7461_6d656d69
`define EVT_ICM      6'd39  //  icm                  hex = 64'h00000000_006d6369
`define EVT_DBGFLUSH      6'd40  //  dbgflush                  hex = 64'h6873756c_66676264
`define EVT_ETAKEN      6'd41  //  etaken                  hex = 64'h00006e65_6b617465
`define EVT_QTAKEN      6'd42  //  qtaken                  hex = 64'h00006e65_6b617471
`define EVT_DMPREPLAY      6'd43  //  dmpreplay                  hex = 64'h616c7065_72706d64
`define EVT_ALWAYS      6'd44  //  always                  hex = 64'h00007379_61776c61
`define EVT_CRUN      6'd45  //  crun                  hex = 64'h00000000_6e757263
`define EVT_CRUNI      6'd46  //  cruni                  hex = 64'h00000069_6e757263
`define PCT_X1_EVENTS       47
`define PCT_X1_LSB          0
`define PCT_X1_MSB          47
`define PCT_X1_RANGE        46:0
`define PCT_CC_IDX_BITS  10
`define PCT_CC_IDX_RANGE 9:0
`define PCT_CC_IDX_FULL_BITS  11
`define PCT_CC_IDX_FULL_RANGE 10:0
`define PCT_EVENTS_MSB       46
`define PCT_EVENTS_LSB       0
`define PCT_EVENTS_RANGE     46:0
`define PCT_NUM_CONFIGS      47
`define PCT_CONFIG_RANGE     6:0
`define PCT_CONFIG_BITS      7
`define PCT_IDX_RANGE        2:0
`define PCT_IDX_BITS         3
`define PCT_COUNT_MSB      63
`define PCT_COUNT_WIDTH    64
`define PCT_COUNT_RANGE    63:0
