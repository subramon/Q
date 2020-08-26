#include "q_incs.h"
#include "vec_macros.h"
#include "vctr_struct.h"

#include "get_file_size.h"
#include "copy_file.h"
#include "isfile.h"
#include "isdir.h"
#include "rdtsc.h"
#include "rs_mmap.h"

#define CORE_VEC_ALIGNMENT 64
#include "aux_qmem.h"
#include "aux_core_vec.h"

int
safe_strcat(
    char **ptr_X,
    size_t *ptr_nX,
    const char * const buf
    )
{
  int status = 0;
  char *X = *ptr_X;
  size_t nX = *ptr_nX;
  size_t buflen = strlen(buf);
  size_t Xlen   = strlen(X);
  if ( Xlen + buflen + 2 >= nX ) { 
    while ( (Xlen + buflen + 2) >= nX ) { 
      nX *= 2;
    }
    X = malloc(nX);
    return_if_malloc_failed(X);
    memset(X, 0, nX);
    strcpy(X, *ptr_X);
  }
  strcat(X, buf);
  *ptr_X = X;
  *ptr_nX = nX;
BYE:
  return status;
}


void 
l_memcpy(
    void *dest,
    const void *src,
    size_t n
    )
{
  memcpy(dest, src, n);
}

void *
l_malloc(
    size_t n
    )
{
  int status = 0;
  void  *x = NULL;

  status = posix_memalign(&x, CORE_VEC_ALIGNMENT, n); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  if ( x == NULL ) { WHEREAMI; return NULL; }
  if ( status < 0 ) { WHEREAMI; return NULL; }

  return x;
}

bool 
is_file_size_okay(
    const char *const file_name,
    int64_t expected_size
    )
{
  if ( ( *file_name == '\0' ) && ( expected_size == 0 ) ) { return true; }
  int64_t actual_size = get_file_size(file_name);
  if ( actual_size !=  expected_size ) { return false; }
  return true;
}

int 
chk_name(
    const char * const name
    )
{
  int status = 0;
  if ( name == NULL ) { go_BYE(-1); }
  for ( const char *cptr = (const char *)name; *cptr != '\0'; cptr++ ) { 
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
chk_fldtype(
    const char * const fldtype,
    uint32_t field_width
    )
{
  int status = 0;
  if ( fldtype == NULL ) { go_BYE(-1); }
  // TODO P3: SYNC with qtypes in q_consts.lua
  if ( ( strcmp(fldtype, "B1") == 0 ) || 
       ( strcmp(fldtype, "I1") == 0 ) || 
       ( strcmp(fldtype, "I2") == 0 ) || 
       ( strcmp(fldtype, "I4") == 0 ) || 
       ( strcmp(fldtype, "I8") == 0 ) || 
       ( strcmp(fldtype, "F4") == 0 ) || 
       ( strcmp(fldtype, "F8") == 0 ) || 
       ( strcmp(fldtype, "SC") == 0 ) || 
       ( strcmp(fldtype, "TM") == 0 ) ) {
    /* all is well */
  }
  else {
    fprintf(stderr, "Bad field type = [%s] \n", fldtype);
    go_BYE(-1);
  }
  if ( strcmp(fldtype, "B1") == 0 )  {
    if ( field_width != 1 ) { go_BYE(-1); }
  }
  else {
    if ( field_width == 0 ) { go_BYE(-1); }
  }
  if ( strcmp(fldtype, "SC") == 0 )  {
    if ( field_width < 2 ) { go_BYE(-1); }
  }
BYE:
  return status;
}


int
init_chunk_dir(
    VEC_REC_TYPE *ptr_vec,
    int num_chunks_to_allocate
    )
{
  int status = 0;
  uint32_t sz_chunks;
  // if elements exist, you would have initialized directory
  if ( ptr_vec->num_elements != 0 ) { return status; }
  //-----------------------------------------
  if ( ptr_vec->chunks     != NULL ) { go_BYE(-1); }
  if ( ptr_vec->sz_chunks  != 0    ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks != 0    ) { go_BYE(-1); }
  if ( num_chunks_to_allocate < 0 ) { 
    if ( ptr_vec->is_memo ) { 
      sz_chunks = 1;
    }
    else {
      sz_chunks = INITIAL_NUM_CHUNKS_PER_VECTOR;
    }
  }
  ptr_vec->chunks = calloc(sz_chunks, sizeof(uint32_t));
  return_if_malloc_failed(ptr_vec->chunks);
  ptr_vec->sz_chunks = sz_chunks;
BYE:
  return status;
}

// tells us which chunk to read this element from
int 
chunk_num_for_read(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    uint32_t *ptr_chunk_num
    )
{
  int status = 0;
  uint32_t chunk_num;
  if ( ptr_vec->num_elements == 0 ) { go_BYE(-1); }
  if ( idx >= ptr_vec->num_elements ) { go_BYE(-1); }
  if ( !ptr_vec->is_memo ) { 
    chunk_num = 0; 
  }
  else {
    chunk_num = idx / ptr_S->chunk_size;
  }
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  *ptr_chunk_num = chunk_num;
BYE:
  return status;
}
// tells us which chunk to write this element into
int 
get_chunk_num_for_write(
    qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t *ptr_chunk_num
    )
{
  int status = 0;
  uint32_t *new = NULL;
  if ( !ptr_vec->is_memo ) { *ptr_chunk_num = 0; return status; }
  // let us say chunk size = 64 and num elements = 63
  // this means that when you want to write, you write to chunk 0
  // let us say chunk size = 64 and num elements = 64
  // this means that when you want to write, you write to chunk 1
  uint32_t chunk_num =  (ptr_vec->num_elements / ptr_S->chunk_size);
  uint32_t sz = ptr_vec->sz_chunks;
  if ( chunk_num >= sz ) { // need to reallocate space
    new = calloc(2*sz, sizeof(uint32_t));
    return_if_malloc_failed(new);
    for ( uint32_t i = 0; i < sz; i++ ) {
      new[i] = ptr_vec->chunks[i];
    }
    free(ptr_vec->chunks);
    ptr_vec->chunks  = new;
    ptr_vec->sz_chunks  = 2*sz;
  }
  *ptr_chunk_num = chunk_num;
BYE:
  return status;
}

int
reincarnate(
    qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const v,
    char **ptr_X,
    bool is_clone
    )
{
  int status = 0;
  size_t nX = 65536; // Initial estimate for size of X 
#define BUFLEN 65535
  char *buf = NULL;
  char *X = NULL;
  char *old_file_name = NULL; char *new_file_name = NULL;

  WHOLE_VEC_REC_TYPE *w = 
    ptr_S->whole_vec_dir->whole_vecs + v->whole_vec_dir_idx;
  if ( w->uqid != v->uqid ) { go_BYE(-1); } 

  // check status of vector 
  if ( v->is_dead ) { go_BYE(-1); }
  if ( !v->is_eov ) { go_BYE(-1); }
  if ( w->num_writers > 0 ) { go_BYE(-1); }
  //--------------
  buf = malloc(BUFLEN+1);
  return_if_malloc_failed(buf);
  memset(buf, '\0', BUFLEN+1);

  X = malloc(nX);
  return_if_malloc_failed(X);
  memset(X, '\0', nX);

  strcpy(buf, " return { ");
  status = safe_strcat(&X, &nX, buf); cBYE(status);

  sprintf(buf, "qtype = \"%s\", ", v->fldtype); 
  status = safe_strcat(&X, &nX, buf); cBYE(status);

  sprintf(buf, "num_elements = %" PRIu64 ", ", v->num_elements); 
  status = safe_strcat(&X, &nX, buf); cBYE(status);

  sprintf(buf, "chunk_size = %" PRIu64 ",", ptr_S->chunk_size);
  status = safe_strcat(&X, &nX, buf); cBYE(status);

  sprintf(buf, "width = %u, ", v->field_width); 
  status = safe_strcat(&X, &nX, buf); cBYE(status);


  uint64_t old_vec_uqid = v->uqid; 
  if ( is_clone ) { 
    status = mk_file_name(ptr_S, old_vec_uqid, &old_file_name); 
    cBYE(status);
    uint64_t new_vec_uqid = get_uqid(ptr_S);
    if ( w->is_file ) {
      status = mk_file_name(ptr_S, new_vec_uqid, &new_file_name); 
      cBYE(status);
      status = copy_file(old_file_name, new_file_name); cBYE(status);
    }
    sprintf(buf, "vec_uqid = %" PRIu64 ",",  new_vec_uqid);
  }
  else {
    sprintf(buf, "vec_uqid = %" PRIu64 ",",  old_vec_uqid);
  }
  status = safe_strcat(&X, &nX, buf); cBYE(status);
  //-------------------------------------------------------
  // no master file => for each chunk, either 
  // (1) file must exist
  // (2) data must exist 
  if ( !w->is_file ) { 
    for ( unsigned int i = 0; i < v->num_chunks; i++ ) { 
      uint32_t chunk_dir_idx = v->chunks[i];
      chk_chunk_dir_idx(chunk_dir_idx);
      CHUNK_REC_TYPE *ptr_c = ptr_S->chunk_dir->chunks + chunk_dir_idx;
      if ( ( !ptr_c->is_file ) && ( ptr_c->data == NULL ) ) { 
        go_BYE(-1);
      }
    }
  }
  //------------------------------------------------------------
  status = safe_strcat(&X, &nX, "chunk_uqids = { "); cBYE(status);
  for ( unsigned int i = 0; i < v->num_chunks; i++ ) { 
    char *old_chunk_file_name = NULL;
    char *new_chunk_file_name = NULL;
    uint32_t chunk_dir_idx = v->chunks[i];
    chk_chunk_dir_idx(chunk_dir_idx);
    CHUNK_REC_TYPE *ptr_c = ptr_S->chunk_dir->chunks + chunk_dir_idx;
    uint64_t old_uqid = ptr_c->uqid; 
    if ( is_clone ) { 
      status = mk_file_name(ptr_S, old_uqid, &old_chunk_file_name); 
      cBYE(status);
      uint64_t new_uqid = get_uqid(ptr_S);
      status = mk_file_name(ptr_S,new_uqid, &new_chunk_file_name); 
      cBYE(status);
      if ( ptr_c->is_file ) { 
        status = copy_file(old_chunk_file_name, new_chunk_file_name); 
        cBYE(status);
        free_if_non_null(old_chunk_file_name); 
        free_if_non_null(new_chunk_file_name); 
      }
      sprintf(buf, "%" PRIu64 ",",  new_uqid);
    }
    else {
      sprintf(buf, "%" PRIu64 ",",  old_uqid);
    }
    status = safe_strcat(&X, &nX, buf); cBYE(status);
  }
  status = safe_strcat(&X, &nX, " }  "); cBYE(status);
  status = safe_strcat(&X, &nX, " }  "); cBYE(status);
  *ptr_X = X;
BYE:
  free_if_non_null(old_file_name);  free_if_non_null(new_file_name); 
  free_if_non_null(buf);
  if ( status < 0 ) { free_if_non_null(X); }
  return status;
}

bool
is_multiple(
    uint64_t x, 
    uint32_t y
    )
{
  if ( ( ( x /y ) * y ) == x ) { return true; } else { return false; }
}
//------------------------------------------------------
