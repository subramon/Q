#include "incs.h"
#include "accumulate.h"
#include "read_config.h"

config_t  g_C; // configuration
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint64_t *Y = NULL;
  metrics_t Mj;
  // read configurations 
  status = read_config(&g_C, "");  cBYE(status);
  // create some bogus data
  uint32_t n = 1024;
  if ( argc == 2 ) { n = atoi(argv[1]); }
  uint32_t yval = 10; // some bogus *constant* value 
  Y = malloc(n * sizeof(uint64_t));
  uint32_t g = 1;
  for ( uint32_t i = 0; i < n; i++ ) { 
    Y[i] = yval;
    Y[i] = Y[i] | ( g << 31 );
    if ( g == 1 ) { g = 0; } else { g = 1; }
  }
  // set up metrics
  memset(&Mj, 0, sizeof(metrics_t));
  int bufsz = g_C.metrics_buffer_size;
  Mj.yval   = malloc(bufsz * sizeof(uint32_t));
  Mj.yidx   = malloc(bufsz * sizeof(uint32_t));
  Mj.nT     = malloc(bufsz * sizeof(uint32_t));
  Mj.nH     = malloc(bufsz * sizeof(uint32_t));
  Mj.metric = malloc(bufsz * sizeof(double));
  // -------------------
  uint32_t nbuf, lb;
  status = accumulate(Y, 0, n, 0, 0, &Mj, &nbuf, &lb); cBYE(status);
  if ( nbuf != 1 ) { go_BYE(-1); }
  if ( Mj.yval[0] != yval ) { go_BYE(-1); }
  if ( Mj.yidx[0] != n-1 ) { go_BYE(-1); }
  if ( Mj.nT[0] != 512 ) { go_BYE(-1); }
  if ( Mj.nH[0] != 512 ) { go_BYE(-1); }
  fprintf(stderr, "Completed test [%s] successfully\n", argv[0]);
BYE:
  free_if_non_null(Mj.yval);
  free_if_non_null(Mj.yidx);
  free_if_non_null(Mj.nT);
  free_if_non_null(Mj.nH);
  free_if_non_null(Mj.metric);
  return status;
}
