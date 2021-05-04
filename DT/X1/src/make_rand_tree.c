#include "incs.h"
#include "consts.h"
#include "types.h"
#include "make_rand_tree.h"

int
make_rand_tree(
    tree_t *T,
    int num_features
    )
{
  int status = 0;
  memset(T, 0, sizeof(tree_t));
  int num_levels = 7; // TODO undo hard code 
  int num_nodes = 1; int num_at_level = 1;
  for ( int i = 0; i < num_levels; i++ ) { 
    num_at_level *= 2;
    num_nodes += num_at_level;
  }
  T->num_nodes = num_nodes;
  printf("num_nodes = %d \n", num_nodes);


  T->nodes = malloc(T->num_nodes * sizeof(node_t));
  return_if_malloc_failed(T->nodes);
  memset(T->nodes, 0,  T->num_nodes * sizeof(node_t));

  T->nodes[0].parent_id = -1; // root has no parent 
  for ( uint32_t i = 0; i < T->num_nodes; i++ ) {
    uint32_t lid = 2*i + 1;
    uint32_t rid = lid + 1;
    if ( ( lid >= T->num_nodes) || ( rid >= T->num_nodes) ) {
      // this is a leaf
      T->nodes[i].lchild_id = -1;
      T->nodes[i].rchild_id = -1;
      T->nodes[i].fidx       = -1;
    }
    else {
      T->nodes[i].fidx = random()  % num_features;
      T->nodes[i].fval = ( random() % MAX_VAL );
      T->nodes[i].lchild_id = lid;
      T->nodes[i].rchild_id = rid;
    }
    if ( i > 0 ) { 
      T->nodes[i].parent_id  = i / 2;
    }
  }
BYE:
  return status;
}

int
free_rand_tree(
    tree_t *T
    )
{
  int status = 0;
  if ( T == NULL ) { return status; }
  free_if_non_null(T->nodes);
  memset(T, 0, sizeof(tree_t));
BYE:
  return status;
}
