#include "incs.h"
#include "read_config.h"
#include <omp.h>
// TODO P1 This is a fake. Read from real config file 
  // START: read configuration
int read_config(
    config_t *ptr_C,
    const char * const config_file
    )
{
  int status = 0;
  memset(ptr_C, 0, sizeof(config_t));

  ptr_C->min_percentage_improvement = 0; // TODO P3

  ptr_C->dump_binary_data = false;
  ptr_C->read_binary_data = false;
  ptr_C->is_verbose       = false;
  /*
  ptr_C->dump_binary_data = true;
  ptr_C->read_binary_data = false;

  ptr_C->dump_binary_data = false;
  ptr_C->read_binary_data = true;
  */
#define BASIC_TEST
#undef  PERF_TEST

#ifdef BASIC_TEST
  ptr_C->max_depth           = 16;
  ptr_C->min_leaf_size       = 32;
  ptr_C->num_features        = 4;
  ptr_C->num_instances       = 32 * 1024;
  ptr_C->metrics_buffer_size = 8;
  ptr_C->min_partition_size  = 32;
  ptr_C->max_nodes_in_tree   = 4096;
#endif
#ifdef PERF_TEST
  ptr_C->max_depth           = 32;
  ptr_C->min_leaf_size       = 32;
  ptr_C->num_features        = 16;
  ptr_C->num_instances       = 1024 * 1024; 
  ptr_C->metrics_buffer_size = 1024; 
  ptr_C->min_partition_size  = 32;
  ptr_C->max_nodes_in_tree   = 32768;
#endif

  ptr_C->num_cores           = 0; // <=0 in config file => get from omp
  if ( ptr_C->num_cores == 0 ) { 
    ptr_C->num_cores = omp_get_num_procs();  
    if ( ptr_C->num_cores > ptr_C->num_features ) { 
      ptr_C->num_cores = ptr_C->num_features; 
    }
  }
  printf("Using %d cores \n", ptr_C->num_cores);
BYE:
  return status;
}
