#include "q_incs.h"
#include "mk_comp_key_val.h"


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
//   int chunk_size = 64;
// #pragma omp parallel for schedule(static, chunk_size)
  for ( int i = 0; i < nV; i++ ) { 
    int offset = i*nR;  // every input produces nR outputs
    __VALTYPE__ val = in_measure_val[i];
    for ( int ridx = 0; ridx < nR; ridx++ ) {
      uint64_t comp_key = 0;
      int shift_by = 0;
      for ( int cidx = 0; cidx < nC; cidx++ ) { 
        uint32_t t_ridx_cidx = template[ridx][cidx];
        if ( t_ridx_cidx == 0 ) { 
          continue;
        }
        // Note the -1 because of Lua indexing versus C
        uint32_t key = ( t_ridx_cidx  << BITS_FOR_VAL ) | 
            in_dim_vals[t_ridx_cidx-1][i];
        comp_key = comp_key | ( key << shift_by);;
        out_key[offset + ridx] = comp_key;
        out_val[offset + ridx] = val;
        shift_by += incr_shift_by;
      }
    }
  }
BYE:
  return status;
}
