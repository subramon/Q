#include "incs.h"
#include "check.h"
#include "check_tree.h"
#include "preproc_j.h"
#include "reorder.h"
#include "search.h"
#include "split.h"

extern node_t *g_tree; // this is where the decision tree is created
extern int g_n_tree;
extern int g_sz_tree;
extern config_t g_C;


int 
split(
    uint32_t **to, /* [m][n] */
    uint8_t *g, // for debugging 
    uint32_t lb,
    uint32_t ub,
    uint32_t nT, // number of tails in this data set 
    uint32_t nH, // number of heads in this data set 
    uint32_t n,
    uint32_t m,
    uint64_t **Y, /* [m][n] */
    uint64_t **tmpY, /* [n] */
    uint32_t depth
   )
{
  int status = 0;

  // No point splitting if it would create more nodes than permissible
  if ( g_n_tree >= g_sz_tree ) { 
    // fprintf(stderr, "No space in tree. Returning... \n"); 
    return status;
  }

  // if a split would cause one of the children to be smaller
  // size than permissible, no point splitting 
  if ( (ub - lb) < 2 * g_C.min_leaf_size ) { return status; }

  // If a split would cause one of the children to be of greater
  // depth than permissible, no point splitting 
  if ( depth >= g_C.max_depth ) {  
    // fprintf(stderr, "Tree too deep. Cannot split further \n");
    return status;
  }

  four_nums_t num4; memset(&num4, 0, sizeof(four_nums_t));

  uint32_t split_j = m+1; // set to some bad value 
  uint32_t split_yidx, split_yval;

#ifdef VERBOSE
  printf("Splitting %u to %u \n", lb, ub);
#endif
#ifdef DEBUG
  status = check(to, g, lb, ub, nT, nH, n, m, Y); cBYE(status);
#endif

  //-----------------------------------------
  status = search(Y, lb, ub, nT, nH, m, 
       &split_j, &split_yval,  &split_yidx, &num4); 
  cBYE(status); 
  //---------------------------------------------------
#pragma omp parallel for schedule(static, 1) num_threads(g_C.num_cores)
  for ( uint32_t j = 0; j < m; j++ ) {
    uint32_t lidx = lb, ridx = split_yidx;
    uint64_t *Yj = Y[j];
    uint64_t *tmpYj = tmpY[j];
#ifndef DEBUG
    // the order of the attribute chosen for split is unchanged
    // Hence, we can skip reordering it 
    if ( j == split_j ) { continue; }

#endif
    status = reorder(Y[j], tmpY[j], to[j], to[split_j], lb, ub,
        split_yidx, &lidx, &ridx);
    if ( status < 0 ) { WHEREAMI; status = -1; continue; }
    if ( lidx != split_yidx ) { WHEREAMI; status = -1; continue; }
    if ( ridx != ub ) { WHEREAMI; status = -1; continue; }
    if ( j != split_j ) { 
      // SLOW: for ( uint32_t i = lb; i < ub; i++ ) { Yj[i] = tmpYj[i]; }
      memcpy(Yj+lb, tmpYj+lb, (ub-lb) * sizeof(uint64_t)); 
    }
    else { // no need to re-order feature chosen for split 
#ifdef DEBUG
      for ( uint32_t i = lb; i < ub; i++ ) {
        if ( Yj[i] != tmpYj[i] ) { WHEREAMI; status = -1; continue; }
      }
#endif
    }
  }

  int parent_id = g_n_tree - 1;
  if ( ( split_yidx - lb ) >= g_C.min_partition_size ) {
    // set parent to lchild pointer and lchild to parent pointer
    g_tree[g_n_tree-1].lchild_id = g_n_tree;
    g_tree[g_n_tree].parent_id = parent_id;
    // set nH and nT for this newly created left child 
    g_tree[g_n_tree].nT = num4.n_T_L;
    g_tree[g_n_tree].nH = num4.n_H_L;
    g_tree[g_n_tree].depth = depth + 1; 
    g_n_tree++;
    // split the left child
    status = split(to, g, lb, split_yidx, num4.n_T_L, num4.n_H_L, 
        n, m, Y, tmpY, depth+1); 
    cBYE(status);
#ifdef DEBUG
    status = check_tree(g_tree, g_n_tree, m); cBYE(status);
#endif
  }
  // This check needs to be repeated because of left child creation
  // No point splitting if it would create more nodes than permissible
  if ( g_n_tree >= g_sz_tree ) { 
    // fprintf(stderr, "No space in tree. Returning... \n"); 
    return status;
  }

  if ( ( ub - split_yidx ) >= g_C.min_partition_size ) {
    // set parent to rchild pointer and rchild to parent pointer
    g_tree[parent_id].rchild_id = g_n_tree;
    g_tree[g_n_tree].parent_id = parent_id; 
    // set nH and nT for this newly created right child 
    g_tree[g_n_tree].nT = num4.n_T_R;
    g_tree[g_n_tree].nH = num4.n_H_R;
    g_tree[g_n_tree].depth = depth + 1; 
    g_n_tree++;
    // split the right child
    status = split(to, g, split_yidx, ub, num4.n_T_R, num4.n_H_R, 
        n, m, Y, tmpY, depth+1); 
    cBYE(status);
#ifdef DEBUG
    status = check_tree(g_tree, g_n_tree, m); cBYE(status);
#endif
  }
BYE:
  return status;
}
