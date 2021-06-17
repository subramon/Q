#ifndef __DT_TYPES
#define __DT_TYPES
typedef struct _four_nums_t {  
  uint32_t n_T_L;
  uint32_t n_H_L;
  uint32_t n_T_R;
  uint32_t n_H_R;
} four_nums_t; 
/* had to switch from AOS to SOA 
typedef struct _metrics_t {  
  uint32_t yval;
  uint32_t yidx;
  uint32_t cnt[2];
  double metric;
} metrics_t; 
*/
typedef struct _metrics_t {  
  uint32_t *yval;
  uint32_t *yidx;
  uint32_t *nT;
  uint32_t *nH;
  double   *metric;
} metrics_t; 

typedef struct _node_t { 
  int depth; 
  int lchild_id;
  int rchild_id;
  int parent_id;
  int yidx;
  uint32_t yval; // remember this is position-encoded value
  float xval;
  uint32_t nH;
  uint32_t nT;
} node_t;

typedef struct _config_t { 
  float min_percentage_improvement;  // TODO P3
  bool dump_binary_data;
  bool read_binary_data;
  bool is_verbose;
  bool is_debug;
  uint32_t max_depth; 
  uint32_t min_leaf_size;
  uint32_t num_features;
  uint32_t num_instances;
  uint32_t metrics_buffer_size;
  uint32_t min_partition_size;
  uint32_t max_nodes_in_tree;
  uint32_t num_cores; // <=0 in config file => get from omp
  char *bin_file_prefix; // TODO DOC
} config_t;
#endif
