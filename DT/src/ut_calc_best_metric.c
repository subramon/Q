
#include "incs.h"
#include "calc_best_metric.h"
#include "calc_best_metric_isp.h"
#include "get_time_usec.h"
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  metrics_t M;
  double *metrics; 
  uint32_t loc1, loc2;
  int m = 100; // number of trials 
  int n = 100; // size of buffer
  if ( argc >= 2 ) { 
    n = atoi(argv[1]);
  }
  if ( n <= 0 ) { go_BYE(-1); } 
  if ( argc >= 3 ) { 
    m = atoi(argv[2]);
  }
  if ( m <= 0 ) { go_BYE(-1); } 

  metrics = malloc(n * sizeof(double));
  srand48(get_time_usec());
  M.metric = metrics;
  for ( int i = 0; i < m; i++ ) { 
    for ( int j = 0; j < n; j++ ) { 
      metrics[j] = drand48();
    }
    status = calc_best_metric(&M, n, &loc1); cBYE(status);
    calc_best_metric_isp(metrics, n, &loc2);  
    if ( loc1 != loc2 ) { 
      go_BYE(-1);
    }
  }
  fprintf(stderr, "Completed test [%s] successfully\n", argv[0]);
BYE:
  free_if_non_null(metrics);
  return status;
}
