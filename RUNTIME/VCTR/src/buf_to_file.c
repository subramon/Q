#include "buf_to_file.h"

int
buf_to_file(
   const char * const buf,
   size_t bufsize,
   const char * const file_name
)

{
  int status = 0;
  FILE *fp = NULL;

  if ( bufsize == 0 ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(1); }
  if ( buf == NULL ) { go_BYE(-1); }

  fp = fopen(file_name, "ab");
  return_if_fopen_failed(fp, file_name, "ab");
  size_t nw = fwrite(buf, 1, bufsize, fp);
  fclose(fp);
  if ( nw != bufsize ) { go_BYE(-1); }
BYE:
  return status;
}
