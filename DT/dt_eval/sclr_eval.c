#include "incs.h"
#include "node_struct.h"
#include "sclr_eval.h"

int
sclr_eval(
    uint32_t *nH, // [n] 
    uint32_t *nT, // [n] 
    float *X, 
    int m, // number of features
    int n, // number of data points to be classified
    const orig_node_t * const dt,
    int n_dt, // for debugging 
    int depth // for debugging 
    )
{
  int status = 0;
  for ( int i = 0; i < n; i++ ) { 
    int node_id = 0; // start at leaf 
    int num_searches = 0;
    for ( ; ; ) { 
#ifdef DEBUG
      if ( ( node_id < 0 ) || ( node_id >= n_dt ) ) { go_BYE(-1); }
#endif
      int lchild_id = dt[node_id].lchild_id;
      int rchild_id = dt[node_id].rchild_id;
      // terminate if either left or right child is null
      if ( ( lchild_id < 0 ) || ( rchild_id < 0 ) ) { 
        nH[i] = dt[node_id].nH;
        nT[i] = dt[node_id].nT;
        break;
      }
      // get feature
      int fidx = dt[node_id].fidx;
#ifdef DEBUG
      num_searches++;
      if ( ( fidx < 0 ) || ( fidx >= m ) ) { go_BYE(-1); }
#endif
      float fval = dt[node_id].fval;
      int xidx = (fidx * n) + i;
      float xval = X[xidx];
#ifdef DEBUG
      if ( ( xidx < 0 ) || ( xidx > (m*n) ) ) { go_BYE(-1); }
#endif
      // float xval = X[fidx][i];
      if ( xval <= fval ) {
        node_id = lchild_id;
      }
      else {
        node_id = rchild_id;
      }
    }
#ifdef DEBUG
    // TODO P2 Should this be > or >= ?
    if ( num_searches > depth ) { 
      printf("num_searches = %d \n", num_searches); go_BYE(-1); 
    }
#endif
  }

BYE:
  return status;
}

