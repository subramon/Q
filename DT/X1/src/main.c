#include "incs.h"
#include "make_rand_data.h"
#include "make_rand_tree.h"
#include "split.h"
data_t g_D; // data
tree_t g_T; // decision tree 
uint32_t *g_P; // permutation induced by tree

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  status = make_rand_data(&g_D);  cBYE(status);
  status = make_rand_tree(&g_T, g_D.nK);  cBYE(status);
  g_P = malloc(g_D.nI * sizeof(uint32_t));
  return_if_malloc_failed(g_P);
  for ( uint32_t i = 0; i < g_D.nI; i++ ) { 
    g_P[i] = i;
  }
  g_T.nodes[0].Plb = 0;
  g_T.nodes[0].Pub = g_D.nI;
  uint64_t t_start = get_time_usec();
  status = split(&g_D, &g_T, g_P, 0); cBYE(status);
  uint64_t t_stop  = get_time_usec();
  printf("time = %lf \n", ((double)t_stop - (double)t_start)/1000.0);
BYE:
  status = free_rand_data(&g_D);  cBYE(status);
  status = free_rand_tree(&g_T);  cBYE(status);
  free_if_non_null(g_P);
  return status;
}
