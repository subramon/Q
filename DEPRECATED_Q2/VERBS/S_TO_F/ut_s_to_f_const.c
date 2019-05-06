#ifdef STAND_ALONE
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include "q_constants.h"
#include "qtypes.h"
#include "macros.h"
#include "auxil.h"
#include "dbauxil.h"
#include "mmap.h"
#include "s_to_f_const.h"
// START FUNC DECL
int main()
{
  int status = 0;
  status =  s_to_f_const( "_xI1", 11, "I1", "123", ""); cBYE(status);
  status =  s_to_f_const( "_xI2", 11, "I2", "12345", ""); cBYE(status);
  status =  s_to_f_const( "_xI4", 11, "I4", "12345678", ""); cBYE(status);
  status =  s_to_f_const( "_xI8", 11, "I8", "12345678901", ""); cBYE(status);
  status =  s_to_f_const( "_xF4", 11, "F4", "1234.56789", ""); cBYE(status);
  status =  s_to_f_const( "_xF8", 11, "F8", "1234567890123.456789", ""); cBYE(status);
  status =  s_to_f_const( "_xSC", 11, "SC", "1234567890", "10"); cBYE(status);
BYE:
  return(status);
}
#else
// This is just to keep gcc from complaining about empty compilation units
int g_ut_s_to_f_const; 
#endif
