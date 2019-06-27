#include "q_incs.h"

#define __VALTYPE__ float
extern int
mk_comp_key_val(
    int **template, /* [nR][nC] */
    int nR,
    int nC,
    /* 0 <= template[i][j] < nD */
    uint8_t **in_dim_vals, /* [nD][nV] */
    __VALTYPE__ *in_measure_val, /* [nV] */
    uint64_t *out_key, /*  [nK] */ 
    __VALTYPE__ *out_val, /*  [nK] */
    int nV,
    int nK
    );
