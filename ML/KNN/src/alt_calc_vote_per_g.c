#include <math.h>
#include "q_incs.h"
#include "calc_vote_per_g.h"

#define OPT_A
double
safe_exp(
    double x
    )
{
  if ( x > 308 ) {
    return DBL_MAX;
  }
  else {
    return exp(x);
  }
}

int 
alt_calc_vote_per_g(
    float **d_train, /* [m][n_train] */
    int m,
    int n_train,
    float *alpha, /* [m] */
    float **d_test, /* [m][n_test] */
    int n_test,
    float *o_test /* [n_test] */
    )
{
  int status = 0;
  float avg_dist[10]; // proxy for alpha
  float min_vote = FLT_MAX;
  float max_vote = -1.0 * FLT_MAX;
  for ( int j = 0; j < n_test; j++ ) { 
    o_test[j] = 0;
  }
  // using avg
  avg_dist[0] = 1.776920;
  avg_dist[1] = 2.032977;
  avg_dist[2] = 1.661558;
  avg_dist[3] = 1.892051;
  avg_dist[4] = 1.700003;
  // using 0.95
  avg_dist[0] = 6.92;
  avg_dist[1] = 6.41;
  avg_dist[2] = 7.55;
  avg_dist[3] = 10.326;
  avg_dist[4] = 7.587;

  float exponent = 4.0; // TODO FIX P1
  float scale = 1;
  for ( int j = 0; j < n_test; j++ ) { 
    for ( int k = 0; k < n_train; k++ ) { 
      float vote_k;
      float sum = 0;
      for ( int i = 0; i < m; i++ ) { 
        float x3;
        float test_val = d_test[i][j];
        float train_val = d_train[i][k];
        float x1 = test_val - train_val;
        float x2 = x1 * x1;
#ifdef OPT_A
        x3 = x2;
#else
        if ( x2 > avg_dist[i] ) { 
          x3 = 0; 
        }
        else {
          x3 = 1 - (x2 / avg_dist[i]);
        }
#endif
        sum += x3;
      }
#ifdef OPT_A
      if ( exponent != 1 ) { sum = pow(sum, exponent); }
      vote_k = 1.0 / (1.0 + sum);
#else
      vote_k = sum;
#endif

      min_vote = mcr_min(min_vote, vote_k);
      max_vote = mcr_max(min_vote, vote_k);
      o_test[j] += vote_k;
    }
  }
  fprintf(stderr, "min/max vote = %f, %f \n", min_vote, max_vote);
BYE:
  return status;
}
