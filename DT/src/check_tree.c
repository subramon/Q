#include "incs.h"
#include "check_tree.h"
#ifdef SEQUENTIAL
extern uint64_t g_num_swaps;
#endif
extern config_t g_C;

static void
pr_tree(
    node_t *tree,
    int n_tree
    )
{
  fprintf(stdout, "id, p, l, r,nT,nH\n");
  for ( int i = 0; i < n_tree; i++ ) { 
    fprintf(stdout, "%2d,%2d,%2d,%2d,%2d,%2d\n",
        i, tree[i].parent_id, tree[i].lchild_id, tree[i].rchild_id, 
        tree[i].nT, tree[i].nH);
  }
}

int 
check_tree(
    node_t *tree,
    int n_tree,
    int m
    )
{
  int status = 0;
  uint64_t exp_num_swaps = 0;

  int num_leaves = 0, num_interior = 0;
  if ( tree[0].parent_id != -1 ) { go_BYE(-1); }
  for ( int i = 0; i < n_tree; i++ ) { 
    int depth = tree[i].depth;
    int n_T = tree[i].nT;
    int n_H = tree[i].nH;
    int lchild_id = tree[i].lchild_id;
    int rchild_id = tree[i].rchild_id;
    int parent_id = tree[i].parent_id;

    if ( ( depth < 0 ) || ( depth > g_C.max_depth ) ) {
      go_BYE(-1);
    }
    if ( ( lchild_id < 0 ) && ( rchild_id < 0 ) ) { 
      num_leaves++;
    }
    else {
      num_interior++;
      exp_num_swaps += ( (n_T + n_H) * m);
    }
    if ( i == 0 ) { // Location 0 reserved for root.
      if ( parent_id != -1 ) { go_BYE(-1); }
    }
    else {
      if ( parent_id < 0 ) { go_BYE(-1); }
    }
    if ( lchild_id == 0 ) { go_BYE(-1); }
    if ( rchild_id == 0 ) { go_BYE(-1); }

    // If there is a left child, then its index must be > parent index
    if ( ( lchild_id > 0 ) && ( parent_id >= lchild_id ) ) { go_BYE(-1); }
    // If there is a right child, then its index must be > parent index
    if ( ( rchild_id > 0 ) && ( parent_id >= rchild_id ) ) { go_BYE(-1); }

    // If there is a right child, then it can't be same as left child
    if ( ( rchild_id > 0 ) && ( lchild_id == rchild_id ) ) { go_BYE(-1); }

    // If not root, I must be left child of parent or right child of parent 
    if ( i > 0 ) { 
      if ( ( tree[parent_id].lchild_id != i ) && 
          ( tree[parent_id].rchild_id != i ) ) {
        go_BYE(-1);
      } 
      if ( depth <= 0 ) { go_BYE(-1); }
      int parent_depth = tree[parent_id].depth;
      if ( depth != ( parent_depth + 1 ) ) { go_BYE(-1); } 
    }
    else {
      if ( depth != 0 ) { go_BYE(-1); }
    }
  }
  if ( ( num_leaves + num_interior ) != n_tree ) {
    go_BYE(-1);
  }
#ifdef SEQUENTIAL
  if ( exp_num_swaps != g_num_swaps ) { 
    go_BYE(-1);
  }
  // printf("n/swaps = %d,%d \n", n_tree, g_num_swaps);
#endif
BYE:
  if ( status < 0 ) { pr_tree(tree, n_tree); } 
  return status;
}
