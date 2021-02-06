#include "incs.h"
#include "chck_tree.h"

int
chck_tree(
    const node_t * const tree,
    int num_features, 
    int num_nodes
    )
{
  int status = 0;

  if ( num_nodes <= 0 ) { go_BYE(-1); }
  if ( num_features <= 0 ) { go_BYE(-1); }

  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( tree[i].feature_idx >= num_features ) { go_BYE(-1); }
    if ( ( tree[i].lchild_idx < 0 ) && 
         ( tree[i].rchild_idx < 0 ) ) { /* leaf */
      if ( tree[i].feature_idx >= 0 ) { go_BYE(-1); }
    }
    else {
      if ( tree[i].feature_idx < 0 ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}

int
num_non_leaf(
    const node_t * const tree,
    int num_nodes
    )
{
  int num_leaf = 0; 

  for ( int i = 0; i < num_nodes; i++ ) { 
    if ( ( tree[i].lchild_idx < 0 ) && 
         ( tree[i].rchild_idx < 0 ) ) { /* leaf */
      num_leaf++;
    }
  }
  int num_non_leaf = num_nodes - num_leaf;
  if ( num_non_leaf == 0 ) { WHEREAMI; return -1; } 
  return num_non_leaf;
}
