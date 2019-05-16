#include <stdlib.h>
#include <time.h>
#include <malloc.h>
#include "q_incs.h"
#include "scalar_struct.h"
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
  free_if_non_null(ptr_agg->hmap);
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
agg_del1(
    SCLR_REC_TYPE *ptr_key,
    const char *const valqtype,
    CDATA_TYPE *ptr_oldval,
    bool *ptr_is_found,
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  /* 
   * We need something like this for all key/val types. This is scripted
  */
#include "_del1.c"
BYE:
  return status;
}

int 
agg_get1(
    SCLR_REC_TYPE *ptr_key,
    const char *const valqtype,
    CDATA_TYPE *ptr_oldval,
    bool *ptr_is_found,
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  /* 
   * We need something like this for all key/val types. This is scripted
  */
#include "_get1.c"
BYE:
  return status;
}

int 
agg_put1(
    SCLR_REC_TYPE *ptr_key,
    SCLR_REC_TYPE *ptr_val,
    int update_type,
    CDATA_TYPE *ptr_oldval,
    AGG_REC_TYPE *ptr_agg
    )
{
  int status = 0;
  /* 
   * We need something like this for all key/val types. This is scripted
  */
#include "_put1.c"
BYE:
  return status;
}

int 
agg_new(
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
    x = q_rhashmap_create_I4_I1(initial_size);
  }
  */
#include "_creation.c"
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
