#include "q_incs.h"
#include "approx_quantile.h"

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_RESET   "\x1b[0m"

int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int nQ = 10;
  uint64_t n = 1048576;
  approx_quantile_state_t state;
  double eps = 0.1;
  int error_code;

  for ( int nQ = 10; nQ >= 1; nQ -= 2 ) { 
    int m = n;
    for ( int iter = 0; iter < 10; iter++ ) { 
      double val = 0;
      status = approx_quantile_make( nQ, n, &state, eps, &error_code);
      for ( int i = 0; i < 1048576; i++ ) { 
        status = approx_quantile_add(&state, val); cBYE(status);
        val++;
        if ( val == m ) { val = 0; }
      }
      status = approx_quantile_read(&state); cBYE(status);
      double x = m / (nQ+1);
      for ( int i = 0; i < state.num_quantiles; i++ ) { 
        fprintf(stdout, "%4d\t%d\t%lf\t%lf\n", 
            m, i, (i+1)*x, state.quantiles[i]);
      }
      status = approx_quantile_free(&state); cBYE(status);
      m = m / 2;
    }
  }
BYE:
  return status;
}
