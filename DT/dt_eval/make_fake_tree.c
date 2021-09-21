#include "incs.h"
#include "node_struct.h"
#include "make_fake_tree.h"

// makes a fake decision tree of depth n 
int
make_fake_tree(
    int depth, // depth
    int num_features, // number of features
    orig_node_t **ptr_dt,
    int *ptr_n_dt
    )
{
  int status = 0;
  orig_node_t *dt = NULL;
  int num_frontier = 1;
  int n_dt = 0;
  for ( int d = 0; d < depth; d++ ) {
    n_dt += num_frontier;
    num_frontier *= 2;
  }
  dt = malloc(n_dt * sizeof(orig_node_t));
  return_if_malloc_failed(dt);
  memset(dt, 0, n_dt * sizeof(orig_node_t));
  // make fake tree
  dt[0].lchild_id = 1;
  dt[0].rchild_id = 2;
  for ( int i = 1; i < n_dt/2; i++ ) { // for all interior nodes
    dt[i].lchild_id = 2*i;
    dt[i].rchild_id = 2*i+1;
  }
  for ( int i = n_dt/2; i < n_dt; i++ ) { // for all interior nodes
    dt[i].lchild_id = dt[i].rchild_id = -1;
  }
  // quick check 
  int num_leaves = 0;
  for ( int i = 1; i < n_dt; i++ ) { 
    if ( ( dt[i].lchild_id < 0 ) ||  ( dt[i].rchild_id < 0 ) ) { 
      num_leaves++;
    }
    else {
      dt[i].fidx = random() % num_features;
      int r = random();
      r = r & 0x00FFFFFF;
      float range = 1 << 24;
      float rand_val = (float)r / range; 
      dt[i].fval = rand_val;
    }
  }
  if ( num_leaves != (n_dt/2) + 1 ) { go_BYE(-1); }


  *ptr_n_dt = n_dt;
  *ptr_dt = dt;
  
BYE:
  return status;
}
