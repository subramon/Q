#include "q_incs.h"
#include "vec_macros.h"
#include "vctr_struct.h"

#include "get_file_size.h"
#include "copy_file.h"
#include "isfile.h"
#include "isdir.h"
#include "rdtsc.h"
#include "rs_mmap.h"

#define Q_MAX_LEN_FILE_NAME 63 // TODO  P2 Delete
#define CORE_VEC_ALIGNMENT 64
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
  if ( strlen(name) > Q_MAX_LEN_INTERNAL_NAME ) {go_BYE(-1); }
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
    int num_chunks
    )
{
  int status = 0;
  // if elements exist, you would have initialized directory
  if ( ptr_vec->num_elements != 0 ) { return status; }
  //-----------------------------------------
  if ( ptr_vec->chunks     != NULL ) { go_BYE(-1); }
  if ( ptr_vec->sz_chunks  != 0    ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks != 0    ) { go_BYE(-1); }
  if ( num_chunks < 0 ) { 
    if ( ptr_vec->is_memo ) { 
      num_chunks = 1;
    }
    else {
      num_chunks = INITIAL_NUM_CHUNKS_PER_VECTOR;
    }
  }
  ptr_vec->chunks = calloc(num_chunks, sizeof(uint32_t));
  return_if_malloc_failed(ptr_vec->chunks);
  ptr_vec->sz_chunks = num_chunks;
BYE:
  return status;
}

// tells us which chunk to read this element from
int 
chunk_dir_idx_for_read(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    uint32_t *ptr_chunk_dir_idx
    )
{
  int status = 0;
  if ( ptr_vec->num_elements == 0 ) { go_BYE(-1); }
  if ( idx >= ptr_vec->num_elements ) { go_BYE(-1); }
  uint32_t chunk_num;
  if ( !ptr_vec->is_memo ) { 
    chunk_num = 0; 
  }
  else {
    chunk_num = idx / ptr_S->chunk_size;
  }
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  *ptr_chunk_dir_idx = ptr_vec->chunks[chunk_num];
  if ( *ptr_chunk_dir_idx >= ptr_S->chunk_dir->sz ) { go_BYE(-1); }
BYE:
  return status;
}
// tells us which chunk to write this element into
int 
get_chunk_num_for_write(
    const qmem_struct_t *ptr_S,
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
get_chunk_dir_idx(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    uint32_t chunk_num,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    )
{
  int status = 0;
  if ( chunk_num >= ptr_vec->sz_chunks )  { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunks[chunk_num];
  if ( chunk_dir_idx == 0 ) { // we need to set it 
    status = allocate_chunk(ptr_S, ptr_vec->chunk_size_in_bytes, 
        chunk_num, ptr_vec->uqid, &chunk_dir_idx, is_malloc); 
    cBYE(status);
    *ptr_num_chunks = *ptr_num_chunks + 1;
  }
  *ptr_chunk_dir_idx = chunk_dir_idx;
  if ( chunk_dir_idx >= ptr_S->sz_chunk_dir ) { go_BYE(-1); }
  ptr_vec->chunks[chunk_num] = chunk_dir_idx;
BYE:
  return status;
}

int
vec_new_common(
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  status = chk_fldtype(fldtype, field_width); cBYE(status);

  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));

  strncpy(ptr_vec->fldtype, fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_vec->field_width = field_width;
  ptr_vec->chunk_size_in_bytes = get_chunk_size_in_bytes(
      ptr_S, field_width, fldtype);
  ptr_vec->uqid = get_uqid(ptr_S);
  //-----------------------------
  chunk_dir = malloc(1 * sizeof(chunk_dir_t));
  return_if_malloc_failed(chunk_dir);
  memset(chunk_dir, '\0', sizeof(chunk_dir_t));
  chunk_dir->n = 0;
  chunk_dir->chunks = malloc(chunk_dir->sz * sizeof(CHUNK_REC_TYPE));
  return_if_malloc_failed(chunk_dir->chunks);
  chunk_dir->sz = Q_INITIAL_SZ_CHUNK_DIR;
  ptr_vec->chunk_dir = chunk_dir; 
  //-----------------------------


  ptr_vec->is_memo = true; // default behavior
BYE:
  return status;
}
//---------------------
int
delete_chunk_file(
    const CHUNK_REC_TYPE *ptr_chunk,
    bool *ptr_is_file
    )
{
  int status = 0;
  if ( ptr_chunk->is_file ) {
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
    cBYE(status);
    if ( !isfile(file_name) ) { go_BYE(-1); }
    status = remove(file_name); cBYE(status);
  }
BYE:
  *ptr_is_file = false;
  return status;
}


int
reincarnate(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_v,
    char **ptr_X,
    bool is_clone
    )
{
  int status = 0;
  size_t nX = 65536;
#define BUFLEN 65535
  char *buf = NULL;
  char *X = NULL;

  // check status of vector 
  if ( ptr_v->is_dead ) { go_BYE(-1); }
  if ( ptr_v->num_writers > 0 ) { go_BYE(-1); }
  if ( !ptr_v->is_eov ) { go_BYE(-1); }
  //--------------
  buf = malloc(BUFLEN+1);
  return_if_malloc_failed(buf);
  memset(buf, '\0', BUFLEN+1);

  X = malloc(nX);
  return_if_malloc_failed(X);
  memset(X, '\0', nX);

  strcpy(buf, " return { ");
  safe_strcat(&X, &nX, buf);

  sprintf(buf, "qtype = \"%s\", ", ptr_v->fldtype); 
  safe_strcat(&X, &nX, buf);

  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_v->num_elements); 
  safe_strcat(&X, &nX, buf);

  sprintf(buf, "chunk_size = %d, ", ptr_S->chunk_size);
  safe_strcat(&X, &nX, buf);

  sprintf(buf, "width = %u, ", ptr_v->field_width); 
  safe_strcat(&X, &nX, buf);

  char old_file_name[Q_MAX_LEN_FILE_NAME+1];
  char new_file_name[Q_MAX_LEN_FILE_NAME+1];

  uint64_t old_vec_uqid = ptr_v->uqid; 
  status = mk_file_name(old_vec_uqid, old_file_name,Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  if ( is_clone ) { 
    uint64_t new_vec_uqid = get_uqid(ptr_S);
    if ( ptr_v->is_file ) {
      status = mk_file_name(new_vec_uqid, new_file_name,Q_MAX_LEN_FILE_NAME); 
      status = copy_file(old_file_name, new_file_name); cBYE(status);
    }
    sprintf(buf, "vec_uqid = %" PRIu64 ",",  new_vec_uqid);
  }
  else {
    sprintf(buf, "vec_uqid = %" PRIu64 ",",  old_vec_uqid);
  }
  safe_strcat(&X, &nX, buf);
  //-------------------------------------------------------
  // no master file => either 
  // (1) all chunk files must exist. 
  // (2) chunk data must exist 
  if ( !ptr_v->is_file ) { 
    for ( unsigned int i = 0; i < ptr_v->num_chunks; i++ ) { 
      uint32_t chunk_idx = ptr_v->chunks[i];
      chk_chunk_idx(chunk_idx);
      CHUNK_REC_TYPE *ptr_c = ptr_S->chunk_dir + chunk_idx;
      uint64_t old_uqid = ptr_c->uqid; 
      status = mk_file_name(old_uqid, old_file_name,Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      if ( ( !isfile(old_file_name) ) && ( ptr_c->data == NULL ) ) { 
        go_BYE(-1);
      }
    }
  }
  //------------------------------------------------------------
  safe_strcat(&X, &nX, "chunk_uqids = { ");
  for ( unsigned int i = 0; i < ptr_v->num_chunks; i++ ) { 
    uint32_t chunk_idx = ptr_v->chunks[i];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *ptr_c = ptr_S->chunk_dir + chunk_idx;
    uint64_t old_uqid = ptr_c->uqid; 
    status = mk_file_name(old_uqid, old_file_name,Q_MAX_LEN_FILE_NAME); 
    cBYE(status);
    if ( is_clone ) { 
      uint64_t new_uqid = get_uqid(ptr_S);
      status = mk_file_name(new_uqid, new_file_name,Q_MAX_LEN_FILE_NAME); 
      if ( ptr_c->is_file ) { 
        status = copy_file(old_file_name, new_file_name); cBYE(status);
      }
      sprintf(buf, "%" PRIu64 ",",  new_uqid);
    }
    else {
      sprintf(buf, "%" PRIu64 ",",  old_uqid);
    }
    safe_strcat(&X, &nX, buf);
  }
  safe_strcat(&X, &nX, " }  ");
  safe_strcat(&X, &nX, " }  ");
  *ptr_X = X;
BYE:
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
// This should be invoked only when a master file exists 
int
vec_clean_chunks(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  if ( ptr_vec->is_file == false ) { go_BYE(-1); }
  uint32_t lb = 0;
  uint32_t ub = ptr_vec->num_chunks; 
  for ( unsigned int i = lb; i < ub; i++ ) { 
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    uint32_t chunk_idx = ptr_vec->chunks[i];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *ptr_chunk = ptr_S->chunk_dir + chunk_idx;
    if ( ptr_chunk->is_file ) { // flush buffer only if NO backup 
      memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
      status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME);
      cBYE(status);
      status = remove(file_name); cBYE(status);
      ptr_chunk->is_file = false;
    }
    free_if_non_null(ptr_chunk->data);
  }
BYE:
  return status;
}

