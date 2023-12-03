#include "q_incs.h"
#include "cmem_consts.h"
#include "cmem_struct.h"
#include "aux_cmem.h"
#define USE_GLOBALS // TODO P2 THINK ABOUT THIS ONE 
#ifdef USE_GLOBALS
#include "mod_mem_used.h"
#endif
#undef VERBOSE
int 
cmem_free( 
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  if ( ptr_cmem->is_foreign ) { return status; }

#ifdef VERBOSE
  if ( *ptr_cmem->cell_name != '\0' ) {  
    printf("CMEM Freeing %lld from %s \n", ptr_cmem->size, ptr_cmem->cell_name);
  }
#endif

  memset(ptr_cmem->cell_name, 0, Q_MAX_LEN_CELL_NAME+1); 
  if ( ptr_cmem->data == NULL ) { 
    // explicit free will cause control to come here
    if ( ptr_cmem->size != 0 ) {
      go_BYE(-1); 
    }
  }
  else {
    if ( ptr_cmem->is_foreign ) { 
      /* Foreign indicates somebody else responsible for free */
    }
    else {
      // garbage collection of Lua
      if ( ptr_cmem->size == 0 ) {
        /* nothing to do */
        go_BYE(-1);
      }
      free_if_non_null(ptr_cmem->data);
#ifdef USE_GLOBALS
      status = decr_mem_used((uint64_t)ptr_cmem->size);  cBYE(status);
#endif
      ptr_cmem->size = 0;
    }
  }
BYE:
  return status;
}
int 
cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    qtype_t qtype,
    const char * const cell_name
    )
{
  int status = 0;
  if ( data == NULL ) { go_BYE(-1); }
  if ( size < 1 ) { go_BYE(-1); }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  ptr_cmem->qtype = qtype;
  memset(ptr_cmem->cell_name, 0, Q_MAX_LEN_CELL_NAME+1); 
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, Q_MAX_LEN_CELL_NAME);
  }
  ptr_cmem->is_foreign = true;
BYE:
  return status;
}

int 
cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    qtype_t qtype,
    const char *const cell_name
    )
{
  int status = 0;
  void *data = NULL;
  if ( size < 0 ) { go_BYE(-1); } // we allow size == 0 
  if ( size > 0 ) { 
    // Always allocate a multiple of CMEM_ALIGNMENT
    size = (size_t)ceil((double)size / CMEM_ALIGNMENT) * CMEM_ALIGNMENT;
    status = posix_memalign(&data, CMEM_ALIGNMENT, size);
    cBYE(status);
    return_if_malloc_failed(data);
#ifdef USE_GLOBALS
    status = incr_mem_used(size);  cBYE(status);
#endif
  }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  ptr_cmem->qtype = qtype;
  memset(ptr_cmem->cell_name, 0, Q_MAX_LEN_CELL_NAME+1); 
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, Q_MAX_LEN_CELL_NAME);
#ifdef VERBOSE
    printf("CMEM Malloc of %lld  for %s \n", ptr_cmem->size, ptr_cmem->cell_name);
#endif
  }
  ptr_cmem->is_foreign = false;
BYE:
  return status;
}
