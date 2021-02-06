#include "incs.h"
#include "delete_point.h"

// determine whether retrain node is a leaf or not 
static bool
is_leaf(
    int node_idx,
    node_t *tree
    )
{
  if ( tree[node_idx].feature_idx < 0 ) {
    return true; 
  }
  else {
    return false; 
  }
}

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
  int curr_node_idx = 0; // start from root
  for ( ; ; ) {
    bool b_is_leaf = is_leaf(curr_node_idx, tree); 
    if ( b_is_leaf ) { break; } 
    // Now we know we are dealing with an interior node

    float best_gini = 1; // since gini can take on values in [0, 1]
    float best_threshold; 
    int best_feature_idx = -1; 

    int curr_feature_idx = tree[curr_node_idx].feature_idx;
    float curr_threshold = tree[curr_node_idx].threshold;

    int meta_offset = tree[curr_node_idx].meta_offset;
    // For each feature
    for ( int i = 0; i < num_features; i++ ) { 
      // For each threshold at this feature
      int lb = meta[meta_offset].start_feature[i];
      int ub = meta[meta_offset].stop_feature[i];
      for ( int j = lb; j < ub; j++ ) { 
        float t = bff[j].threshold; 
        int l0  = bff[j].count_L0; 
        int l1  = bff[j].count_L1; 
        float gini; 
        // re-compute gini 
        if ( gini < best_gini ) { 
          best_gini = gini; 
          best_feature_idx = i; 
          best_threshold = t;
        }
      }
    }
    // Decide whether to retrain current node 
    if ( ( ( best_feature_idx != curr_feature_idx ) ||
          ( best_threshold != curr_threshold ) )  &&
        (  1 == 1 ) ) { 
      break; 
    }
    // Decide whether to go left or right 
    float point_val = point[curr_feature_idx];
    if ( point_val < curr_threshold ) { // go left 
      curr_node_idx = tree[curr_node_idx].lchild_idx;
    }
    else { // go right 
      curr_node_idx = tree[curr_node_idx].rchild_idx;
    }
    if ( curr_node_idx < 0 ) { go_BYE(-1); } // TODO Think about this 
  }
  *ptr_is_leaf = is_leaf(curr_node_idx, tree); 
  *ptr_retrain_node_idx = curr_node_idx;
BYE:
  return status;
}
