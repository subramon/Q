#ifndef __DT_TYPES
#define __DT_TYPES

typedef struct _node_t { 
  int lchild_idx; // [num_nodes] 
  int rchild_idx; // [num_nodes] 
  int feature_idx; 
  float threshold; 
  int meta_offset;
} node_t;

typedef struct _meta_t { 
  int node_idx; 
  int *start_feature; // [num_features]
  int *stop_feature; //  [num_features]
  int count0;
  int count1;
} meta_t;

typedef struct _bff_t { 
  float threshold; 
  int count_L0; 
  int count_L1; 
} bff_t;

 
#endif
