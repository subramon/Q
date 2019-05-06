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
#include "s_to_f_seq.h"
#include "s_to_f_seq_I1.h"
#include "s_to_f_seq_I2.h"
#include "s_to_f_seq_I4.h"
#include "s_to_f_seq_I8.h"
#include "s_to_f_seq_F4.h"
#include "s_to_f_seq_F8.h"

//<hdr>
int 
s_to_f_seq(
    const char *filename, // is also name of field 
    uint64_t    nR,
    const char *str_fldtype,
    const char *str_start,
    const char *str_incr
    )
//</hdr>
{
  int status = 0;
  int fldlen = 0;
  FLD_TYPE fldtype;
  char *bak_opX = NULL, *opX = NULL; size_t n_opX = 0;
  bool file_created = false;
  size_t filesz;
  int8_t  startI1, incrI1;
  int16_t startI2, incrI2;
  int32_t startI4, incrI4;
  int64_t startI8, incrI8;
  float   startF4, incrF4;
  double  startF8, incrF8;

  if ( ( str_start == NULL ) || ( *str_start == '\0' ) ) { go_BYE(-1);}
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
      status = stoI1(str_start, &startI1); cBYE(status);
      status = stoI1(str_incr,  &incrI1); cBYE(status);
      s_to_f_seq_I1((int8_t *)opX, nR, startI1, incrI1); 
      break;
    case I2 : 
      status = stoI2(str_start, &startI2); cBYE(status);
      status = stoI2(str_incr,  &incrI2); cBYE(status);
      s_to_f_seq_I2((int16_t *)opX, nR, startI2, incrI2); 
      break;
    case I4 : 
      status = stoI4(str_start, &startI4); cBYE(status);
      status = stoI4(str_incr,  &incrI4); cBYE(status);
      s_to_f_seq_I4((int32_t *)opX, nR, startI4, incrI4); 
      break;
    case I8 : 
      status = stoI8(str_start, &startI8); cBYE(status);
      status = stoI8(str_incr,  &incrI8); cBYE(status);
      s_to_f_seq_I8((int64_t *)opX, nR, startI8, incrI8); 
      break;
    case F4 : 
      status = stoF4(str_start, &startF4); cBYE(status);
      status = stoF4(str_incr,  &incrF4); cBYE(status);
      s_to_f_seq_F4((float *)opX, nR, startF4, incrF4); 
      break;
    case F8 : 
      status = stoF8(str_start, &startF8); cBYE(status);
      status = stoF8(str_incr,  &incrF8); cBYE(status);
      s_to_f_seq_F8((double *)opX, nR, startF8, incrF8); 
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
