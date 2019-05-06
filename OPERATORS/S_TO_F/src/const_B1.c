#include "const_B1.h"
#include "_rdtsc.h"

//START_FUNC_DECL
int
const_B1(
  uint64_t *X,
  uint64_t nX,
  int32_t *ptr_val,
  uint64_t dummy
  )
//STOP_FUNC_DECL
{
  int status = 0;
  if ( ptr_val == NULL ) { go_BYE(-1); }
  if ( X       == NULL ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }

  int val = *ptr_val;
  if ( ( val < 0 ) || ( val > 1 ) ) { go_BYE(-1); }
  uint64_t lval = 0;
  if ( val == 1 ) { 
    lval = ~lval;
  }


  uint64_t nXprime = nX / 64 ;
  if ( nXprime * 64 != nX )  { nXprime++; }
#define pragma omp parallel for
  for ( uint64_t i = 0; i < nXprime; i++ ) {
    X[i] = lval;
  }
  
BYE:
  return status;
}
