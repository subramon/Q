#include <stdlib.h>
#include <time.h>
#include <malloc.h>
#include "q_incs.h"
#include "lauxlib.h"
#include "core_agg.h"
#include "_files_to_include.h"

static int 
chk_name(
    const char * const name
    )
{
  int status = 0;
  if ( name == NULL ) { go_BYE(-1); }
  if ( strlen(name) > Q_MAX_LEN_INTERNAL_NAME ) {go_BYE(-1); }
  for ( char *cptr = (char *)name; *cptr != '\0'; cptr++ ) { 
    if ( !isascii(*cptr) ) { 
      fprintf(stderr, "Cannot have character [%c] in name \n", *cptr);
      go_BYE(-1); 
    }
    if ( ( *cptr == ',' ) || ( *cptr == '"' ) || ( *cptr == '\\') ) {
      go_BYE(-1);
    }
  }
BYE:
  return status;
}

int
agg_meta(
    AGG_REC_TYPE *ptr_agg,
    char *opbuf
    )
{
  int status = 0;
BYE:
  return status;
}

int
agg_free(
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  if ( ptr_agg == NULL ) {  go_BYE(-1); }
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
  // Set aggregator fields to default
  // ptr_agg->field_size = 0;
BYE:
  return status;
}

int 
agg_new(
    uint32_t initial_size,
    const char * const keytype,
    const char * const valtype,
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
  if ( ( strcmp(keytype, "I4") == 0 ) &&  ( strcmp(valtype, "I1") == 0 ) ) {
    x = q_rhashmap_create_I4_I1(initial_size);
  }
  if ( x == NULL ) { go_BYE(-1); }
  ptr_agg->hmap = x;

BYE:
  return status;
}

int
agg_num_elements(
    AGG_REC_TYPE *ptr_agg
    )
{
  return 0; // TODO 
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

int
agg_set_name(
    AGG_REC_TYPE *ptr_agg,
    const char * const name
    )
{
  int status = 0;
  if ( ptr_agg == NULL ) { go_BYE(-1); }
  
  memset(ptr_agg->name, '\0', Q_MAX_LEN_INTERNAL_NAME+1);
  status = chk_name(name); cBYE(status);
  strcpy(ptr_agg->name, name);
BYE:
  return status;
}
