#include "incs.h"
#include "get_time_usec.h"

#include "read_tree.h"
#include "read_meta.h"
#include "read_point.h"
#include "read_bin_data.h"
#include "read_bin_meta.h"
#include "read_counts.h"
#include "delete_point.h"

#include "chck_tree.h"
#include "chck_meta.h"
#include "chck_counts.h"
#include "chck_counts_equality.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *tree_file = NULL;
  char *meta_file = NULL;
  char *counts_file = NULL;
  char *meta_file_bin = NULL;
  char *counts_file_bin = NULL;
  int num_features; 
  node_t *tree = NULL; // [num_nodes] 
  meta_t *meta = NULL; // [num_nodes] 
  int num_nodes;
  bff_t *bff = NULL; // [n_bff]
  int n_bff = 0; 
  bff_t *bff_bin = NULL; // [n_bff]
  int n_bff_bin = 0; 
  int *meta_bin = NULL;
  int n_meta_bin = 0;
  int num_lines = 32; // TODO hard coded for DS1
  //int num_lines = 2246696; // TODO hard coded for DS2
  //int num_lines = 4391204; // TODO hard coded for DS3

  // Normally, Use getopt to parse arguments. This is too simple for getopt.
  if ( argc != 8 ) { go_BYE(-1); }
  num_nodes    = atoi(argv[1]); if ( num_nodes <= 1 ) { go_BYE(-1); }
  num_features = atoi(argv[2]); if ( num_features <= 1 ) { go_BYE(-1); }
  tree_file = argv[3];
  meta_file = argv[4];
  counts_file = argv[5];
  meta_file_bin = argv[6];
  counts_file_bin = argv[7];
  uint64_t t1 = get_time_usec();
  status = read_tree(tree_file, num_features, num_nodes, &tree); 
  cBYE(status); 
  printf("num nodes = %d\n", num_nodes);
  int num_interior_nodes = num_non_leaf(tree, num_nodes);
  printf("num interior nodes = %d\n", num_interior_nodes);
  status = read_meta(meta_file, num_features, num_interior_nodes, &meta, 
      tree, num_nodes); 
  cBYE(status); 
  status = read_bin_meta(meta_file_bin, &meta_bin, &n_meta_bin, num_features); cBYE(status);
  status = read_bin_data(counts_file_bin, &bff_bin, &n_bff_bin); cBYE(status);
  status = read_counts(counts_file, num_lines, &bff, &n_bff); cBYE(status);
  uint64_t t2 = get_time_usec();
  printf("time to read inputs: %lf\n", (t2-t1)/1000000.0);
  status = chck_tree(tree, num_features ,num_nodes); cBYE(status); 
  status = chck_meta(num_features, meta, num_interior_nodes, 
    tree, num_nodes);
  cBYE(status);
  status = chck_counts(bff, n_bff); cBYE(status);
  status = chck_counts(bff_bin, n_bff_bin); cBYE(status);
  status = chck_counts_equality(bff, n_bff, bff_bin, n_bff_bin);
  printf("Inputs read\n");
  for ( ; ; ) { // debugging loop 
    // read a point 
    int retrain_node_idx; bool is_leaf;
    bool all_done; float *point = NULL;  int label; 
    status = read_point(&point, &label, num_features, &all_done); 
    if ( all_done ) { break; } 
    if ( status != 0 ) { continue; } 
    // perform updates 
    uint64_t start = get_time_usec();
    status = delete_point(point, label, tree, meta, bff, 
        num_nodes, num_interior_nodes, num_features, n_bff,
        &retrain_node_idx, &is_leaf); 
    uint64_t end = get_time_usec();
    printf("time for incremental training %lf\n", (end - start)/1000000.0);
    printf("retrain at node: %d\n", retrain_node_idx);
    printf("node to retrain is leaf? : %d\n", is_leaf);
    free_if_non_null(point);
  }
BYE:
  free_if_non_null(tree);
  free_if_non_null(bff);
  // if ( bff != NULL ) { munmap(bff, n_bff * sizeof(bff_t)); }
  free_meta(num_interior_nodes, meta);  meta = NULL;
  
  // free_data(data); 
  // free_tree(tree); 
  return status;
}
