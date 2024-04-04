#include "q_incs.h"
#include "q_macros.h"

int
pack(
    char **in_vals,  // [n_vals][n]
    uint32_t n_vals,
    uint32_t n,
    uint32_t *width, // [n_vals]
    uint64_t *out_val // [n]
    )
{
  int status = 0;
  uint32_t *shift_by = NULL;

  uint32_t l_shift_by = 0;
  for ( uint32_t i = n_vals; i >= 0; i-- ) { 
    shift_by[i] = l_shift_by;
    l_shift_by += width[i];
  }
  // Initialize out_val to 0 
#pragma omp parallel for 
  for ( uint32_t j = 0; j < n; j++ ) { 
    out_val[j] = 0;
  }
  //-----------------------------------------------
  for ( uint32_t i = 0; i < n_vals; i++ ) { 
#pragma omp parallel for 
    for ( uint32_t j = 0; j < n; j++ ) { 
      uint64_t tmp;
      switch ( width[i] ) { 
        case 1 : tmp = ((uint8_t *)in_vals[i])[j]; break; 
        case 2 : tmp = ((uint8_t *)in_vals[i])[j]; break; 
        case 4 : tmp = ((uint8_t *)in_vals[i])[j]; break; 
        case 8 : tmp = ((uint8_t *)in_vals[i])[j]; break; 
        default : status = -1; break; 
      }
      out_val[j] |= tmp << shift_by[i];
    }
  }
    
BYE:
  free_if_non_null(shift_by);
  return status;
}

