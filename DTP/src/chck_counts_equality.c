#include "incs.h"
#include "rs_mmap.h"
#include "chck_counts_equality.h"

int
chck_counts_equality(
    const bff_t * const bff,
    int n_bff,
    const bff_t * const bff_bin,
    int n_bff_bin
    )
{
  int status = 0; 
  if ( n_bff != n_bff_bin ) { go_BYE(-1); }
  for ( int i = 0; i < n_bff; i++ ) {
    if ( bff[i].count_L0 != bff_bin[i].count_L0 ) { go_BYE(-1); }
    if ( bff[i].count_L1 != bff_bin[i].count_L1 ) { go_BYE(-1); }
    if ( bff[i].threshold != bff_bin[i].threshold ) { go_BYE(-1); }
  }

BYE:
  return status;
}
