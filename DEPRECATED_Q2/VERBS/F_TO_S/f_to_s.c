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
#include "f_to_s.h"
#include "f_to_s_min_I1.h"
#include "f_to_s_min_I2.h"
#include "f_to_s_min_I4.h"
#include "f_to_s_min_I8.h"
#include "f_to_s_min_F4.h"
#include "f_to_s_min_F8.h"
#include "f_to_s_max_I1.h"
#include "f_to_s_max_I2.h"
#include "f_to_s_max_I4.h"
#include "f_to_s_max_I8.h"
#include "f_to_s_max_F4.h"
#include "f_to_s_max_F8.h"
#include "f_to_s_sum_I1.h"
#include "f_to_s_sum_I2.h"
#include "f_to_s_sum_I4.h"
#include "f_to_s_sum_I8.h"
#include "f_to_s_sum_F4.h"
#include "f_to_s_sum_F8.h"

//<hdr>
int 
f_to_s(
    const char *filename, // is also name of fld
    uint64_t    nR,
    const char *str_fldtype,
    const char *str_op,
    int has_null_fld,
    char *str_rslt,
    size_t sz_rslt // TODO: P3 Use this to check for overflow
    )
//</hdr>
{
  int status = 0;
  int fldlen = 0; FLD_TYPE fldtype;
  char *X = NULL; size_t n_X = 0;
  int8_t  valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float   valF4;
  double  valF8;

  if ( ( has_null_fld != TRUE )&& ( has_null_fld != FALSE ) ) { go_BYE(-1);}
  if ( ( str_fldtype == NULL ) || ( *str_fldtype == '\0' ) ) { go_BYE(-1);}
  if ( ( filename == NULL )  || ( *filename == '\0' ) ) { go_BYE(-1); }

  status= rs_mmap(filename, &X, &n_X, 0); cBYE(status);
  status = get_fld_sz(str_fldtype, &fldtype, &fldlen); cBYE(status);
  if ( strcasecmp(str_op, "min" ) == 0 ) { 
#include "incl_f_to_s_min.x"
  }
  else if ( strcasecmp(str_op, "max" ) == 0 ) { 
#include "incl_f_to_s_max.x"
  }
  else if ( strcasecmp(str_op, "sum" ) == 0 ) { 
#include "incl_f_to_s_sum.x"
  }
  else {
    go_BYE(-1);
  }
  
BYE:
  if ( status < 0 ) { WHEREAMI; }
  rs_munmap(X, n_X);
  return(status);
}
