#include "q_incs.h"
#include "rs_mmap.h"
#include "str_as_file.h"
#include "get_file_size.h"
int
str_as_file(
    const char * const str,
    const char * const outfile
    )
{
  int status = 0;
  FILE *fp = NULL;
  if ( str == NULL ) { go_BYE(-1); }
  if ( outfile == NULL ) { go_BYE(-1); }

  fp = fopen(outfile, "wb");
  return_if_fopen_failed(fp, outfile, "wb");
  size_t len = strlen(str);
  size_t nw = fwrite(str, len, 1, fp); 
  if ( nw != 1 ) { go_BYE(-1); }
  fclose_if_non_null(fp);
#ifdef DEBUG
  if ( len != (size_t)get_file_size(outfile) ) { go_BYE(-1); }
#endif
BYE:
  return status;
}
