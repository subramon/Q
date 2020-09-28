#include "incs.h"
#include "check_tree.h"

void
static pr_tree(
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
    int n_tree
    )
{
  int status = 0;
  if ( tree[0].parent_id != -1 ) { go_BYE(-1); }
  for ( int i = 1; i < n_tree; i++ ) { 
    int n_T = tree[i].nT;
    int n_H = tree[i].nH;
    int lchild_id = tree[i].lchild_id;
    int rchild_id = tree[i].rchild_id;
    int parent_id = tree[i].parent_id;

    if ( parent_id < 0 ) { go_BYE(-1); }
    if ( lchild_id == 0 ) { go_BYE(-1); }
    if ( rchild_id == 0 ) { go_BYE(-1); }

    if ( ( lchild_id > 0 ) && ( parent_id >= lchild_id ) ) { go_BYE(-1); }
    if ( ( rchild_id > 0 ) && ( parent_id >= rchild_id ) ) { go_BYE(-1); }

    if ( ( rchild_id > 0 ) && ( lchild_id == rchild_id ) ) { go_BYE(-1); }

    if ( ( tree[parent_id].lchild_id != i ) && 
         ( tree[parent_id].rchild_id != i ) ) {
      go_BYE(-1);
    } }
BYE:
  if ( status < 0 ) { pr_tree(tree, n_tree); } 
  return status;
}
