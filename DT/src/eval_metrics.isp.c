// TODO Convert to ispc 
#include "incs.h"

export int
eval_metrics(
    metrics_t M[BUFSZ],
    uint32_t nbuf
    )
{
  int status = 0;
  if ( nbuf > BUFSZ ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < nbuf; i++ ) { 
    M[i].metric = (random() % 1000000 )  / 1000000.0; // TODO
  }
BYE:
  return status;
}
