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
#include "s_to_f_const.h"
#include "s_to_f_const_I1.h"
#include "s_to_f_const_I2.h"
#include "s_to_f_const_I4.h"
#include "s_to_f_const_I8.h"
#include "s_to_f_const_F4.h"
#include "s_to_f_const_F8.h"
#include "s_to_f_const_SC.h"

//<hdr>
int 
s_to_f_const(
    const char *filename, // is also name of field 
    uint64_t    nR,
    const char *str_fldtype,
    const char *str_fldval,
    int         sc_fldlen // only for SC
    )
//</hdr>
{
  int status = 0;
  FLD_TYPE fldtype;
  char *bak_opX = NULL, *opX = NULL; size_t n_opX = 0;
  bool file_created = false;
  size_t filesz;
  int8_t valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float valF4;
  double valF8;
  char *valSC = NULL;
  int fldlen;

  if ( ( str_fldval == NULL ) || ( *str_fldval == '\0' ) ) { go_BYE(-1);}
  if ( ( str_fldtype == NULL ) || ( *str_fldtype == '\0' ) ) { go_BYE(-1);}
  if ( ( filename == NULL )  || ( *filename == '\0' ) ) { go_BYE(-1); }

  status = get_fld_sz(str_fldtype, &fldtype, &fldlen); cBYE(status);
  if ( fldtype == SC ) { 
    fldlen = sc_fldlen; 
    if ( ( fldlen <= 0 ) || ( fldlen >= 32767 ) ) { go_BYE(-1); }
    fldlen++; // allocate space for null character
    valSC = malloc(fldlen * sizeof(char));
    return_if_malloc_failed(valSC);
    zero_string(valSC, fldlen);
    strcpy(valSC, str_fldval);
  }
  //
  // make output file and mmap it
  filesz = fldlen * nR;
  status = mk_file(filename, filesz); cBYE(status);
  file_created = true;
  status = rs_mmap(filename, &opX, &n_opX, 1); cBYE(status);
  bak_opX = opX;

  switch ( fldtype ) {
    case I1 : 
      status = stoI1(str_fldval, &valI1); cBYE(status);
      s_to_f_const_I1((int8_t *)opX, nR, valI1); 
      break;
    case I2 : 
      status = stoI2(str_fldval, &valI2); cBYE(status);
      s_to_f_const_I2((int16_t *)opX, nR, valI2); 
      break;
    case I4 : 
      status = stoI4(str_fldval, &valI4); cBYE(status);
      s_to_f_const_I4((int32_t *)opX, nR, valI4); 
      break;
    case I8 : 
      status = stoI8(str_fldval, &valI8); cBYE(status);
      s_to_f_const_I8((int64_t *)opX, nR, valI8); 
      break;
    case F4 : 
      status = stoF4(str_fldval, &valF4); cBYE(status);
      s_to_f_const_F4((float *)opX, nR, valF4); 
      break;
    case F8 : 
      status = stoF8(str_fldval, &valF8); cBYE(status);
      s_to_f_const_F8((double *)opX, nR, valF8); 
      break;
    case SC : 
      s_to_f_const_SC(opX, nR, fldlen, valSC); 
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
  free_if_non_null(valSC);
  return(status);
}
