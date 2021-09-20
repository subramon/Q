#include "node_struct.h"

export void 
vctr_eval_isp(
    uniform int nH[], // [n] 
    uniform int nT[], // [n] 
    uniform float X[], 
    uniform int m, // number of features
    uniform int n, // number of data points to be classified
    uniform orig_node_t dt[],
    uniform int n_dt, // for debugging 
    uniform int depth // for debugging 
    )
{
  int status = 0;
  foreach ( i = 0 ... n ) { 
    int node_id = 0; // start at leaf 
    int num_searches = 0;
    for ( ; ; ) { 
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
      float fval = dt[node_id].fval;
      // float xval = X[fidx][i];
      int xidx = (fidx * n) + i;
      float xval = X[xidx];
      if ( xval <= fval ) {
        node_id = lchild_id;
      }
      else {
        node_id = rchild_id;
      }
    }
  }
  return;
}

