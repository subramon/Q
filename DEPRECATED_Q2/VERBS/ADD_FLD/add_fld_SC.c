#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <inttypes.h>
#include "q_constants.h"
#include "qtypes.h"
#include "macros.h"
#include "auxil.h"
#include "dbauxil.h"
#include "mmap.h"
#include "mk_file.h"
#include "aux_add_fld.h"
#include "add_fld_SC.h"

//<hdr>
int add_fld_SC(
    char *nnX,
    uint64_t nR,
    bool *ptr_file_created,
    int *ptr_has_null_vals,
    const char *filename,
    int   fldlen,
    const char *datafile,
    const char *data_dir
    )
//</hdr>
{
  int status = 0;
  uint64_t nL = 0; /* number of lines in file */
  char *buf = NULL;
  char *inX = NULL; size_t n_inX = 0;
  char *opX = NULL; size_t n_opX = 0; char *bak_opX  = NULL;
  int buflen = 0;
  size_t filesz;
  
  *ptr_file_created = false;
  *ptr_has_null_vals = FALSE;
  // Set up for null values
  // Determine length of field
  if ( fldlen <= 1 ) { go_BYE(-1);}
  buflen = fldlen + 1; // to keep space for nullc
  filesz = buflen * nR;
  //-------------------------------------------------------
  buf = malloc(buflen+1);
  return_if_malloc_failed(buf);
  for ( int i = 0; i < buflen+1; i++ ) { buf[i] = '\0'; }
  //-------------------------------------------------------
  // make output file and mmap it
  status = mk_file(filename, filesz); cBYE(status);
  *ptr_file_created = true;
  status = rs_mmap(filename, &opX, &n_opX, 1); cBYE(status);
  bak_opX = opX;
  // gain access to input
  if ( ( data_dir !=  NULL ) && (  *data_dir != '\0' ) ) {
    status = chdir(data_dir); cBYE(status);
  }
  status = rs_mmap(datafile, &inX, &n_inX, 0); cBYE(status);
  //----------------------------------------------------
  size_t inidx = 0;
  for ( nL = 0 ; inidx < n_inX; nL++, nnX++ ) {
    int bufidx;
    if ( nL >= nR ) { 
      fprintf(stderr, "ERROR: Expected %" PRId64 " lines. Got more", nR);
      go_BYE(-1); 
    }
    // fill up buffer by reading until eoln
    status = load_buffer(inX, n_inX, &inidx, buf, &bufidx, buflen);
    cBYE(status);
    if ( bufidx == 0 ) { 
      // printf("Value index %d is null \n", (int)nL); 
      *ptr_has_null_vals = true;
      *nnX = FALSE;
    }
    else {
      *nnX = TRUE;
    }
    memcpy(opX, buf, buflen);  opX += buflen;
  }
  if ( nL != nR ) {
    fprintf(stderr, "ERROR: Read %" PRId64 " lines. Expected %" PRId64, nL, nR);
    go_BYE(-1); 
  }
  // fprintf(stderr, "DBG: Read %" PRId64 " lines\n", nL);
BYE:
  opX = bak_opX;
  rs_munmap(opX, n_opX);
  rs_munmap(inX, n_inX);
  free_if_non_null(buf);
  return(status);
}
