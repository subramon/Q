#include "incs.h"
#include "delete_point.h"

int
delete_point(
    float *point, 
    int label, 
    node_t *tree, 
    meta_t *meta, 
    bff_t *bff, 
    int num_nodes, 
    int num_interior_nodes, 
    int num_features, 
    int n_bff, 
    int *ptr_retrain_node_idx,  // output 
    bool *ptr_is_leaf // output 
    )
{
  int status =  0; 
  int node_idx = 0; // start from root
  for ( ; ; ) { 

  }
  // determine whether retrain node is a leaf or not 
  if ( tree[node_idx].feature_idx < 0 ) {
    *ptr_is_leaf = true; 
  }
  else
    *ptr_is_leaf = false; 
  }

BYE:
  return status;
}
