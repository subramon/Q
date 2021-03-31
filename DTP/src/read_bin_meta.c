#include "incs.h"
#include "rs_mmap.h"
#include "read_bin_meta.h"

int
read_bin_meta(
    const char * const data_file,
    int **ptr_meta,
    int *ptr_n_meta,
    int num_features
    )
{
  int status = 0; 
  char *X = NULL; size_t nX = 0; 
  int n_meta = 0; 
  status = rs_mmap(data_file, &X, &nX, false);  cBYE(status);
  if ( ( X == NULL ) ||  ( nX == 0 ) ) { go_BYE(-1); }

  int meta_t_num_elems = ( 2 * num_features ) + 3;

  n_meta = nX / (meta_t_num_elems * sizeof(int));
  if ( ( n_meta * meta_t_num_elems * sizeof(int) ) != nX ) { go_BYE(-1); } 

  *ptr_meta = (int *)X;
  *ptr_n_meta = n_meta;

BYE:
  return status;
}
