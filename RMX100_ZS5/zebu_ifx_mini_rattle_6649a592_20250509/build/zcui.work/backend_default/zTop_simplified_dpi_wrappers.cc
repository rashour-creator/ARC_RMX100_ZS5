#include "grp0_ccall.h"
#include <stddef.h>

typedef unsigned int uint;

size_t expandDpi(size_t outSize, const uint* in, const uint* usageMask, const uint* cstData, uint* out)
{
    const size_t wordSize = 32;

    size_t inWordCnt = 0; // Number of 32-bit data input word
    size_t inBitOff  = 0; // Bit offset in the 32-bit input word

    for ( size_t wIdx = 0; wIdx < outSize; ++wIdx )
    {
        // Copy the 32-bit word with constants only
        if ( usageMask[wIdx] == 0 ) {
            out[wIdx] = cstData[wIdx];
        }
        // Copy the 32-bit word aligned and without any constant
        else if ( (inBitOff == 0) && (usageMask[wIdx] == (unsigned) -1) ) {
            out[wIdx] = in[inWordCnt];
            ++inWordCnt;
        }
        // Copy consecutive bits without any constant
        else if ( usageMask[wIdx] == (unsigned) -1 ) {
            out[wIdx] = (in[inWordCnt] >> inBitOff) | (in[inWordCnt+1] << (wordSize-inBitOff));
            ++inWordCnt;
        }
        else { // Bit by bit copy
            const uint use = usageMask[wIdx];
            const uint cst_out = cstData[wIdx] & ~use;
                  uint ext_out = 0;

            for ( size_t bIdx = 0; bIdx < wordSize; ++bIdx )
            {
                if( ((use >> bIdx) & 0x01) != 0 )
                {
                    ext_out |= ((in[inWordCnt] >> inBitOff) & 0x01) << bIdx;
                    ++inBitOff;
                    if ( inBitOff == wordSize ) {
                         inBitOff = 0;
                        ++inWordCnt;
                    }
                }
            }
            out[wIdx] = ext_out | cst_out;
        }
    }
    return (inBitOff > 0) ? inWordCnt+1 : inWordCnt;
}

