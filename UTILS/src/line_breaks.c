// This function has a very simplistic notion of a line. 
// All we work off is a separation by the eoln character.
// Do not handle case where eoln could be within a cell e.g., when
// quote delimited
// Assumption is that line length does not exceed 65535 
// Length of line *INCLUDES* eoln at end 
#include <stdio.h>
#include <string.h>
#include "rs_mmap.h"
#include "q_macros.h"
#include "line_breaks.h"

int
line_breaks(
    const char * const infile,
    const char * const outfile
    )
{
  int status = 0;
  FILE *ofp = NULL;
    char *X = NULL; size_t nX = 0;
  char eoln = '\n';
  if ( infile == NULL ) { go_BYE(-1); } 
  if ( outfile == NULL ) { go_BYE(-1); } 
  if ( strcmp(infile, outfile)  == 0 ) { go_BYE(-1); } 
  ofp = fopen(outfile, "wb");
  return_if_fopen_failed(ofp, outfile, "wb");

  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  if ( X[nX-1] != eoln ) { 
    fprintf(stderr, "File should terminate with eoln = ascii [%d]\n", eoln);
    go_BYE(-1);
  }
  uint32_t len = 0; 
  for ( uint64_t xidx = 0; xidx < nX; xidx++ ) { 
    len++; if ( len >= 65535 ) { go_BYE(-1); }
    if ( X[xidx] == eoln ) { 
      fwrite(&len, sizeof(uint16_t), 1, ofp);
      len = 0; 
    }
  }

BYE:
  fclose_if_non_null(ofp);
  mcr_rs_munmap(X, nX);
  return status;
}

