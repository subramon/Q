#include "incs.h"
#include "node_struct.h"
#include "sclr_eval.h"
#include "make_fake_tree.h"
#include "make_fake_data.h"
#include "get_time_usec.h"
// TODO Keep following in sync with ispc code
extern void vctr_eval_isp(int32_t * nH, int32_t * nT, float * X, int32_t m, int32_t n, struct _orig_node_t * dt, int32_t n_dt, int32_t depth);

config_t g_C;

int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  // start configuration parameters
  int depth = 16;
  int num_features = 64;
  int num_instances = 4 * 1048576;
  //--------------------
  orig_node_t *dt = NULL; // [n_dt]
  int n_dt = 0;
  float *X = NULL; // [num_features * num_instances]
  int *nH = NULL; // [num_instances]
  int *nT = NULL; // [num_instances]
  //-------------------
  // read (or generate) decision tree
  memset(&g_C, 0, sizeof(config_t));
  status = make_fake_tree(depth, num_features, &dt, &n_dt);
  cBYE(status);
  // read (or generate) data
  status = make_fake_data(num_features, num_instances, &X);
  cBYE(status);
  // create space for results
  nH = malloc(num_instances * sizeof(int));
  return_if_malloc_failed(nH);
  nT = malloc(num_instances * sizeof(int));
  return_if_malloc_failed(nT);
  // perform inferencing
  printf("n = %d \n", num_instances);
  printf("m = %d \n", num_features);
  printf("d = %d \n", depth);
  uint64_t t_start = get_time_usec();
  status = sclr_eval(nH, nT, X, num_features, num_instances,
      dt, n_dt, depth); 
  cBYE(status);
  uint64_t t_stop  = get_time_usec();
  printf("T (scalar) = %lf\n", (t_stop - t_start)/1000000.0);

  t_start = get_time_usec();
  vctr_eval_isp(nH, nT, X, num_features, num_instances,
      dt, n_dt, depth); 
  t_stop  = get_time_usec();
  printf("T (vector) = %lf\n", (t_stop - t_start)/1000000.0);

BYE:
  free_if_non_null(X);
  free_if_non_null(dt);
  free_if_non_null(nH);
  free_if_non_null(nT);
  return status;
}
