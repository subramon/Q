#include "incs.h"
#include "check_tree.h"
#include "get_time_usec.h"

uint64_t g_num_swaps; // for debugging when single-threaded

#include "dump_data.h"
#include "make_data.h"
#include "read_data.h"
#include "prnt_data.h"

#include "read_config.h"
#include "preproc.h"
#include "split.h"

#include <omp.h>
config_t  g_C; // configuration
// m = number of features. Where is it defined?
// n = number of instances. Where is it defined?
// TODO DOC What is bufsz and why do we nd it? Where is it set?
metrics_t *g_M;  // [m][g_M_bufsz] 
uint32_t g_M_bufsz;

// The only reason that these are allocated here is so that
// search() does not have to allocate them.
double *g_best_metrics;   // [m] 
uint32_t *g_best_yvals;    // [m] 
uint32_t *g_best_yidxs;    // [m] 
four_nums_t *g_best_num4s; // [m] 
bool *g_is_splittables;    // [m]

node_t *g_tree; // this is where the decision tree is created
int g_n_tree;   // number of nodes in the treee
int g_sz_tree;  // allocated space for nodes => g_n_tree <= g_sz_tree

// following for statistics gathering
uint32_t g_num_gini_calc;
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  uint32_t n = 0; // number of instances
  uint8_t  m = 0; // number of features 
  float **X = NULL;  // [m][n] features for classification
  uint64_t **Y  = NULL; // [m][n]
  uint64_t **tmpY  = NULL; // [XX][n]  TODO DOC 
  uint32_t **to = NULL; // [m][n]
  uint8_t *g = NULL; // [n] goal attribute 
  char *config_file = NULL;
  // START: Initialize globals 
  g_M              = NULL;               
  g_M_bufsz        = 0;
  //-------------------
  g_best_metrics   = NULL;
  g_best_yvals     = NULL;
  g_best_yidxs     = NULL;
  g_best_num4s     = NULL;
  g_is_splittables = NULL;
  //-------------------
  g_tree         = NULL; 
  g_n_tree       = 0; 
  g_sz_tree      = 0;
  // STOP: Initialize globals 

  if ( argc >= 2 ) { config_file = argv[1]; }
  g_num_swaps = 0; // globals for debugging, only for single-threaded
  // read configurations 
  status = read_config(&g_C, config_file);  cBYE(status);
  // following are configurable 
  n = g_C.num_instances;
  m = g_C.num_features;
  const char *bin_file_prefix = "_bin_data_";

  uint32_t nT = 0; uint32_t nH = 0;
  uint32_t lb = 0; uint32_t ub = n;
  //-----------------------------------------------
  // One time allocation for later use 
  g_M_bufsz = g_C.metrics_buffer_size;
  g_M = malloc(m * sizeof(metrics_t));
  return_if_malloc_failed(g_M);
  memset(g_M, 0,  (m * sizeof(metrics_t)));
  for ( uint32_t j = 0; j < m; j++ ) { 
    g_M[j].yval   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].yidx   = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nT     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].nH     = malloc(g_M_bufsz * sizeof(uint32_t));
    g_M[j].metric = malloc(g_M_bufsz * sizeof(double));
  }
  // One time allocation for later use 
  g_best_metrics   = malloc(m * sizeof(double));
  g_best_yvals     = malloc(m * sizeof(uint32_t));
  g_best_yidxs     = malloc(m * sizeof(uint32_t));
  g_best_num4s     = malloc(m * sizeof(four_nums_t));
  g_is_splittables = malloc(m * sizeof(bool));
  // we are taking short-cut of allocating g_tree at beginning
  // Ideally, we would allocate a "reasonable" size and re-alloc
  // if we need more space 
  g_sz_tree = g_C.max_nodes_in_tree;
  g_tree = malloc(g_sz_tree * sizeof(node_t));
  return_if_malloc_failed(g_tree);
  for ( int i = 0; i < g_sz_tree; i++ ) { 
    g_tree[i].nT = g_tree[i].nH = g_tree[i].yval = 0;
    g_tree[i].lchild_id = g_tree[i].rchild_id = g_tree[i].yidx = -1;
    g_tree[i].parent_id = -1; 
    g_tree[i].xval = 0; 
    g_tree[i].depth = -1;
  }

  // for statistics gathering
  g_num_gini_calc = 0;
  //-----------------------------------------------
  if ( g_C.read_binary_data ) { 
    status = read_data(&X, m, n, &g, bin_file_prefix); cBYE(status); 
    printf("Read pre-computed data \n");
  }
  else { 
    status = make_data(&X, m, n, &g); cBYE(status);
    printf("Generated data \n");
    if ( g_C.dump_binary_data ) { 
      status = dump_data(X, m, n, g, bin_file_prefix); cBYE(status);
      printf("Dumped    data \n");
    }
  }
  if ( g_C.is_verbose ) { 
    status = prnt_data_f(X, m, g, lb, ub); cBYE(status);
  }
  status = preproc(X, m, n, g, &nT, &nH, &Y, &to, &tmpY); cBYE(status);
  printf("Pre-processed data \n");
  // create root node 
  g_tree[g_n_tree].nT = nT;
  g_tree[g_n_tree].nH = nH;
  g_tree[g_n_tree].depth = 0;
  g_n_tree++;
  // start splitting
  uint64_t t1, t2;
  t1 = get_time_usec();
  status = split(to, g, lb, ub, nT, nH, n, m, Y, tmpY, 0); cBYE(status);
  t2 = get_time_usec();
  status = check_tree(g_tree, g_n_tree, m); cBYE(status);
  printf("Num tree nodes    = %d \n", g_n_tree); 
  printf("Time              = %lf\n", (t2-t1)/1000000.0);
  printf("Num features      = %d\n", m);
  printf("Num instances     = %d\n", n);
  printf("Gini calculations = %u\n", g_num_gini_calc);
BYE:
  for ( uint32_t j = 0; j < m; j++ ) { 
    if ( !g_C.read_binary_data ) { 
      if ( X != NULL ) { free_if_non_null(X[j]); }
    }
    else {
      munmap(X[j], n * sizeof(float));
    }
    if ( Y != NULL ) { free_if_non_null(Y[j]); }
    if ( tmpY != NULL ) { free_if_non_null(tmpY[j]); }
    if ( to != NULL ) { free_if_non_null(to[j]); }
  }
  free_if_non_null(X);
  free_if_non_null(Y);
  free_if_non_null(tmpY);
  free_if_non_null(to);
  if ( !g_C.read_binary_data ) { 
    free_if_non_null(g);
  }
  else {
    munmap(g, n * sizeof(uint8_t));
  }
  free_if_non_null(g_tree);
  //----------------------------------
  if ( g_M != NULL ) { 
    for ( uint32_t j = 0; j < m; j++ ) { 
      free_if_non_null(g_M[j].yval);
      free_if_non_null(g_M[j].yidx);
      free_if_non_null(g_M[j].nT);
      free_if_non_null(g_M[j].nH);
      free_if_non_null(g_M[j].metric);
    }
  }
  free_if_non_null(g_M);
  //----------------------------------
  free_if_non_null(g_best_metrics);
  free_if_non_null(g_best_yvals);
  free_if_non_null(g_best_yidxs);
  free_if_non_null(g_best_num4s);
  free_if_non_null(g_is_splittables);
  //----------------------------------
  free_if_non_null(g_C.bin_file_prefix);
  return status;
}
