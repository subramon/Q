#include "incs.h"
#include "preproc_j.h"

typedef struct _comp_key_t { 
  float xval;
  uint32_t idx;
  uint8_t g;
} comp_key_t;

static int
sortfn(
    const void *p1, 
    const void *p2
    )
{
  const comp_key_t *r1 = (const comp_key_t *)p1;
  const comp_key_t *r2 = (const comp_key_t *)p2;
  if ( r1->xval < r2->xval ) { 
    return -1;
  }
  else  {
    return 1;
  }
}

int 
preproc_j(
    float *Xj, /* [m][n] */
    uint32_t n,
    uint8_t *g,
    uint32_t **ptr_Yj,
    uint32_t **ptr_to
   )
{
  int status = 0;
  uint32_t *Yj = NULL;
  uint32_t *to = NULL;
  comp_key_t *C = NULL;
  // allocate Y and idx 
  Yj  = malloc(n * sizeof(uint32_t));
  to  = malloc(n * sizeof(uint32_t));
  C   = malloc(n * sizeof(comp_key_t));
  for ( uint32_t i = 0; i < n; i++ ) { 
    C[i].idx  = i;
    C[i].g    = g[i];
    C[i].xval = Xj[i];
  }
  // sort X, idx, g
  qsort(C, n, sizeof(comp_key_t), sortfn);
  // create Y 
  float xval = C[0].xval;
  uint32_t yval = 1;
  to[0] = C[0].idx;
  Yj[0] = yval | (((uint64_t)g[0]) << 31); 
  for ( uint32_t i = 1; i < n; i++ ) { 
    if ( C[i].xval != xval ) {
      xval = C[i].xval;
      yval++;
    }
    Yj[i] = yval | (((uint64_t)g[i]) << 31); 
    to[i] = C[i].idx;
  }
  *ptr_Yj = Yj;
  *ptr_to = to;
BYE:
  free_if_non_null(C);
  return status;
}
