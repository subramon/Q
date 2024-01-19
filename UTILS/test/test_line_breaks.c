#include "q_incs.h"
#include "line_breaks.h"
#include "rs_mmap.h"

int 
main(
    int argc, 
    char** argv
    ) 
{
  int status = 0;
  char  *X = NULL; size_t nX = 0;

  if ( argc != 3 ) { go_BYE(-1); } 
  const char *infile  = argv[1];
  const char *outfile = argv[2];

  status = line_breaks(infile, outfile); cBYE(status);
  // do some basic testing. 
  status = rs_mmap(outfile, &X, &nX, 0); cBYE(status);
  uint16_t *lens = (uint16_t *)X;
  uint32_t n_lens = nX / sizeof(uint16_t);
  if ( n_lens * sizeof(uint16_t) != nX ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < n_lens; i++ ) { 
    if ( lens[i] == 0 ) { go_BYE(-1); }
    printf("%3i:%u\n", i, lens[i]);
  }

BYE:
  mcr_rs_munmap(X, nX);
  return status;
}
