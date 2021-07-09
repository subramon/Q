#include "incs.h"
#include "get_time_usec.h"
#include "dump_data.h"
#include "make_data.h"
#include "read_data.h"
#include "read_config.h"
#include "qsort_asc_val_F4_idx_I1.h"
#include "preproc.h"
#include <omp.h>
config_t  g_C; // configuration
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

  if ( argc >= 2 ) { config_file = argv[1]; }
  // read configurations 
  status = read_config(&g_C, config_file);  cBYE(status);
  // following are configurable 
  n = g_C.num_instances;
  m = g_C.num_features;
  const char *bin_file_prefix = "_bin_data_";

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
  status = preproc(X, m, n, g, &nT, &nH, &Y, &to, &tmpY); cBYE(status);
  printf("Pre-processed data \n");
  // Pick a random split point
  // Call re-order
  uint64_t t1, t2, t3, t4;
  t1 = get_time_usec();
  // re-order
  t2 = get_time_usec();
  // Compare against re-sort
  t3 = get_time_usec();
  // re-sort
  t4 = get_time_usec();
  printf("Re-order Time              = %lf\n", (t2-t1)/1000000.0);
  printf("Re-sort  Time              = %lf\n", (t4-t3)/1000000.0);
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
  free_if_non_null(g_C.bin_file_prefix);
  return status;
}
