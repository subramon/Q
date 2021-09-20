#include "incs.h"
#include "node_struct.h"
#include "sclr_eval.h"
extern void vctr_eval_isp(int32_t * nH, int32_t * nT, float * X, int32_t m, int32_t n, struct _orig_node_t * dt, int32_t n_dt, int32_t depth);
#include "get_time_usec.h"

config_t g_C;

// make fake data 
static int
make_fake_data(
    int num_features,
    int num_instances, 
    float **ptr_X // [num_features*num_instances]
    )
{
  int status = 0;
  float *X = NULL;
  X = malloc(num_features * num_instances * sizeof(float *));
  return_if_malloc_failed(X);
  *ptr_X = X;
  srandom(time(NULL));
  for ( int fidx =  0; fidx < num_features; fidx++ ) { 
    for ( int ridx =  0; ridx < num_instances; ridx++ ) { 
      int r = random();
      r = r & 0x00FFFFFF;
      float range = 1 << 24;
      *X = (float)r / range; 
      X++;
    }
  }
BYE:
  return status;
}

// makes a fake decision tree of depth n 
static int
make_fake_dt(
    int depth, // depth
    int num_features, // number of features
    orig_node_t **ptr_dt,
    int *ptr_n_dt
    )
{
  int status = 0;
  orig_node_t *dt = NULL;
  int num_frontier = 1;
  int n_dt = 0;
  for ( int d = 0; d < depth; d++ ) {
    n_dt += num_frontier;
    num_frontier *= 2;
  }
  dt = malloc(n_dt * sizeof(orig_node_t));
  return_if_malloc_failed(dt);
  memset(dt, 0, n_dt * sizeof(orig_node_t));
  // make fake tree
  dt[0].lchild_id = 1;
  dt[0].rchild_id = 2;
  for ( int i = 1; i < n_dt/2; i++ ) { // for all interior nodes
    dt[i].lchild_id = 2*i;
    dt[i].rchild_id = 2*i+1;
  }
  for ( int i = n_dt/2; i < n_dt; i++ ) { // for all interior nodes
    dt[i].lchild_id = dt[i].rchild_id = -1;
  }
  // quick check 
  int num_leaves = 0;
  for ( int i = 1; i < n_dt; i++ ) { 
    if ( ( dt[i].lchild_id < 0 ) ||  ( dt[i].rchild_id < 0 ) ) { 
      num_leaves++;
    }
  }
  if ( num_leaves != (n_dt/2) + 1 ) { go_BYE(-1); }


  *ptr_n_dt = n_dt;
  *ptr_dt = dt;
  
BYE:
  return status;
}

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
  status = make_fake_dt(depth, num_features, &dt, &n_dt);
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
