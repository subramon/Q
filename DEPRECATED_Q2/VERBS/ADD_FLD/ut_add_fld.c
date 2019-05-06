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
#include "add_fld.h"
// START FUNC DECL
int main()
{
  int status = 0;
  char *filename = "_xxx";
  uint64_t nR = 20;
  char *str_fldtype = "I4"; 
  char *str_fldlen = "";
  char *datafile = "in1.csv";
  char *data_dir = "/tmp/";
  int is_null_vals = false;

  system(" cp t1.csv /tmp/");
  status =  add_fld(
      "_x",
      "20",
      "I4",
      "",
      "t1.csv",
      "/tmp/",
      &is_null_vals
      );
  cBYE(status);
  system(" cp t2.csv /tmp/");
  status =  add_fld(
      "_y",
      "9",
      "SC",
      "7",
      "t2.csv",
      "/tmp/",
      &is_null_vals
      );
  cBYE(status);
  status =  add_fld(
      "_z",
      "9",
      "SV",
      "",
      "t2.csv",
      "",
      &is_null_vals
      );
  cBYE(status);
BYE:
  return(status);
}
#else
// This is just to keep gcc from complaining about empty compilation units
int g_ut_add_fld; 
#endif
