#include "q_incs.h"
#include "q_macros.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "isdir.h"
#include "file_split.h"

int 
main(
    int argc,
    const char ** const argv
    )
{
  int status = 0;
  for ( int i = 0; i < argc; i++ ) { 
    printf("%d -> %s \n", i, argv[i]);
  }
  printf("argc = %d \n", argc);
  if ( argc != 5 ) { go_BYE(-1); }
  const char * const infile =    argv[1];
  const char * const opdir  =    argv[2];
  uint32_t nB = atoi(            argv[3]);
  uint32_t split_col_idx  = atoi(argv[4]);
  status = file_split(infile, opdir, nB, split_col_idx); cBYE(status);
BYE:
  return status;
}
