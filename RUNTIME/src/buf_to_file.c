#include "buf_to_file.h"

int
buf_to_file(
   const char * const addr,
   size_t size,
   size_t nmemb,
   const char * const file_name
)

{
  int status = 0;
  FILE *fp = NULL;

  if ( size == 0 ) {  // Unfortunate special case for B1
    // we must write out a multiple of 64 bits 
    size = 8;  // 64 bits = 8 bytes
    nmemb = ceil(nmemb/64.0);
  }
  if ( size == 0 ) { go_BYE(-1); }
  if ( nmemb == 0 ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(1); }
  if ( addr == NULL ) { go_BYE(-1); }

  // fprintf(stderr, "addr = %llu, size = %d, nmemb = %d, %s \n", addr, size, nmemb, file_name);
  // TODO P2 Consider using seek to end of file instead of using "ab"
  fp = fopen(file_name, "ab");
  return_if_fopen_failed(fp, file_name, "ab");
  size_t nw = fwrite(addr, size, nmemb, fp);
  fclose(fp);
  if ( nw != nmemb ) { 
    fprintf(stderr, "nw = %lu, size = %lu nmemb = %lu file = %s \n", 
        (long unsigned int)nw, (long unsigned int)size, (long unsigned int)nmemb, file_name);
    go_BYE(-1); 
  }
BYE:
  // fprintf(stderr, "Finished buf_to_file\n");
  return status;
}
