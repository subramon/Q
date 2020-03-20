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

  cBYE(status);
  for ( int denom = 1; denom <= 1024; denom *= 2 ) { 
    status = approx_quantile_make( nQ, n, &state, eps, &error_code);
    for ( int i = 0; i < 1048576; i++ ) { 
      status = approx_quantile_add(&state, (double)i); cBYE(status);
    }
    status = approx_quantile_final(&state); cBYE(status);
    for ( int i = 0; i < state.nQ; i++ ) { 
      fprintf(stdout, "%4d:%d:%ld\n", denom, i, state.quantiles[i]);
    }
    status = approx_quantile_free(&state); cBYE(status);
  }
BYE:
  return status;
