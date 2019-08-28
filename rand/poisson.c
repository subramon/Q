#include <math.h>
#include <stdio.h>
#include "poisson.h"
/* Version 1 
int 
poisson(
    float lambda,
    float *rnums,
    int n_rnums,
    int *ptr_ridx
    )
{
  register double L = exp(-1.0*lambda);
  register int k = 0;
  register double p = 1;
  register int ridx = *ptr_ridx;
  register float *ptr_this_rnums = rnums + ridx;
  register float *ptr_last_rnums = rnums + n_rnums;
  do {
    k++;
    if ( ptr_this_rnums == ptr_last_rnums ) { ptr_this_rnums = rnums; }
    p = p * *ptr_this_rnums++;
  } while ( p > L );
  *ptr_ridx = ptr_this_rnums - rnums;
  return k-1;
}
*/
int 
poisson(
    float lambda,
    float *rnums,
    int n_rnums,
    int *ptr_ridx
    )
{
  register int k = 0;
  register double p = 0;
  register int ridx = *ptr_ridx;
  register float *ptr_this_rnums = rnums + ridx;
  register float *ptr_last_rnums = rnums + n_rnums;
  do {
    k++;
    if ( ptr_this_rnums == ptr_last_rnums ) { ptr_this_rnums = rnums; }
    p += *ptr_this_rnums++;
  } while ( p < lambda );
  *ptr_ridx = ptr_this_rnums - rnums;
  return k-1;
}
