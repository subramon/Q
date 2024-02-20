//START_INCLUDES
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include "q_macros.h"
#include "rs_mmap.h"
#include "load_data_from_file.h"
//STOP_INCLUDES

//START_FUNC_DECL
int
load_data_from_file(
    const char * const src_file,
    uint64_t file_offset,
    uint64_t num_to_copy,
    uint32_t width,
    char *dst
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *X = NULL; uint64_t nX = 0;
  char *bak_X = NULL; uint64_t bak_nX = 0;
  if ( src_file == NULL ) { go_BYE(-1); }
  if ( dst == NULL ) { go_BYE(-1); }
  if ( width == 0 ) { go_BYE(-1); }
  if ( num_to_copy == 0 ) { go_BYE(-1); }

  status = rs_mmap(src_file, &X, &nX, 0); cBYE(status);
  bak_X = X; bak_nX = nX;
  X += file_offset * width;
  // make sure start of copy is within bounds 
  if ( X > bak_X + bak_nX ) { go_BYE(-1); } 
  nX -= file_offset * width;

  // make sure stop  of copy is within bounds 
  if ( num_to_copy * width > nX ) { go_BYE(-1); } 

  memcpy(dst, X, (num_to_copy*width));
BYE:
  mcr_rs_munmap(bak_X, bak_nX);
  return status;
}

