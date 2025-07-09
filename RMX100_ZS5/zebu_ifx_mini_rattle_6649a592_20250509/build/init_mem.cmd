mem write -l 262144 1048576*0 0
mem write -l 262144 1048576*2048 0
expr $bank_reg(0x1, 0x7B0)
expr $put_bank_reg(0x1, 0x7B0, (0x8000 | $bank_reg(0x1, 0x7B0)))
expr -f h -- $bank_reg(0x1, 0x7B0)
reg read dcsr
