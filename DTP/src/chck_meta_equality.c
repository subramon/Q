#include "incs.h"
#include "rs_mmap.h"
#include "chck_counts_equality.h"

int
chck_counts_equality(
    const int * const meta,
    int n_meta,
    const bff_t * const meta_bin,
    int n_meta_bin,
    int num_features
    )
{
  int status = 0; 
  if ( n_meta != n_mta_bin ) { go_BYE(-1); }
  int meta_t_num_elems = (2 * num_features) + 3;
  for ( int i = 0; i < n_meta; i++ ) {

    if ( meta[i].node-idx != ??? ) { go_BYE(-1); }
    if ( meta[i].count0 != ??? ) { go_BYE(-1); }
    if ( meta[i].count1 != bff_bin[i].threshold ) { go_BYE(-1); }

    for ( int j = 0; j < num_features; j++ ) {
       if (meta[i].start_feature[j] != ???) { go_BYE(-1); }
       if (meta[i].stop_feature[j] != ???) { go_BYE(-1); }
    }

  }

BYE:
  return status;
}
