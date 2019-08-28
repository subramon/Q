#include <math.h>
#include <stdio.h>
#include "poisson.h"

int 
poisson_1(
    float lambda,
    float *rnums,
    int n_rnums,
    int *ptr_ridx,
    int *ptr_num_steps
    )
{
  register double L = exp(-1.0*lambda);
  register int k = 0;
  register double p = 1;
  register int ridx = *ptr_ridx;
  register float *ptr_this_rnums = rnums + ridx;
  register float *ptr_last_rnums = rnums + n_rnums;
  register int num_steps = 0;
  do {
    k++;
    if ( ptr_this_rnums == ptr_last_rnums ) { ptr_this_rnums = rnums; }
    p = p * *ptr_this_rnums++;
    num_steps++;
  } while ( p > L );
  *ptr_ridx = ptr_this_rnums - rnums;
  *ptr_num_steps = num_steps;
  return k-1;
}

int 
poisson_2(
    float lambda,
    float *rnums,
    int n_rnums,
    int *ptr_ridx,
    int *ptr_num_steps
    )
{
  register int k = 0;
  register double p = 0;
  register int ridx = *ptr_ridx;
  register float *ptr_this_rnums = rnums + ridx;
  register float *ptr_last_rnums = rnums + n_rnums;
  register int num_steps = 0;
  do {
    k++;
    if ( ptr_this_rnums == ptr_last_rnums ) { ptr_this_rnums = rnums; }
    p += *ptr_this_rnums++;
    num_steps++;
  } while ( p < lambda );
  *ptr_ridx = ptr_this_rnums - rnums;
  *ptr_num_steps = num_steps;
  return k-1;
}

int 
poisson_3(
    float lambda,
    float *rnums,
    int n_rnums,
    int *ptr_ridx,
    int *ptr_num_steps
    )
{
  register int k = 0;
  register double p = 0;
  register int ridx = *ptr_ridx;
  register float *ptr_this_rnums = rnums + ridx;
  register float *ptr_last_rnums = rnums + n_rnums;
  register int num_steps = 0;
  do {
    k++;
    if ( ptr_this_rnums == ptr_last_rnums ) { ptr_this_rnums = rnums; }
    p += *ptr_this_rnums++;
    num_steps++;
  } while ( p < lambda );
  *ptr_ridx = ptr_this_rnums - rnums;
  *ptr_num_steps = num_steps;
  return k-1;
}
