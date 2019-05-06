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
#include "add_fld_SV.h"

//<hdr>
int add_fld_SV(
    char *nnX,
    uint64_t nR,
    int *ptr_has_null_vals,
    const char *filename,
    const char *datafile,
    const char *data_dir
    )
//</hdr>
{
  int status = 0;
  uint64_t nL = 0; /* number of lines in file */
  char *buf = NULL;
  FILE *ofp = NULL;
  char *inX = NULL; size_t n_inX = 0;
  char *lenX = NULL; size_t n_lenX = 0; 
  char *offX = NULL; size_t n_offX = 0; 
  char *len_filename = NULL;
  char *off_filename = NULL;
  
  bool file_created = false;
  bool len_file_created = false;
  bool off_file_created = false;
  *ptr_has_null_vals = FALSE;
  // Set up for null values
  if ( ( filename == NULL )  || ( *filename == '\0' ) ) { go_BYE(-1); }
  int len = strlen(filename);

  // Determine length of field
  size_t len_filesz = nR * sizeof(uint16_t);
  size_t off_filesz = nR * sizeof(uint64_t);
  //-------------------------------------------------------
#define MAX_BUF_LEN 32767 // max size of string 
  buf = malloc(MAX_BUF_LEN+1);
  return_if_malloc_failed(buf);
  for ( int i = 0; i < MAX_BUF_LEN+1; i++ ) { buf[i] = '\0'; }
  //-------------------------------------------------------
  // open handle to output file 
  ofp = fopen(filename, "wb");
  return_if_fopen_failed(ofp, filename, "wb");
  // make size file and mmap it
  len_filename = malloc(len + strlen(".len.") + 1);
  return_if_malloc_failed(len_filename);
  strcpy(len_filename, ".len."); strcat(len_filename, filename);
  status = mk_file(len_filename, len_filesz); cBYE(status);
  len_file_created = true;
  status = rs_mmap(len_filename, &lenX, &n_lenX, 1); cBYE(status);
  uint16_t *len_ptr = (uint16_t *)lenX;
  // make offset file and mmap it
  off_filename = malloc(len + strlen(".off.") + 1);
  return_if_malloc_failed(off_filename);
  strcpy(off_filename, ".off."); strcat(off_filename, filename);
  status = mk_file(off_filename, off_filesz); cBYE(status);
  off_file_created = true;
  status = rs_mmap(off_filename, &offX, &n_offX, 1); cBYE(status);
  uint64_t *off_ptr = (uint64_t *)offX;
  // gain access to input
  if ( ( data_dir !=  NULL ) && (  *data_dir != '\0' ) ) {
    status = chdir(data_dir); cBYE(status);
  }
  status = rs_mmap(datafile, &inX, &n_inX, 0); cBYE(status);
  //----------------------------------------------------
  size_t inidx = 0;
  off_ptr[0] = 0;
  for ( nL = 0 ; inidx < n_inX; nL++, nnX++ ) {
    int bufidx;
    if ( nL >= nR ) { 
      fprintf(stderr, "ERROR: Expected %" PRId64 " lines. Got more", nR);
      go_BYE(-1); 
    }
    // fill up buffer by reading until eoln
    status = load_buffer(inX, n_inX, &inidx, buf, &bufidx, MAX_BUF_LEN);
    cBYE(status);
    if ( bufidx == 0 ) { 
      // printf("Value index %d is null \n", (int)nL); 
      *ptr_has_null_vals = true;
      *nnX = FALSE;
    }
    else {
      *nnX = TRUE;
    }
    fwrite(buf, bufidx+1, sizeof(char), ofp);
    len_ptr[nL] = bufidx;
    if ( nL > 0 ) { 
      off_ptr[nL] = off_ptr[nL-1] + len_ptr[nL-1] + 1;
      // Note the +1 for the null character
    }
  }
  if ( nL != nR ) {
    fprintf(stderr, "ERROR: Read %" PRId64 " lines. Expected %" PRId64, nL, nR);
    go_BYE(-1); 
  }
  // fprintf(stderr, "DBG: Read %" PRId64 " lines\n", nL);
BYE:
  fclose_if_non_null(ofp);
  if ( status < 0 ) { 
    if ( off_file_created ) { unlink(off_filename); }
    if ( len_file_created ) { unlink(len_filename); }
    if (     file_created ) { unlink(    filename); }
  }
  rs_munmap(lenX, n_lenX);
  rs_munmap(offX, n_offX);
  rs_munmap(inX, n_inX);
  free_if_non_null(buf);
  free_if_non_null(len_filename);
  free_if_non_null(off_filename);
  return(status);
}
