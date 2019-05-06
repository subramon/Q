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
#include "s_to_f_period.h"
#include "s_to_f_period_I1.h"
#include "s_to_f_period_I2.h"
#include "s_to_f_period_I4.h"
#include "s_to_f_period_I8.h"

//<hdr>
int 
s_to_f_period(
    const char *filename, // is also name of field 
    uint64_t    nR,
    const char *str_fldtype,
    int64_t start,
    int64_t incr,
    uint64_t period
    )
//</hdr>
{
  int status = 0;
  int fldlen = 0;
  FLD_TYPE fldtype;
  char *bak_opX = NULL, *opX = NULL; size_t n_opX = 0;
  bool file_created = false;
  size_t filesz;

  if ( ( str_fldtype == NULL ) || ( *str_fldtype == '\0' ) ) { go_BYE(-1);}
  if ( ( filename == NULL )  || ( *filename == '\0' ) ) { go_BYE(-1); }

  status = get_fld_sz(str_fldtype, &fldtype, &fldlen); cBYE(status);
  if ( ( fldlen < 0 ) || ( fldtype < 0 ) ) { go_BYE(-1); }
  // make output file and mmap it
  printf("\n====================================\n");
  filesz = fldlen * nR;
  status = mk_file(filename, filesz); cBYE(status);
  file_created = true;
  status = rs_mmap(filename, &opX, &n_opX, 1); cBYE(status);
  bak_opX = opX;

  switch ( fldtype ) {
    case I1 : 
      s_to_f_period_I1((int8_t *)opX, nR, start, incr, period);
      break;
    case I2 : 
      s_to_f_period_I2((int16_t *)opX, nR, start, incr, period);
      break;
    case I4 : 
      s_to_f_period_I4((int32_t *)opX, nR, start, incr, period);
      break;
    case I8 : 
      s_to_f_period_I8((int64_t *)opX, nR, start, incr, period);
      break;
    default : 
      go_BYE(-1); 
      break; 
  }
BYE:
  if ( status < 0 ) { WHEREAMI; }
  if (status < 0 ) { 
    if (    file_created ) { unlink(filename); }
  }
  opX = bak_opX;
  rs_munmap(opX, n_opX);
  return(status);
}
