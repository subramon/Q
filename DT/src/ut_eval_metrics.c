
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "incs.h"
#include "eval_metrics.h"
#include "eval_metrics_isp.h"
#include "get_time_usec.h"
config_t g_C;

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  double *metric1; // [n] 
  double *metric2; // [n] 
  uint32_t *in_nTL; // [n] 
  uint32_t *in_nHL; // [n] 
  int m = 100; // number of trials 
  int n = 100; // size of buffer
  int l = 100; // nT + nH

  if ( argc >= 2 ) { 
    n = atoi(argv[1]);
  }
  if ( n <= 0 ) { go_BYE(-1); } 
  //--------------------------------
  if ( argc >= 3 ) { 
    m = atoi(argv[2]);
  }
  if ( m <= 0 ) { go_BYE(-1); } 
  //--------------------------------
  if ( argc >= 4 ) { 
    l = atoi(argv[3]);
  }
  if ( l <= 0 ) { go_BYE(-1); } 
  //--------------------------------
  metric1 = malloc(n * sizeof(double));
  metric2 = malloc(n * sizeof(double));
  in_nTL   = malloc(n * sizeof(uint32_t));
  in_nHL   = malloc(n * sizeof(uint32_t));

  g_C.metrics_buffer_size = n;

  srand48(get_time_usec());
  for ( int i = 0; i < m; i++ ) { 
    double x = drand48(); x -= 0.5;
    if ( ( x < -0.5 ) || ( x > 0.5 ) ) { go_BYE(-1); }
    uint32_t nT = l * ( 1 + x );
    uint32_t nH = l = nT;
    for ( int j = 0; j < n; j++ ) { 
      in_nTL[j] = drand48() * l; 
      in_nHL[j] = l - in_nTL[j];
    }
    eval_metrics_isp(in_nTL, in_nHL, nT, nH, metric1, n); 
    status = eval_metrics(in_nTL, in_nHL, nT, nH, metric2, n); 
    for ( int j = 0; j < n; j++ ) { 
      /*
      if ( metric1[i] < 0.0 ) { go_BYE(-1); } // TODO CHECK 
      if ( metric2[i] < 0.0 ) { go_BYE(-1); } // TODO CHECK 
      */
      if ( metric1[i] > 0.5 ) { go_BYE(-1); } // TODO CHeck j
      if ( metric2[i] > 0.5 ) { go_BYE(-1); } // TODO CHeck j
      if ( ( fabs(metric1[j] - metric2[j]) / ( metric1[i] + metric2[j] ) )
          > 0.001 ) { 
        go_BYE(-1);
      }
    }
  }
  fprintf(stderr, "Completed test [%s] successfully\n", argv[0]);
BYE:
  free_if_non_null(metric1); 
  free_if_non_null(metric2); 
  free_if_non_null(in_nTL);
  free_if_non_null(in_nHL);
  return status;
}
