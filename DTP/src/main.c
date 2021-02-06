#include "incs.h"
#include "get_time_usec.h"
#include "read_tree.h"
#include "read_meta.h"
#include "read_point.h"
#include "read_bin_data.h"
#include "read_counts.h"
//
#include "chck_tree.h"
// #include "chck_meta.h"
// #include "chck_counts.h"

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
  int num_features; 
  node_t *tree = NULL; // [num_nodes] 
  meta_t *meta = NULL; // [num_nodes] 
  int num_nodes;
  bff_t *bff = NULL; // [n_bff]
  int n_bff = 0; 
  int num_lines = 32; // TODO hard coded for now. Undo 

  // Normally, Use getopt to parse arguments. This is too simple for getopt.
  if ( argc != 6 ) { go_BYE(-1); }
  num_nodes    = atoi(argv[1]); if ( num_nodes <= 1 ) { go_BYE(-1); }
  num_features = atoi(argv[2]); if ( num_features <= 1 ) { go_BYE(-1); }
  tree_file = argv[3];
  meta_file = argv[4];
  counts_file = argv[5];
  status = read_tree(tree_file, num_features, num_nodes, &tree); 
  cBYE(status); 
  int num_interior_nodes = num_non_leaf(tree, num_nodes);
  status = read_meta(meta_file, num_features, num_interior_nodes, &meta, 
      tree, num_nodes); 
  cBYE(status); 
  status = read_counts(counts_file, num_lines, &bff, &n_bff); cBYE(status);
  // status = read_bin_data(counts_file, &bff, &n_bff); cBYE(status);
  status = chck_tree(tree, num_features ,num_nodes); cBYE(status); 
  // status = chck_meta(meta, num_features ,num_nodes); cBYE(status); 
  printf("Inputs read\n");
  for ( ; ; ) { // debugging loop 
    // read a point 
    bool all_done; float *point = NULL; 
    status = read_point(&point, num_features, &all_done); 
    if ( all_done ) { break; } 
    if ( status != 0 ) { continue; } 
    // perform updates 
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
