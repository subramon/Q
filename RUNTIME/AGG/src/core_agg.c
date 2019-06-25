#include <stdlib.h>
#include <time.h>
#include "q_incs.h"
#include "scalar_struct.h"
#include "lauxlib.h"
#include "cmem_struct.h"
#include "core_agg.h"
#include "_files_to_include.h"
#include "_mk_hash_files_to_include.h"
#include "_q_rhashmap_I8_I8.h"
#include "_q_rhashmap_I4_F4.h" // TODO UNDO P1 

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
#include "_destroy.c"
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
agg_get_meta(
    AGG_REC_TYPE *ptr_agg,
    uint32_t *ptr_nitems,
    uint32_t *ptr_size
    )
{
  int status = 0;
  /* Note that to access these values we don't really care about 
   * type of hmap */
  q_rhashmap_I8_I8_t *ptr_hmap = (q_rhashmap_I8_I8_t *)(ptr_agg->hmap);
  *ptr_nitems = ptr_hmap->nitems;
  *ptr_size   = ptr_hmap->size;
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
agg_putn(
    AGG_REC_TYPE *ptr_agg,
    CMEM_REC_TYPE *keys,
    int update_type,
    CMEM_REC_TYPE *cmem_hashes,
    CMEM_REC_TYPE *cmem_locs,
    CMEM_REC_TYPE *cmem_tids,
    int nT,
    CMEM_REC_TYPE *vals,
    int nkeys, /* TODO P4 Undo Assumption that nkeys <= 2^31 */
    CMEM_REC_TYPE *cmem_isfs
    )
{
  int status = 0;
  uint32_t *hashes = (uint32_t *)cmem_hashes->data;
  uint32_t *locs   = (uint32_t *)cmem_locs->data;
  uint8_t  *tids   = (uint8_t  *)cmem_tids->data;
  uint8_t  *isfs   = (uint8_t  *)cmem_isfs->data;
#include "_putn.c"
  /*
  if ( ( strcmp(keys->field_type, "I4") == 0 ) && 
      ( strcmp(vals->field_type, "F4") == 0 ) ) {
    status = q_rhashmap_putn_I4_F4( (q_rhashmap_I4_F4_t *)ptr_agg->hmap,  
    update_type, (int32_t *)keys->data, hashes, locs, tids, nT,
    (float *)vals->data, nkeys, isfs);
  }
  else {
    go_BYE(-1);
  }
  */


BYE:
  return status;
}

int 
agg_getn(
    AGG_REC_TYPE *ptr_agg,
    CMEM_REC_TYPE *keys,
    CMEM_REC_TYPE *cmem_hashes,
    CMEM_REC_TYPE *cmem_locs,
    CMEM_REC_TYPE *vals,
    int nkeys
    )
{
  int status = 0;
  uint32_t *hashes = (uint32_t *)cmem_hashes->data;
  uint32_t *locs   = (uint32_t *)cmem_locs->data;
#include "_getn.c"
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
