
 extern void ZEBU_VS_AMBA_MASTER_error__notifier(/* INPUT */int error_code);

 extern void ZEBU_VS_AMBA_MASTER_dpi__write_resp(/* INPUT */int resp, /* INPUT */int bid, const /* INPUT */svBitVecVal *buser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__nostream_write_resp(/* INPUT */int resp, /* INPUT */int bid, const /* INPUT */svBitVecVal *buser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__read_resp(/* INPUT */int rid, /* INPUT */int resp, /* INPUT */unsigned char rlast, const /* INPUT */svBitVecVal *rdata, const /* INPUT */svBitVecVal *ruser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__nostream_read_resp(/* INPUT */int rid, /* INPUT */int resp, /* INPUT */unsigned char rlast, const /* INPUT */svBitVecVal *rdata, const /* INPUT */svBitVecVal *ruser);

 extern void ZEBU_VS_AMBA_MASTER_dpi__rdAddrFifo();

 extern void ZEBU_VS_AMBA_MASTER_dpi__wrAddrFifo();

 extern void ZEBU_VS_AMBA_MASTER_dpi__wrDataFifo(/* INPUT */int wid);

 extern void ZEBU_VS_SNPS_UDPI__BuildSerialNumber(const /* INPUT */svBitVecVal *data);

 extern void ZEBU_VS_SNPS_UDPI__rst_assert();

 extern void ZEBU_VS_SNPS_UDPI__rst_deassert();

 extern void ZEBU_VS_SNPS_UDPI__unlockSw();

 extern void ZEBU_VS_SNPS_UDPI__clkTick();

 extern void ZEBU_VS_AMBA_SLAVE_error__notifier(/* INPUT */int error_code);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_addr(const /* INPUT */svBitVecVal *AW_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_data(const /* INPUT */svBitVecVal *WDATA_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__read_addr(const /* INPUT */svBitVecVal *AR_txn, const /* INPUT */svBitVecVal *global_counter);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__read_fifo(/* INPUT */int rid);

 extern void ZEBU_VS_AMBA_SLAVE_dpi__write_fifo(/* INPUT */int wid);

 extern void* svapfGetAttempt(/* INPUT */unsigned int assertHandle);

 extern void svapfReportResult(/* INPUT */unsigned int assertHandle, /* INPUT */void* ptrAttempt, /* INPUT */int result);

 extern int svapfGetAssertEnabled(/* INPUT */unsigned int assertHandle);
