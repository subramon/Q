
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "eval_metrics.h"
#include "eval_metrics_isp.h"
#include "get_time_usec.h"
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
  uint32_t nT; 
  uint32_t nH; 
  uint32_t loc;
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
  in_TL   = malloc(n * sizeof(uint32_t));
  in_TH   = malloc(n * sizeof(uint32_t));

  srand48(get_time_usec());
  for ( int i = 0; i < m; i++ ) { 
    x = drand48(); x -= 0.5;
    if ( ( x < -0.5 ) || ( x > 0.5 ) ) { go_BYE(-1); }
    uint32_t nT = l ( 1 + x );
    uint32_t nH = l = nT;
    for ( int j = 0; j < n; j++ ) { 
      in_nTL[j] = drand48() * l; 
      in_nTH[j] = l - in_nTL[j];
    }
    eval_metric_ispc(in_nTL, in_HL, nT, nH, metric1, n); 
    status = eval_metric(in_nTL, in_HL, nT, nH, metric2, n); 
    for ( int j = 0; j < n; j++ ) { 
      if ( metric1[i] < 0.0 ) { go_BYE(-1); } 
      if ( metric2[i] < 0.0 ) { go_BYE(-1); } 
      if ( metric1[i] > 0.5 ) { go_BYE(-1); } // TODO CHeck j
      if ( metric2[i] > 0.5 ) { go_BYE(-1); } // TODO CHeck j
      if ( ( fabs(metric1[j] - metric2[j]) / ( metric1[i] + metric2[j] ) )
          > 0.001 ) { 
      go_BYE(-1):
    }
  }
BYE:
  free_if_non_null(metric1); 
  free_if_non_null(metric2); 
  free_if_non_null(in_TL);
  free_if_non_null(in_TH);
  return status;
}
