
return require 'Q/UTILS/lua/code_gen' {
  declaration = [[
#include "q_incs.h"
int
${fn}(
double junk,
    const int ** const template, /* [nR][nC] */
    int nR,
    int nC,
    int nD,
    /* 0 <= template[i][j] < nD */
    const uint8_t ** const in_dim_vals, /* [nD][nV] */
    const ${VALTYPE} * const in_measure_val, /* [nV] */
    uint64_t * restrict out_key, /*  [nK] */ 
    ${VALTYPE} * restrict out_val, /*  [nK] */
    int nV,
    int nK
    );
]],
definition = [[
#include "_${fn}.h"

/* As an example, if we have 3 raw attributes with the 
 * first  one having 2 derived attributes, 
 * second one having 4 derived attributes, 
 * third  one having 3 derived attributes, 
 * Then, 
 * nC = 3
 * nD = 2 + 3 + 4 
 * nR = (2+1) * (3+1) * (4+1)
 * Recall +1 is for the don't care case.
 * It is responsiblity of caller to make sure that (nV * nR) <= nK
 * */
int
${fn}(
double junk,
    const int **const template, /* [nR][nC] */
    int nR, // number of output rows produced for each input row 
    int nC, // number of raw attributes 
    int nD, // number of derived attributes 
    /* 0 <= template[i][j] < nD */
    const uint8_t ** const in_dim_vals, /* [nD][nV] */
    const ${VALTYPE} * const in_measure_val, /* [nV] */
    uint64_t * restrict out_key, /*  [nK] */ 
    ${VALTYPE} * restrict out_val, /*  [nK] */
    int nV, // note that nV * nR <= nK
    int nK
    )
{
  int status = 0;
#define BITS_FOR_VAL 8 //  HARD CODED
#define BITS_FOR_KEY 8 //  HARD CODED
  int incr_shift_by = BITS_FOR_VAL + BITS_FOR_KEY;

  if ( ( nV*nR ) > nK )  { go_BYE(-1); }
  for ( int i = (nV*nR); i < nK; i++ ) { 
    out_key[i] = 0;
    out_val[i] = 0;
  }
  int chunk_size = 64;
#pragma omp parallel for schedule(static, chunk_size)
  for ( int i = 0; i < nV; i++ ) { 
    register int offset = i*nR; 
    register ${VALTYPE} val = in_measure_val[i];
    for ( int ridx = 0; ridx < nR; ridx++ ) {
      register uint64_t comp_key = 0;
      register int shift_by = 0;
      for ( int cidx = 0; cidx < nC; cidx++ ) { 
        register uint32_t t_ridx_cidx = template[ridx][cidx];
#ifdef DEBUG
        if  ( t_ridx_cidx >= nD ) { status = -1; continue; }
#endif
        register uint32_t key;
        if ( t_ridx_cidx == 0 ) {
          key = 0;
        }
        else {
          // Note the -1 because of Lua indexing versus C
          key = ( t_ridx_cidx  << BITS_FOR_VAL ) | 
            in_dim_vals[t_ridx_cidx-1][i];
        }
        comp_key = comp_key | ( key << shift_by);;
        out_key[offset + ridx] = comp_key;
        out_val[offset + ridx] = val;
        shift_by += incr_shift_by;
      }
    }
  }
  cBYE(status);
BYE:
  return status;
}
]]
}
