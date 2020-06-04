#include "q_incs.h"
#include "_rs_mmap.h"
#include "copy_file.h"

int
copy_file(
    const char * const src_file,
    const char * const dst_file
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  FILE *fp = NULL;
  if ( src_file == NULL ) { go_BYE(-1); }
  if ( dst_file == NULL ) { go_BYE(-1); }
  if ( strcmp(src_file, dst_file) == 0 ) { go_BYE(-1); }
  status = rs_mmap(src_file, &X, &nX, 0); cBYE(status);
  fp = fopen(dst_file, "wb");
  return_if_fopen_failed(fp, dst_file, "wb");
  int nw = fwrite(X, nX, 1, fp); if ( nw != 1 ) { go_BYE(-1); } 
BYE:
  fclose_if_non_null(fp);
  if ( X != NULL ) { munmap(X, nX); }
  return status;
}

