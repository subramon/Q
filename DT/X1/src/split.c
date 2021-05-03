#include "incs.h"
#include "split.h"
static int
sortfn(
    const void *p1, 
    const void *p2
    )
{
  const comp_key_t *ck1 = (const comp_key_t *)p1;
  const comp_key_t *ck2 = (const comp_key_t *)p2;
  if ( ck1->fval < ck2->fval ) { 
    return -1;
  }
  else  {
    return 1;
  }
}
//------------------------------------------------
int
split(
    data_t *g_D,
    tree_t *g_T,
    uint32_t *g_P,
    uint32_t node_id
    )
{
  int status = 0;
  comp_key_t *ck = NULL; 
  uint32_t j = 0;

  int lchild_id = g_T->nodes[node_id].lchild_id;
  int rchild_id = g_T->nodes[node_id].rchild_id;
  uint32_t Plb       = g_T->nodes[node_id].Plb;
  uint32_t Pub       = g_T->nodes[node_id].Pub;
  // nothing to do if leaf
  if ( ( lchild_id < 0 ) || ( rchild_id < 0 ) ) { return status; }

  int n_ck = Pub - Plb;
  if ( n_ck <= 0 ) { 
    go_BYE(-1); 
  }

  int fidx = g_T->nodes[node_id].fidx;
  float  *data = g_D->fval[fidx];

  ck = malloc(n_ck * sizeof(comp_key_t));
  return_if_malloc_failed(ck);
  memset(ck, 0,  n_ck * sizeof(comp_key_t));
  j = 0;
  for ( uint32_t i = Plb; i < Pub; i++ ) { 
    uint32_t p = ck[j].p = g_P[i];
    ck[j].fval = data[p];
    j++;
  }
  qsort(ck, n_ck, sizeof(comp_key_t), sortfn);
  // DANGEROUS!!!!! update fval because this is fake data
  float fval = g_T->nodes[node_id].fval = ck[n_ck/2].fval;
  // TODO Undo above as soon as you have a real tree
  //-- find how many go left and how many go right 
  uint32_t left_ub = 0;
  for ( int i = 0; i < n_ck; i++ ) { 
    if ( ck[i].fval >= fval ) {  break; }
    left_ub++;
  }
  g_T->nodes[lchild_id].Plb = Plb;
  g_T->nodes[lchild_id].Pub = Plb + left_ub;
  g_T->nodes[rchild_id].Plb = Plb + left_ub;
  g_T->nodes[rchild_id].Pub = Pub;
  //----- update P 
  j = 0;
  for ( uint32_t i = Plb; i < Pub; i++ ) { 
    g_P[i] = ck[j++].p;
  }
  free_if_non_null(ck);
  // recursive call
  status = split(g_D, g_T, g_P, lchild_id); cBYE(status);
  status = split(g_D, g_T, g_P, rchild_id); cBYE(status);
  
BYE:
  free_if_non_null(ck);
  return status;
}
