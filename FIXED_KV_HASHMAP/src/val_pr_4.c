// update the value 
#include "q_incs.h"
#include <limits.h>
#include <float.h>
#include "q_macros.h"
#include "val_struct_4.h"
#include "val_update.h"
#include "val_pr.h"

int
val_pr(
    void *in_val,
    FILE *fp
    )
{
  int status = 0;
  if ( in_val == NULL ) { go_BYE(-1); }
  if ( fp == NULL ) { fp = stdout; }

  val_t *val = (val_t *)in_val;
  fprintf(fp, "%d,%f,%f,%lf\n", 
      val->cnt, val->minval, val->maxval, val->sumval);
BYE:
  return status;
}

int
key_pr(
    void *in_key,
    FILE *fp
    )
{
  int status = 0;
  if ( in_key == NULL ) { go_BYE(-1); }
  if ( fp == NULL ) { fp = stdout; }

  key_t *key = (key_t *)in_key;
  fprintf(fp, "%d:", *key);
BYE:
  return status;
}
