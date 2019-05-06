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
#include "s_to_f_seq.h"
// START FUNC DECL
int main()
{
  int status = 0;
  status =  s_to_f_seq( "_xI1", 11, "I1", "1", "1"); cBYE(status);
  status =  s_to_f_seq( "_xI2", 11, "I2", "2", "2"); cBYE(status);
  status =  s_to_f_seq( "_xI4", 11, "I4", "3", "3"); cBYE(status);
  status =  s_to_f_seq( "_xI8", 11, "I8", "4", "4"); cBYE(status);
  status =  s_to_f_seq( "_xF4", 11, "F4", "5", "5"); cBYE(status);
  status =  s_to_f_seq( "_xF8", 11, "F8", "6", "6"); cBYE(status);
BYE:
  return(status);
}
#else
// This is just to keep gcc from complaining about empty compilation units
int g_ut_s_to_f_seq; 
#endif
