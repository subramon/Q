#ifndef __NODE_STRUCT_H
#define __NODE_STRUCT_H
// orig_node_t is minimal node with no encoding of values
typedef struct _orig_node_t { 
  int lchild_id;
  int rchild_id;
  int fidx; // feature index: which feature for this decision 
  float fval; // feature value: which value to be compared against
  int nH;
  int nT;
} orig_node_t;
#endif // __NODE_STRUCT_H
