#include "incs.h"
#include "rs_mmap.h"
#include "read_data.h"

int
read_data(
    const char * const counts_file,
    int num_lines,
    bff_t **ptr_bff,
    int *ptr_n_bff
    )
{
  int status = 0; 
  FILE *fp = NULL;
  bff_t *bff = NULL;

  bff = malloc(num_lines * sizeof(bff_t));
  return_if_malloc_failed(bff);
  memset(bff, 0,  (num_lines * sizeof(bff_t)));

  fp = fopen(counts_file, "r");
  return_if_fopen_failed(fp,  counts_file, "r");
  int num_lines_read = 0;
  for ( int i = 0; !feof(fp); i++, num_lines_read++ ) { 
    float t, n0, n1; 
    int nr = fscanf(fp, "%f,%f,%f\n", &t, &n0, &n1);
    if ( nr != 3 )  { go_BYE(-1); }
    bff[i].threshold = t;
    bff[i].count_L0 = (int)n0;
    bff[i].count_L1 = (int)n1;
  }
  if ( num_lines_read != num_lines ) { go_BYE(-1); }

  *ptr_bff = (bff_t *)bff;
  *ptr_n_bff = num_lines;

BYE:
  return status;
}
