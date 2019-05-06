//START_INCLUDES
#include "q_incs.h"
#include "_buf_to_file.h"
//STOP_INCLUDES
#include "_copy_file.h"

//START_FUNC_DECL
int
copy_file(
    char *src_file,
    char *dst_file
    )
//STOP_FUNC_DECL
{
  int status = 0;
  FILE *src_fp;
  char *buffer = NULL;
  

  src_fp = fopen(src_file, "rb");
  return_if_fopen_failed(src_fp, src_file, "rb");

  int64_t read_size = 0;
  int64_t buf_size = 1024; // TODO: Remove this hard-coding, size of intermediate buffer
  buffer = malloc(buf_size); return_if_malloc_failed(buffer);

  while ( !feof(src_fp) ) {
    read_size = fread(buffer, 1, buf_size, src_fp);
    if ( read_size > 0 ) {
      status = buf_to_file(buffer, 1, read_size, dst_file);
      cBYE(status);
    }
  }

BYE:
  // Close src_fp
  fclose_if_non_null(src_fp);

  // Free intermediate buffer
  free_if_non_null(buffer);

  return status;
}
