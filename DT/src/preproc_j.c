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
    uint32_t **ptr_to,
    uint32_t **ptr_from
   )
{
  int status = 0;
  uint32_t *Yj = NULL;
  uint32_t *to = NULL;
  uint32_t *from = NULL;
  comp_key_t *C = NULL;
  // allocate Y and idx 
  Yj  = malloc(n * sizeof(uint32_t));
  to  = malloc(n * sizeof(uint32_t));
  from  = malloc(n * sizeof(uint32_t));
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
  from[0] = C[0].idx;
  Yj[0] = yval | (((uint64_t)g[0]) << 31); 
  for ( uint32_t i = 1; i < n; i++ ) { 
    if ( C[i].xval != xval ) {
      xval = C[i].xval;
      yval++;
    }
    Yj[i] = yval | (((uint64_t)g[i]) << 31); 
    if ( C[i].idx >= n ){ go_BYE(-1); }
    from[i] = C[i].idx;
  }
  //--------------------------------------
  for ( uint32_t i = 0; i < n; i++ ) { 
    uint32_t pos = from[i];
    if ( pos >= n ) { go_BYE(-1); }
    to[pos] = i;
  }
  *ptr_Yj = Yj;
  *ptr_to = to;
  *ptr_from = from;
BYE:
  free_if_non_null(C);
  if ( status < 0 ) { 
    free_if_non_null(Yj);
    free_if_non_null(to);
    free_if_non_null(from);
  }
  return status;
}
