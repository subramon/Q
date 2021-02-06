#include "incs.h"
#include "rs_mmap.h"
#include "chck_counts.h"

int
chck_counts(
    const bff_t * const bff,
    int n_bff
    )
{
  int status = 0; 
  if ( n_bff < 0 ) { go_BYE(-1); }
  for ( int i = 0; i < n_bff; i++ ) {
    if ( bff[i].count_L0 < 0 ) { go_BYE(-1); }
    if ( bff[i].count_L1 < 0 ) { go_BYE(-1); }
  }

BYE:
  return status;
}
