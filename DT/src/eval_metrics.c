// TODO Convert to ispc 
#include "incs.h"
#include "eval_metrics.h"
int
eval_metrics(
    double M_metric[BUFSZ],
    uint32_t nbuf
    )
{
  int status = 0;
  if ( nbuf > BUFSZ ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < nbuf; i++ ) { 
    M_metric[i] = (random() % 1000000 )  / 1000000.0; // TODO
  }
BYE:
  return status;
}
