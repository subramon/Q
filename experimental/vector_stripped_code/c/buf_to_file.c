//START_INCLUDES
#include "q_incs.h"
#include "mmap_types.h"
#include "_f_mmap.h"
//STOP_INCLUDES
#include "_buf_to_file.h"
//START_FUNC_DECL
int
buf_to_file(
   const char *addr,
   size_t size,
   size_t nmemb,
   const char * const file_name
)
//STOP_FUNC_DECL
{
  int status = 0;
  FILE *fp = NULL;

  if ( size == 0 ) { go_BYE(-1); }
  if ( nmemb == 0 ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(1); }
  if ( addr == NULL ) { go_BYE(-1); }

  // fprintf(stderr, "addr = %llu, size = %d, nmemb = %d, %s \n", addr, size, nmemb, file_name);
  fp = fopen(file_name, "a");
  return_if_fopen_failed(fp, file_name, "wb");
  size_t nw = fwrite(addr, size, nmemb, fp);
  // fprintf(stderr, "Wrote %d times %d to %s \n", size, nmemb, file_name);
  fclose(fp);
  if ( nw != nmemb ) { go_BYE(-1); }
BYE:
  // fprintf(stderr, "Finished buf_to_file\n");
  return status;
}
