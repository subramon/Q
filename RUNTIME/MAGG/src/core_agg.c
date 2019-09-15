#include <stdlib.h>
#include <time.h>
#include "q_incs.h"
#include "scalar_struct.h"
#include "lauxlib.h"
#include "cmem_struct.h"
#include "core_agg.h"

int
agg_free(
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  if ( ptr_agg == NULL ) {  go_BYE(-1); }
  memset(ptr_agg, '\0', sizeof(AGG_REC_TYPE));
  // Don't do this in C. Lua will do it: free(ptr_agg);
BYE:
  return status;
}

int
agg_delete(
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  if ( ptr_agg == NULL ) { go_BYE(-1); }
  status = agg_free(ptr_agg); cBYE(status);
BYE:
  return status;
}

int 
agg_instantiate(
    const char * const keytype,
    const char * const valtype,
    uint32_t initial_size,
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  if ( ( strcmp(keytype, "I4") != 0 ) && ( strcmp(keytype, "I8") != 0 ) ) {
    go_BYE(-1);
  }
  if ( ( strcmp(valtype, "I1") != 0 ) && ( strcmp(valtype, "I2") != 0 ) &&
       ( strcmp(valtype, "I4") != 0 ) && ( strcmp(valtype, "I8") != 0 ) && 
       ( strcmp(valtype, "F4") != 0 ) && ( strcmp(valtype, "F8") != 0 ) ) {
    go_BYE(-1);
  }
  strcpy(ptr_agg->valtype, valtype);
  strcpy(ptr_agg->keytype, keytype);
  void *x = NULL;
  /* We need something like this for all key/val types. This is scripted
  if ( ( strcmp(keytype, "I4") == 0 ) &&  ( strcmp(valtype, "I1") == 0 ) ) {
  }
  */
  if ( x == NULL ) { go_BYE(-1); }
  ptr_agg->hmap = x;

BYE:
  return status;
}

int
agg_check(
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
BYE:
  return status;
}
