#include "incs.h"
#include "delete_point.h"

// determine whether retrain node is a leaf or not 
static bool
is_leaf(
    int node_idx,
    node_t *tree
    )
{
  if ( ( tree[node_idx].feature_idx < 0 ) 
    && ( tree[node_idx].threshold < 0 ) ) {
    return true; 
  }
  else {
    return false; 
  }
}

static int
calc_gini(
    int L0,
    int L1,
    int count0,
    int count1,
    int f,
    float t,
    int y,
    float* point
    )
{
  int R0 = count0 - L0;
  int R1 = count1 - L1;
  if ( point[f] < t ) { //going left
    if ( y == 0 ) {
      L0 -= 1;
    } else {
      L1 -= 1;
    }
  } else { //going right
    if ( y == 0 ) {
      R0 -= 1;
    } else {
      R1 -= 1;
    }
  }
  int N = L0 + L1 + R0 + R1;
  int NL = L0 + L1;
  int NR = R0 + R1;
  float giniL = 0;
  float giniR = 0;
  if ( NL == 0 ) {
    giniL = 0;
  } else {
    float p0 = ( (float)L0 ) / ( (float)NL );
    giniL = 1 - p0*p0 - (1-p0)*(1-p0);
  }
  if ( NR == 0 ) {
    giniR = 0;
  } else {
    float p0 = ( (float)R0 ) / ( (float)NR );
    giniR = 1 - p0*p0 - (1-p0)*(1-p0);
  }
  return ( (float)NL / (float)N )*giniL + ( (float)NR / (float)N)*giniR;
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
  int parent_of_curr = -1;
  int curr_node_idx = 0; // start from root
  for ( ; ; ) {
    printf("curr node is: %d\n", curr_node_idx);
    bool b_is_leaf = is_leaf(curr_node_idx, tree); 
    if ( b_is_leaf ) { 
      printf("hit leaf, no retraining required\n");
      printf("parent info:\n");
      printf("count0 = %d\n", meta[tree[parent_of_curr].meta_offset].count0);
      printf("count1 = %d\n", meta[tree[parent_of_curr].meta_offset].count1);
      break; 
    } 
    // Now we know we are dealing with an interior node

    float best_gini = 1; // since gini can take on values in [0, 1]
    float best_threshold; 
    int best_feature_idx = -1; 

    int curr_feature_idx = tree[curr_node_idx].feature_idx;
    float curr_threshold = tree[curr_node_idx].threshold;

    int meta_offset = tree[curr_node_idx].meta_offset;
    float gini_of_original = -1;
    // For each feature
    for ( int i = 0; i < num_features; i++ ) { 
      // For each threshold at this feature
      int lb = meta[meta_offset].start_feature[i];
      int ub = meta[meta_offset].stop_feature[i];
      int count0 = meta[meta_offset].count0;
      int count1 = meta[meta_offset].count1;
      for ( int j = lb; j < ub; j++ ) { 
        float t = bff[j].threshold; 
        int L0  = bff[j].count_L0; 
        int L1  = bff[j].count_L1; 
        float gini = calc_gini(L0, L1, count0, count1, i, t, label, point); 
        // re-compute gini 
        if ( gini < best_gini ) { 
          best_gini = gini;
          best_feature_idx = i; 
          best_threshold = t;
        }
        if ( ( i == curr_feature_idx ) && ( t == curr_threshold ) ) {
          gini_of_original = gini;
        }
      }
    }

    if ( gini_of_original < 0 ) { go_BYE(-1); }

    // Decide whether to retrain current node 
    if ( ( ( best_feature_idx != curr_feature_idx ) ||
          ( best_threshold != curr_threshold ) )  &&
        (  gini_of_original != best_gini ) ) { 
      break; 
    }
    // Decide whether to go left or right 
    parent_of_curr = curr_node_idx;
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
