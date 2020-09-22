#include "incs.h"
#include "eval_metrics.h"
int
eval_metrics(
    metrics_t M[BUFSZ],
    uint32_t nbuf
    )
{
  int status = 0;
  for ( int i = 0; i < nbuf; i++ ) { 
    M[i].metric = (random() % 1000000 )  / 1000000.0; // TODO
  }
BYE:
  return status;
}
