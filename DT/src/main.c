#include "incs.h"
#include "check_tree.h"
#include "get_time_usec.h"

#ifdef SEQUENTIAL
int g_num_swaps;  // for debugging 
uint64_t g_exp_num_swaps;  // for debugging 
#endif
// TODO #include "dump_data.h"
#include "make_data.h"
#include "read_data.h"
#include "prnt_data.h"
// TODO #include "unmp_data.h"

#include "read_config.h"
#include "preproc.h"
#include "split.h"

#include <omp.h>
config_t g_C; // configuration
metrics_t *g_M;  // [g_M_m][g_M_bufsz] 
uint32_t g_M_m;
uint32_t g_M_bufsz;

node_t *g_tree; // this is where the decision tree is created
int g_n_tree;
int g_sz_tree;

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  float **X = NULL;  // [m][n]
  uint64_t **Y  = NULL; // [m][n]
  uint64_t **tmpY  = NULL; // [n]
  uint32_t **to = NULL; // [m][n]
  uint8_t *g = NULL; // [n]
  g_tree = NULL; g_n_tree = 0; g_sz_tree = 0;
  g_M = NULL;

  if ( argc != 2 ) { go_BYE(-1); }
  char *config_file = argv[1];
  // globals for debugging 
#ifdef SEQUENTIAL
  g_num_swaps = 0;
#endif
  status = read_config(&g_C, config_file);  cBYE(status);
  // following are configurable 
  uint32_t n = g_C.num_instances;
  uint8_t  m = g_C.num_features;
  char *bin_file_prefix = "_bin_data_";
  bool use_bin_data = false;

  uint32_t nT = 0; uint32_t nH = 0;
  uint32_t lb = 0; uint32_t ub = n;
  //-----------------------------------------------
  // One time allocation for later use 
  g_M = NULL;
  g_M_m = m;
  g_M_bufsz = g_C.metrics_buffer_size;
  g_M = malloc(g_M_m * sizeof(metrics_t));
  return_if_malloc_failed(g_M);
  memset(g_M, 0,  (g_M_m * sizeof(metrics_t)));
  for ( uint32_t j = 0; j < g_M_m; j++ ) { 
    g_M[j].yval   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].yidx   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nT     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nH     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].metric = malloc(g_M_bufsz * sizeof(double));
  }
  // we are taking short-cut of allocating g_tree at beginning
  // Ideally, we would allocate a "reasonable" size and re-alloc
  // if we need more space 
  g_tree = NULL; // this is where the decision tree is created
  g_n_tree = 0;
  g_sz_tree = g_C.max_nodes_in_tree;
  g_tree = malloc(g_sz_tree * sizeof(node_t));
  return_if_malloc_failed(g_tree);
  for ( int i = 0; i < g_sz_tree; i++ ) { 
    g_tree[i].nT = g_tree[i].nH = g_tree[i].yval = 0;
    g_tree[i].lchild_id = g_tree[i].rchild_id = g_tree[i].yidx = -1;
    g_tree[i].parent_id = -1; 
    g_tree[i].xval = 0; 
  }
  //-----------------------------------------------
  if ( use_bin_data ) { 
    // status = read_data(&X, m, n, &g, bin_file_prefix); cBYE(status); 
    printf("Read pre-computed data \n");
  }
  else { 
    status = make_data(&X, m, n, &g); cBYE(status);
    // status = dump_data(X, m, n, g, bin_file_prefix); cBYE(status);
    printf("Generated data \n");
  }
#ifdef VERBOSE
  status = prnt_data_f(X, m, g, lb, ub); cBYE(status);
#endif
  status = preproc(X, m, n, g, &nT, &nH, &Y, &to, &tmpY); cBYE(status);
  printf("Pre-processed data \n");
  // create leaf node 
  g_tree[g_n_tree].nT = nT;
  g_tree[g_n_tree].nH = nH;
  g_n_tree++;
  // start splitting
  uint64_t t1, t2;
  t1 = get_time_usec();
  status = split(to, g, lb, ub, nT, nH, n, m, Y, tmpY); cBYE(status);
  t2 = get_time_usec();
  status = check_tree(g_tree, g_n_tree, m); cBYE(status);
  printf("Num nodes = %d \n", g_n_tree); 
  printf("Time      = %lf\n", (t2-t1)/1000000.0);
  printf("num_rows  = %d\n", n);
BYE:
  // TODO status = unmp_data(m, bin_file_prefix); cBYE(status);
  for ( uint32_t j = 0; j < m; j++ ) { 
    if ( X != NULL ) { free_if_non_null(X[j]); }
    if ( Y != NULL ) { free_if_non_null(Y[j]); }
    if ( tmpY != NULL ) { free_if_non_null(tmpY[j]); }
    if ( to != NULL ) { free_if_non_null(to[j]); }
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(to);
  free_if_non_null(g);
  free_if_non_null(g_tree);
  return status;
}
