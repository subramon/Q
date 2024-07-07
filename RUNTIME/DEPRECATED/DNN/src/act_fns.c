#include "q_incs.h"
#include "dnn_types.h"
#include "act_fns.h"

float 
sigmoid(
    float *x,
    int n,
    float *y
    )
{
  int status = 0;
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = -1 * x[i];
#ifdef COUNT
    num_f_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = exp(y[i]);
#ifdef COUNT
    num_f_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = 1 + y[i];
#ifdef COUNT
    num_f_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = 1.0 / y[i];
#ifdef COUNT
    num_f_flops += 1;
#endif
  }
  return status;
}

float
sigmoid_bak(
    float *z,
    float *da,
    int n,
    float *dz
    )
{
  int status = 0;
  // TODO Don't malloc s here
  float *y;
  y = malloc(n * sizeof(float));
  return_if_malloc_failed(y);

#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = -1 * z[i];
#ifdef COUNT
    num_b_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = exp(y[i]);
#ifdef COUNT
    num_b_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = 1 + y[i];
#ifdef COUNT
    num_b_flops += 1;
#endif
  }
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) {
    y[i] = 1.0 / y[i];
#ifdef COUNT
    num_b_flops += 1;
#endif
  }

  /*
  status = sigmoid(z, n, s);
  cBYE(status);
  */

#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { 
    dz[i] = ( da[i] * y[i] * ( 1 - y[i] ) );
#ifdef COUNT
    num_b_flops += 3;
#endif
  }
BYE:
  free_if_non_null(y);
  return status;
}

float 
identity(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
#pragma omp simd
  for ( int  i = 0; i < n; i++ ) { y[i] = x[i]; }
  return status;
}

float 
relu(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
  for ( int  i = 0; i < n; i++ ) { 
    if ( x[i] < 0 ) { 
      y[i] = 0;
    }
    else {
      y[i] = x[i]; 
    }
  }
  return status;
}
// https://stackoverflow.com/questions/34968722/how-to-implement-the-softmax-function-in-python
float 
softmax(
    float *x, 
    int n, 
    float *y
    ) 
{ 
  int status = 0;
#pragma omp simd 
  for ( int  i = 0; i < n; i++ ) { y[i] = exp(x[i]); }
  float sum = 0;
#pragma omp simd reduction(+:sum)
  for ( int  i = 0; i < n; i++ ) { 
    sum += y[i];
  }
#pragma omp simd 
  for ( int  i = 0; i < n; i++ ) { y[i] = y[i] / sum; }
  return status;
}

float
relu_bak(
    float *z,
    float *da,
    int n,
    float *dz
    )
{
  int status = 0;

  for ( int  i = 0; i < n; i++ ) { 
    // TODO Use terary operatorz[i] = z[i] < 0 ? 0 : z[i];
    if ( z[i] < 0 ) { 
      dz[i] = 0;
    }
    else { 
      dz[i] = da[i];
    }
  }
BYE:
  return status;
}

