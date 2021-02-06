#include "incs.h"
#include "chck_meta.h"

int
chck_meta(
    int num_features, 
    meta_t *meta, // [num_interior_nodes] 
    int num_interior_nodes, 
    node_t *tree, // [num_nodes]
    int num_nodes
    )
{
  int status = 0;

  if ( num_nodes <= 0 ) { go_BYE(-1); }
  if ( num_features <= 0 ) { go_BYE(-1); }
  if ( num_interior_nodes <= 0 ) { go_BYE(-1); }
  for ( int i = 0; i < num_interior_nodes; i++ ) {
    for ( int j = 0; j < num_features; j++ ) {
      // can be equal eg if both are 0, but start can never be strictly bigger
      if ( meta[i].start_feature[j] > meta[i].stop_feature[j] ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}

