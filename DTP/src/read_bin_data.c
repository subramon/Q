#include "incs.h"
#include "rs_mmap.h"
#include "read_bin_data.h"

int
read_bin_data(
    const char * const data_file,
    bff_t **ptr_bff,
    int *ptr_n_bff
    )
{
  int status = 0; 
  char *X = NULL; size_t nX = 0; 
  int n_bff = 0; 
  status = rs_mmap(data_file, &X, &nX, false);  cBYE(status);
  if ( ( X == NULL ) ||  ( nX == 0 ) ) { go_BYE(-1); }

  n_bff = nX / sizeof(bff_t);
  if ( ( n_bff * sizeof(bff_t) ) != nX ) { go_BYE(-1); } 

  *ptr_bff = (bff_t *)X;
  *ptr_n_bff = n_bff;

BYE:
  return status;
}
