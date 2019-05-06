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
#include "add_fld.h"
#include "add_fld_SC.h"
#include "add_fld_SV.h"

//
//<hdr>
int add_fld(
    const char *filename,
    uint64_t   nR,
    const char *str_fldtype,
    int         sc_fldlen,
    const char *datafile,
    const char *data_dir,
    int *ptr_has_null_vals
    )
//</hdr>
{
#define MAX_BUF_LEN 31
  int status = 0;
  FLD_TYPE fldtype; int fldlen;
  uint64_t nL = 0; /* number of lines in file */
  char *buf = NULL;
  char *inX = NULL; size_t n_inX = 0;
  char *szX = NULL; size_t n_szX = 0;
  char *offX = NULL; size_t n_offX = 0;
  char *opX = NULL; size_t n_opX = 0; char *bak_opX  = NULL;
  char *nnX = NULL; size_t n_nnX = 0; char *bak_nnX  = NULL;
  bool file_created = false, nn_file_created = false;
  int8_t valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float valF4;
  double valF8;
  char cwd[MAX_LEN_DIR_NAME+1];
  char *nn_filename = NULL;
  size_t filesz;
  uint64_t zero = 0;
  
  // Remember where you started off from
  if ( getcwd(cwd, MAX_LEN_DIR_NAME) == NULL ) { go_BYE(-1); }
  // Set up for null values
  if ( ( filename == NULL )  || ( *filename == '\0' ) ) { go_BYE(-1); }
  int len = strlen(filename);
  nn_filename = malloc(len + strlen(".nn.") + 1 );
  strcpy(nn_filename, ".nn.");
  strcat(nn_filename, filename);

  *ptr_has_null_vals = false;
  status = get_fld_sz(str_fldtype, &fldtype, &fldlen); cBYE(status);
  //
  // make nn file and mmap it
  status = mk_file(nn_filename, nR); cBYE(status);
  nn_file_created = true;
  status = rs_mmap(nn_filename, &nnX, &n_nnX, 1); cBYE(status);
  bak_nnX = nnX;

  bool done = false;
  switch ( fldtype ) { 
    case SC : 
      done = true; 
      status = add_fld_SC(nnX, nR, &file_created, ptr_has_null_vals,
      filename, sc_fldlen, datafile, data_dir);
      cBYE(status); 
      break;
    case SV : 
      done = true; 
      status = add_fld_SV(nnX, nR, ptr_has_null_vals, filename, 
          datafile, data_dir);
      cBYE(status); break;
    default : /* keep going */ break;
  }
  if ( done ) { goto BYE; }
  /* Following code handles types I1, i2, i4, I8, F4, F8 */
  filesz = fldlen * nR;
  //-------------------------------------------------------
  buf = malloc(MAX_BUF_LEN+1);
  return_if_malloc_failed(buf);
  for ( int i = 0; i < MAX_BUF_LEN+1; i++ ) { buf[i] = '\0'; }
  //-------------------------------------------------------
  // make output file and mmap it
  status = mk_file(filename, filesz); cBYE(status);
  file_created = true;
  status = rs_mmap(filename, &opX, &n_opX, 1); cBYE(status);
  bak_opX = opX;
  // gain access to input
  if ( ( data_dir !=  NULL ) && (  *data_dir != '\0' ) ) {
    status = chdir(data_dir); cBYE(status);
  }
  status = rs_mmap(datafile, &inX, &n_inX, 0); cBYE(status);

  size_t inidx = 0;
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
       memcpy(opX, &zero, fldlen);  
       opX += fldlen;
    }
    else {
      switch ( fldtype ) {
        case I1 : 
          status = stoI1(buf, &valI1); cBYE(status); 
          memcpy(opX, &valI1, fldlen);   opX += fldlen;
          break;
        case I2 : 
          status = stoI2(buf, &valI2); cBYE(status); 
          memcpy(opX, &valI2, 2);   opX += fldlen;
          break;
        case I4 : 
          status = stoI4(buf, &valI4); cBYE( status); 
          // fprintf(stderr, "valI4 = %d \n", valI4);
          memcpy(opX, &valI4, 4);   opX += fldlen;
          break;
        case I8 : 
          status = stoI8(buf, &valI8); cBYE( status); 
          memcpy(opX, &valI8, 8);   opX += fldlen;
          break;
        case F4 : 
          status = stoF4(buf, &valF4); cBYE(status); 
          memcpy(opX, &valF4, 4);   opX += fldlen;
          break;
        case F8 : 
          status = stoF8(buf, &valF8); cBYE(status); 
          memcpy(opX, &valF8, 8);   opX += fldlen;
          break;
        default : 
          go_BYE(-1); 
          break; 
      }
      *nnX = TRUE;
    }
  }
  if ( nL != nR ) {
    fprintf(stderr, "ERROR: Read %" PRId64 " lines. Expected %" PRId64, nL, nR);
    go_BYE(-1); 
  }
  // fprintf(stderr, "DBG: Read %" PRId64 " lines\n", nL);
BYE:
  status = chdir(cwd);  // needs to be done before unlink below 
  if ( status < 0 ) { WHEREAMI; }
  if (status < 0 ) { 
    if (    file_created ) { unlink(filename); }
    if ( nn_file_created ) { unlink(nn_filename); }
  }
  if ( *ptr_has_null_vals == false ) { 
    if ( nn_file_created ) { unlink(nn_filename); }
  }
  opX = bak_opX;
  nnX = bak_nnX;
  free_if_non_null(nn_filename);
  rs_munmap(opX, n_opX);
  rs_munmap(nnX, n_nnX);
  rs_munmap(szX, n_szX);
  rs_munmap(offX, n_offX);
  rs_munmap(inX, n_inX);
  free_if_non_null(buf);
  return(status);
}
