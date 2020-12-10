#include "incs.h"
#include "read_config.h"
  // START: read configuration
int read_config(
    config_t *ptr_C,
    const char * const config_file
    )
{
  int status = 0;

  ptr_C->min_leaf_size = 32;
  ptr_C->num_features = 4;
  ptr_C->num_instances = 32 * 1024;
  ptr_C->metrics_buffer_size = 8;
  ptr_C->min_partition_size = 32;
  ptr_C->max_nodes_in_tree = 4096;
  ptr_C->num_cores = -1; // <=0 in config file => get from omp
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
