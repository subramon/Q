#ifndef __AVX_H_
#define __AVX_H_
#include "q_incs.h"
extern int
va_times_sb_plus_vc(
    float *A,
    float sB,
    float *C,
    float *D,
    int32_t nI
    );

extern int
va_dot_vb(
    float *A,
    float *B,
    float *C,
    int32_t nI
    );
#endif
