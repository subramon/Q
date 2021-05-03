#ifndef __DT_TYPES
#define __DT_TYPES

typedef struct _data_t {
  uint32_t nI; // number of instances
  uint32_t nK; // number of features
  float **fval; // [nK][nI]
} data_t;

typedef struct _node_t { 
  int depth; 
  int lchild_id;
  int rchild_id;
  int parent_id;
  int fidx; // feature index
  float fval; // feature val
  // comparison is X[fidx][..] < fval 
  uint32_t nH;
  uint32_t nT;
  uint32_t Plb; // lower index into permutation array P
  uint32_t Pub; // upper index into permutation array P
} node_t;

typedef struct _dt_t { 
  node_t *nodes; // [num_nodes]
  uint32_t num_nodes; 
} tree_t;

typedef struct _comp_key_t { 
  uint32_t p;
  float fval;
} comp_key_t;
#endif
