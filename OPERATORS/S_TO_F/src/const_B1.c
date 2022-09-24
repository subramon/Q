#include "const_B1.h"

//START_FUNC_DECL
int
const_B1(
  uint64_t *X,
  uint64_t nX,
  CONST_BL_REC_TYPE *ptr_arg,
  uint64_t dummy // not used but for consistency with others
  )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_arg == NULL ) { go_BYE(-1); }
  if ( X       == NULL ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }

  bool val = ptr_arg->val;
  uint64_t lval = 0;
  if ( val == true ) { 
    lval = ~lval;
  }

  uint64_t nXprime = nX / 64 ;
#define pragma omp parallel for
  for ( uint64_t i = 0; i < nXprime; i++ ) {
    X[i] = lval;
  }
  // handle overflow if any
  if ( ( nXprime * 64 ) != nX ) {
    // Now set nX-Xprime least significant bits to 1 
    lval = 0; 
    for ( unsigned int k = 0; k < nX - nXprime; k++  ) { 
      lval = ( lval << 1 ) | 1 ;
    }
    X[nXprime] = 0; // set to 0
    X[nXprime] = lval;
  }
BYE:
  return status;
}
