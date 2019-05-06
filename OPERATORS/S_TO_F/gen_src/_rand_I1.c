
#include "_rand_I1.h"

 /* no identitu function needed */  

//START_FUNC_DECL
int
rand_I1(
  int8_t *X,
  uint64_t nX,
  RAND_I1_REC_TYPE *ptr_rand_info,
  uint64_t idx
  )
//STOP_FUNC_DECL
{
  int status = 0;

  uint64_t seed      = ptr_rand_info->seed;
  register double lb = ptr_rand_info->lb;
  double ub          = ptr_rand_info->ub;
  if ( ub <= lb ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  if ( idx == 0 ) { //seed has not yet been set
    if ( seed <= 0 ) {
     seed = RDTSC();
    }
    srand48_r(seed, &(ptr_rand_info->buffer));
  }
  register double range = ub - lb;
// TODO P2: Consider parallelizing this loop
  for ( uint64_t i = 0; i < nX; i++ ) { 
    double x;
    drand48_r(&(ptr_rand_info->buffer), &x);
    X[i] = (int8_t) floor ((lb + (x * range)));
  }
BYE:
  return status;
}

   
