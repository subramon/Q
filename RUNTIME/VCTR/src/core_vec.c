#include "q_incs.h"
#include "vec_macros.h"
#include "core_vec.h"
#include "aux_qmem.h"
#include "aux_core_vec.h"
#include "cmem.h"

#include "copy_file.h"
#include "file_exists.h"
#include "get_file_size.h"
#include "isfile.h"
#include "isdir.h"
#include "rdtsc.h"
#include "rs_mmap.h"
#include "txt_to_I4.h"

#include "lauxlib.h"


typedef struct _vec_uqid_chunk_num_rec_type {
  uint64_t vec_uqid;
  uint32_t chunk_num;
} VEC_UQID_CHUNK_NUM_REC_TYPE;


static int
sortfn2(
    const void *p1, 
    const void *p2
    )
{
  const uint64_t *r1 = (const uint64_t *)p1;
  const uint64_t *r2 = (const uint64_t *)p2;
  if ( *r1 < *r2 ) { 
    return -1;
  }
  else  {
    return 1;
  }
}

static int
sortfn(
    const void *p1, 
    const void *p2
    )
{
  const VEC_UQID_CHUNK_NUM_REC_TYPE *r1 = (const VEC_UQID_CHUNK_NUM_REC_TYPE *)p1;
  const VEC_UQID_CHUNK_NUM_REC_TYPE *r2 = (const VEC_UQID_CHUNK_NUM_REC_TYPE *)p2;
  if ( r1->vec_uqid < r2->vec_uqid ) { 
    return -1;
  }
  else if ( r1->vec_uqid > r2->vec_uqid ) { 
    return 1;
  }
  else {
    if ( r1->chunk_num < r2->chunk_num ) { 
      return -1;
    }
    else {
      return 1;
    }
  }
}

int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char **ptr_opbuf
    )
{
  int status = 0;
  *ptr_opbuf = NULL;
  char buf[4096]; // should be large enough 
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
#define Q_MAX_LEN_FILE_NAME 63
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); cBYE(status);

  char  *opbuf = NULL; size_t bufsz = 4096; // initial size 
  opbuf = malloc(bufsz); return_if_malloc_failed(opbuf);
  memset(opbuf, '\0', bufsz);

  strcpy(buf, "return { ");
  safe_strcat(&opbuf, &bufsz, buf); 
  //------------------------------------------------
  sprintf(buf, "fldtype   = \"%s\", ", ptr_vec->fldtype);
  safe_strcat(&opbuf, &bufsz, buf); 
  sprintf(buf, "field_width   = %d, ", ptr_vec->field_width);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "uqid         = %" PRIu64 ", ", ptr_vec->uqid);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "name         = \"%s\", ", ptr_vec->name);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  // TODO P2: All the stuff from qmem_struct about chunks
  // TODO P2: All the stuff from qmem_struct about whole_vecs

  //-------------------------------------
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_killable = %s, ", ptr_vec->is_killable ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "is_eov = %s, ", ptr_vec->is_eov ? "true" : "false");
  safe_strcat(&opbuf, &bufsz, buf);
  //-------------------------------------
  sprintf(buf, "num_chunks = %" PRIu32 ", ", ptr_vec->num_chunks);
  safe_strcat(&opbuf, &bufsz, buf);
  sprintf(buf, "sz_chunks = %" PRIu32 ", ", ptr_vec->sz_chunks);
  safe_strcat(&opbuf, &bufsz, buf);

  //-------------------------------------
  strcpy(buf, "} ");
  safe_strcat(&opbuf, &bufsz, buf);
  *ptr_opbuf = opbuf;
BYE:
  return status;
}

int
vec_free(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  // printf("vec_free: Freeing vector\n");
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  if ( ptr_vec->is_dead ) {  
    // fprintf(stderr, "Freeing Vector that is already dead\n");
    return status; // TODO P4 Should this be an error?
  }
  if ( ptr_vec->num_readers > 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_writers > 0 ) { go_BYE(-1); }
  // If file has been opened, close it and delete it 
  if ( ( ptr_vec->mmap_addr  != NULL ) && ( ptr_vec->mmap_len > 0 ) )  {
    munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
    ptr_vec->mmap_addr = NULL;
    ptr_vec->mmap_len  = 0;
  }
  // delete file created for entire access
  status = delete_vec_file(ptr_vec->uqid, ptr_vec->whole_vec_dir_idx, 
      ptr_vec->is_persist, ptr_S);
  cBYE(status);
  //-- Free all chunks that you own
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    status = free_chunk(ptr_S, ptr_vec->chunks[i], ptr_vec->is_persist);  
    cBYE(status);
  }
  memset(ptr_vec->fldtype, '\0', sizeof(Q_MAX_LEN_QTYPE_NAME+1));
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  ptr_vec->is_dead = true;
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  return status;
}
// vec_delete is *almost* identical as vec_free but hard delete of files
int
vec_delete(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  ptr_vec->is_persist = false; // IMPORTANT 
  status = vec_free(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width
    )
{
  int status = 0;

  status = vec_new_common(ptr_vec, fldtype, field_width); 
  cBYE(status);
BYE:
  return status;
}

int 
vec_rehydrate(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const char * const fldtype,
    uint32_t field_width,
    int64_t num_elements,
    int64_t vec_uqid,
    int64_t *chunk_uqids
    )
{
  int status = 0;
  char file_name[Q_MAX_LEN_FILE_NAME+1];

  if ( num_elements == 0 ) { go_BYE(-1); }
  if ( vec_uqid == 0 ) { go_BYE(-1); }
  if ( chunk_uqids == NULL ) { go_BYE(-1); }
  if ( field_width == 0 ) { go_BYE(-1); }
  if ( fldtype == NULL ) { go_BYE(-1); }

  status = vec_new_common(ptr_vec, fldtype, field_width);
  cBYE(status);
  // Important: Normally, vec_new_common will assign a new vec_uqid
  // by calling mk_uqid(). However, given that this is a rehydration,
  // we use the vec_uqid provided, not the one generated. Hence, as below:
  ptr_vec->uqid = vec_uqid; 

  uint32_t num_chunks = ceil((double)num_elements / (double)ptr_S->chunk_size);
  status = init_chunk_dir(ptr_vec, num_chunks); cBYE(status);
  ptr_vec->num_elements = num_elements; // after init_chunk_dir()
  ptr_vec->num_chunks   = num_chunks;
  for ( uint32_t i = 0; i < num_chunks; i++ ) {
    uint32_t chunk_idx;
    status = allocate_chunk(ptr_S, 0, i, ptr_vec->uqid, 
        &chunk_idx, false); 
    cBYE(status); chk_chunk_idx(chunk_idx); 
    ptr_vec->chunks[i] = chunk_idx;
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    chunk->vec_uqid = ptr_vec->uqid;
    chunk->uqid = chunk_uqids[i]; // Important: over-write
    chunk->chunk_num = i;
    status = mk_file_name(chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME);
    if ( isfile(file_name) ) { 
      int64_t expected_file_size = get_exp_file_size(ptr_S, 
          ptr_S->chunk_size, ptr_vec->field_width, ptr_vec->fldtype);
      int64_t actual_file_size = get_file_size(file_name);
      if ( actual_file_size != expected_file_size ) { go_BYE(-1); }
      chunk->is_file = true; 
    }
  }
  //
  // Note that we just accept the master file (after some checking)
  // we do not "load" it into memory. We delay that until needed
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME);
  if ( isfile(file_name) ) { 
    int64_t expected_file_size = get_exp_file_size(ptr_S, num_elements,
        ptr_vec->field_width, ptr_vec->fldtype);
    int64_t actual_file_size = get_file_size(file_name);
    if ( actual_file_size != expected_file_size ) { go_BYE(-1); }
    ptr_vec->file_size = actual_file_size;
    ptr_vec->is_file = true; 
  }
  ptr_vec->num_elements = num_elements;
  ptr_vec->is_eov     = true;
  ptr_vec->is_persist = true;
  //------------
BYE:
  return status;
}
//-------------------------------------------------
int
check_chunks(
    const qmem_struct_t *ptr_S
    )
{
  int status = 0;
  CHUNK_REC_TYPE *chunks = ptr_S->chunk_dir->chunks;
  uint32_t sz  = ptr_S->chunk_dir->sz;
  uint32_t n   = ptr_S->chunk_dir->n;
  if ( n == 0 ) { return status;  }
  if ( n > sz ) { go_BYE(-1); }
  VEC_UQID_CHUNK_NUM_REC_TYPE *buf1 = NULL;
  uint64_t                    *buf2 = NULL;

  buf1 = malloc(n * sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE));
  return_if_malloc_failed(buf1);

  buf2 = malloc(n * sizeof(uint64_t));
  return_if_malloc_failed(buf2);

  uint32_t alt_n = 0;
  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( chunks[i].uqid == 0 ) { continue;}
    if ( alt_n >= n ) { go_BYE(-1); }
    buf1[alt_n].vec_uqid = chunks[i].vec_uqid;
    buf1[alt_n].chunk_num = chunks[i].chunk_num;
    buf2[alt_n] = chunks[i].uqid;
    alt_n++;
    // other checks 
    if ( chunks[i].num_readers < 0 ) { go_BYE(-1); }
  }
  if ( alt_n != n ) { go_BYE(-1); }
  // check uniqueness of (vec_uqid, chunk_num);
  qsort(buf1, n, sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE), sortfn);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( ( buf1[i].vec_uqid  == buf1[i-1].vec_uqid ) && 
         ( buf1[i].chunk_num == buf1[i-1].chunk_num ) ) {
      go_BYE(-1);
    }
  }
  // check uniqueness of (uqid);
  qsort(buf2, n, sizeof(uint64_t), sortfn2);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( buf2[i] == buf2[i-1] ) { go_BYE(-1); }
  }

BYE:
  free_if_non_null(buf1);
  free_if_non_null(buf2);
  return status;
}
//-------------------------------------------------
int
vec_check(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *v
    )
{
  int status = 0;
  if ( v->num_elements == 0 ) {
    if ( v->chunks      != NULL ) { go_BYE(-1); }
    if ( v->num_chunks  != 0    ) { go_BYE(-1); }
    if ( v->sz_chunks   != 0    ) { go_BYE(-1); }
    if ( v->file_size   != 0    ) { go_BYE(-1); }
    if ( v->mmap_addr   != NULL ) { go_BYE(-1); }
    if ( v->mmap_len    != 0    ) { go_BYE(-1); }
    if ( v->num_readers != 0    ) { go_BYE(-1); }
    if ( v->num_writers != 0    ) { go_BYE(-1); }

    if ( v->is_dead             ) { go_BYE(-1); }
    // TODO P2 THINK if ( v->is_eov              ) { go_BYE(-1); }
    if ( v->is_file             ) { go_BYE(-1); }
    return status;
  }
  //------------------------------------------
  if ( v->is_file ) { 
    if ( v->file_size == 0 ) { go_BYE(-1); }
  }
  else {
    if ( v->file_size   != 0    ) { go_BYE(-1); }
    if ( v->mmap_addr   != NULL ) { go_BYE(-1); }
    if ( v->mmap_len    != 0    ) { go_BYE(-1); }
    if ( v->num_readers != 0    ) { go_BYE(-1); }
    if ( v->num_writers != 0    ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( v->num_readers > 0 ) { 
    if ( v->num_writers != 0 ) { go_BYE(-1); }
  }
  if ( v->num_writers > 1 ) { go_BYE(-1); }
  if ( v->num_writers == 1 ) { 
    if ( v->num_readers != 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( v->mmap_addr != NULL ) { 
    if ( !v->is_file      ) { go_BYE(-1); }
    if ( v->mmap_len == 0 ) { go_BYE(-1); }
    if ( ( v->num_readers == 0 ) && ( v->num_writers == 0 ) )  {
      go_BYE(-1);
    }
  }
  else {
    if ( ( v->num_readers > 0 ) || ( v->num_writers > 0 ) )  {
      go_BYE(-1);
    }
  }
  //-------------------------------------------
  if ( v->is_dead ) { 
    char *cptr = (char *)v;
    for ( uint32_t i = 0; i < sizeof(VEC_REC_TYPE); i++ ) { 
      if ( *cptr != '\0' ) { go_BYE(-1); }
    }
  }
  //-------------------------------------------
  // if ( v->num_chunks < 0 ) { go_BYE(-1); }
  // if ( v->sz_chunks < 0 ) { go_BYE(-1); }
  if ( v->num_chunks > v->sz_chunks ) { go_BYE(-1); }
  //-------------------------------------------
  if ( v->chunks != NULL ) { 
    if ( v->num_chunks == 0 ) { go_BYE(-1); }
    if ( v->sz_chunks  == 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  if ( !v->is_memo ) { 
    if ( v->chunks != NULL ) { 
      if ( v->num_chunks != 1 ) { go_BYE(-1); }
      if ( v->sz_chunks  < v->num_chunks ) { go_BYE(-1); }
    }
  }
  else {
    // if ( v->num_chunks < 0 ) { go_BYE(-1); }
    // if ( v->sz_chunks < 0 ) { go_BYE(-1); }
  }
  //-------------------------------------------
  for ( uint32_t i = 0; i < v->num_chunks; i++ ) {
    status = chk_chunk(ptr_S, v, v->chunks[i], v->uqid);
    cBYE(status);
    chk_chunk_idx(v->chunks[i]);
    for ( uint32_t j = i+1; j  < v->num_chunks; j++ ) {
      if (  v->chunks[i] == v->chunks[j] ) { go_BYE(-1); }
    }
  }
  //-------------------------------------------
  if ( strcmp(v->fldtype, "B1") == 0 ) { 
    // TODO P1: How do we handle field_width for B1?
  }
  else {
    if  ( v->field_width == 0 ) { go_BYE(-1); }
    status = chk_fldtype(v->fldtype, v->field_width); cBYE(status);
  }
  if ( ptr_S->max_mem_KB < ptr_S->now_mem_KB ) { go_BYE(-1); }
BYE:
  return status;
}

int
vec_memo(
    const VEC_REC_TYPE *const ptr_vec,
    bool *ptr_is_memo,
    bool is_memo
    )
{
  int status = 0;
  // No changes about is_memo can be made once creation starts
  if ( ptr_vec->is_eov == true ) { go_BYE(-1); }
  if ( ptr_vec->num_elements > 0 ) { go_BYE(-1); }
  //----------------------------------------
  if ( ( is_memo == false ) && ( ptr_vec->is_persist == true )) {
    // If Vector is to be persisted, and you don't memoize it, you take 
    // the chance of losing it. You will get lucky if the number of 
    // elements is less than the chunk size
    // However, note that this is NOT an error
  }
  *ptr_is_memo = is_memo;
BYE:
  return status;
}

int
vec_get1(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    void **ptr_data
    )
{
  int status = 0;
  uint32_t chunk_dir_idx, in_chunk_idx;

  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  status = chunk_dir_idx_for_read(ptr_S, ptr_vec, idx, &chunk_dir_idx);
  cBYE(status);
  in_chunk_idx = idx % ptr_S->chunk_size; // identifies element within chunk

  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_dir_idx;
  status = load_chunk(chunk, ptr_vec, &(chunk->t_last_get), 
      &(chunk->data)); 
  cBYE(status);
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { 
    uint32_t word_idx = in_chunk_idx / 64;
    *ptr_data =  chunk->data + word_idx;
  }
  else {
    *ptr_data =  chunk->data + (in_chunk_idx * ptr_vec->field_width);
  }

BYE:
  return status;
}
//--------------------------------------------------
int
vec_start_read(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  if ( !ptr_vec->is_eov         ) { go_BYE(-1); }
  if ( ptr_vec->num_writers > 0 ) { go_BYE(-1); }

  ptr_vec->num_readers++; 
  if ( ptr_vec->mmap_addr == NULL ) { 
    status = make_master_file(ptr_S, ptr_vec, false); cBYE(status);
    if ( !ptr_vec->is_file ) { go_BYE(-1); }
    char *X = NULL; size_t nX = 0;
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME);
    status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
    ptr_vec->mmap_addr = X;
    ptr_vec->mmap_len  = nX;
  }
  ptr_cmem->data = ptr_vec->mmap_addr;
  ptr_cmem->size = ptr_vec->mmap_len;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;
BYE:
  return status;
}
//--------------------------------------------------
int
vec_end_read(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->mmap_addr   == NULL ) { go_BYE(-1); }
  if ( ptr_vec->mmap_len    == 0    )  { go_BYE(-1); }
  if ( ptr_vec->num_readers == 0    ) { go_BYE(-1); }

  ptr_vec->num_readers--;
  if ( ptr_vec->num_readers == 0 ) { 
    munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
    ptr_vec->mmap_addr  = NULL;
    ptr_vec->mmap_len   = 0;
  }
BYE:
  return status;
}
//--------------------------------------------------
int
vec_get_chunk(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    )
{
  int status = 0;
  if ( !ptr_vec->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); } 
  uint32_t chunk_idx = ptr_vec->chunks[chunk_num];
  chk_chunk_idx(chunk_idx);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
  status = load_chunk(chunk, ptr_vec, &(chunk->t_last_get), 
      &(chunk->data)); 
  cBYE(status);
  if ( chunk->num_readers  < 0 ) { go_BYE(-1); }
  chunk->num_readers++;

  ptr_cmem->data = chunk->data;
  ptr_cmem->size = ptr_vec->chunk_size_in_bytes;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;

  // set chunk size
  if ( chunk_num < ptr_vec->num_chunks - 1 ) {
    *ptr_num_in_chunk = ptr_S->chunk_size;
  }
  else {
    *ptr_num_in_chunk = ptr_vec->num_elements % ptr_S->chunk_size;
    if ( *ptr_num_in_chunk == 0 ) { 
      *ptr_num_in_chunk = ptr_S->chunk_size;
    }
  }
BYE:
  return status;
}
//------------------------------------------------
int
vec_shutdown(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    char **ptr_str
    )
{
  int status = 0;
  *ptr_str = NULL;

  if ( ( !ptr_vec->is_memo )  && 
      ( ptr_vec->num_elements > ptr_S->chunk_size ) ) { 
    fprintf(stderr,"We have lost data and no hope of recovering it\n");
    status = vec_delete(ptr_S, ptr_vec); cBYE(status);
    go_BYE(-1); 
  }
  // if not eov, then delete the vector
  // In other words, only eov vectors get to be saved
  if ( !ptr_vec->is_eov )  {
    status = vec_delete(ptr_S, ptr_vec); cBYE(status);
    return status;
  }
  // check if anybody is using it 
  if ( ( ptr_vec->num_readers > 0 ) || ( ptr_vec->num_writers > 0 ) ) {
    go_BYE(-1);
  }
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    if ( chunk->num_readers > 0 ) { go_BYE(-1); }
  }
  //------------------------------------------
  if ( ptr_vec->is_persist ) { 
    if ( ptr_vec->is_file ) { 
      // master file exists, no need to flush chunks individually
    }
    else {
      status = vec_make_chunk_file(ptr_S, ptr_vec, true, -1); 
      cBYE(status);
    }
    status = reincarnate(ptr_S, ptr_vec, ptr_str, false);
    cBYE(status);
  }
  status = vec_free(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status;
}
int
vec_unget_chunk(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num
    )
{
  int status = 0;
  if ( !ptr_vec->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  uint32_t chunk_idx = ptr_vec->chunks[chunk_num];
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
  if ( chunk->data     == NULL ) { go_BYE(-1); }
  if ( chunk->num_readers == 0 ) { go_BYE(-1); }
  chunk->num_readers--;
BYE:
  return status;
}
//--------------------------------------------------


int
vec_start_write(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( !ptr_vec->is_eov ) { go_BYE(-1); }
  if ( ptr_vec->num_writers != 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_readers != 0 ) { go_BYE(-1); }
  if ( !ptr_vec->is_file  ) { 
    fprintf(stderr, "TO BE IMPLEMENTED\n"); go_BYE(-1); 
  }
  if ( !ptr_vec->is_file  ) { go_BYE(-1); }
  ptr_vec->num_writers = 1;
  // delete chunks since they no longer reflect reality
  status = vec_clean_chunks(ptr_S, ptr_vec);
  cBYE(status);
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  rs_mmap(file_name, &X, &nX, 1); cBYE(status);
  // Set the CMEM that will be consumed by caller
  ptr_vec->mmap_addr = ptr_cmem->data     = X;
  ptr_vec->mmap_len  = ptr_cmem->size     = nX;
  ptr_cmem->is_foreign = true;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);

BYE:
  return status;
}

int
vec_end_write(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->num_writers != 1 ) { go_BYE(-1); }
  if ( ptr_vec->mmap_addr  == NULL ) { go_BYE(-1); }
  if ( ptr_vec->mmap_len   == 0    )  { go_BYE(-1); }
  munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
  ptr_vec->mmap_addr  = NULL;
  ptr_vec->mmap_len   = 0;
  ptr_vec->num_writers = 0; 
BYE:
  return status;
}

int
vec_kill(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( !ptr_vec->is_killable ) { return status; } // ignore if necessary
  status = vec_delete(ptr_S, ptr_vec); cBYE(status);
BYE:
  return status;
}

int
vec_killable(
    VEC_REC_TYPE *ptr_vec,
    bool is_killable
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->num_elements > 0 ) { go_BYE(-1); }
  ptr_vec->is_killable = is_killable;
BYE:
  return status;
}

int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  ptr_vec->is_persist = is_persist;
BYE:
  return status;
}

int
vec_set_name(
    VEC_REC_TYPE *ptr_vec,
    const char * const name
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  
  memset(ptr_vec->name, '\0', Q_MAX_LEN_INTERNAL_NAME+1);
  status = chk_name(name); cBYE(status);
  strncpy(ptr_vec->name, name, Q_MAX_LEN_INTERNAL_NAME);
BYE:
  return status;
}

char *
vec_get_name(
    VEC_REC_TYPE *ptr_vec
    )
{
  return ptr_vec->name;
}

int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { return status; }
  ptr_vec->is_eov = true;
BYE:
  return status;
}

int
vec_put_chunk(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t num_elements
    )
{
  int status = 0;
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_vec  == NULL ) { go_BYE(-1); }
  if ( ptr_cmem == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }

  if ( num_elements == 0 ) { num_elements = ptr_S->chunk_size; }
  if ( num_elements > ptr_S->chunk_size ) { go_BYE(-1); }
  const char * const data = ptr_cmem->data;
  if ( data == NULL ) { go_BYE(-1); }

  bool is_malloc;
  if ( ptr_cmem->is_stealable ) {
    is_malloc = false;
  }
  else {
    is_malloc = true;
  }
  //-----------------------------------------
  status = init_chunk_dir(ptr_vec, -1); cBYE(status);
  // number of elements must be a multiple of ptr_S->chunk_size
  if ( !is_multiple(ptr_vec->num_elements, ptr_S->chunk_size) ) { 
    go_BYE(-1); 
  }
  uint32_t chunk_num, chunk_idx;
  if ( !ptr_vec->is_memo ) {
    chunk_num = 0;
    if ( ptr_vec->num_chunks == 0 ) { // indicating no allocation done 
      status = allocate_chunk(ptr_S, ptr_vec->chunk_size_in_bytes, 
          chunk_num, ptr_vec->uqid, &chunk_idx, is_malloc); 
      cBYE(status);
      if ( chunk_idx >= ptr_S->chunk_dir->sz ) { go_BYE(-1); }
      if ( !is_malloc ) {
        ptr_cmem->is_foreign   = true;
        ptr_S->chunk_dir->chunks[chunk_idx].data = ptr_cmem->data;
      }
      ptr_vec->chunks[chunk_num] = chunk_idx;
      ptr_vec->num_chunks = 1;
    }
    else {
      chunk_idx = ptr_vec->chunks[chunk_num];
    }
    // if memo and stealable, then you have stolen CMEM by now
    // This means that the write done by the generator was into the
    // first chunk of this Vector and there is nothing more to do 
    if ( ptr_cmem->is_stealable ) { 
      ptr_vec->num_elements += num_elements;
      return 0;
    }
  }
  else {
    status = get_chunk_num_for_write(ptr_S, ptr_vec, &chunk_num); 
    cBYE(status);
    status = get_chunk_dir_idx(ptr_S, ptr_vec, chunk_num, 
        &(ptr_vec->num_chunks), &chunk_idx, is_malloc); 
    cBYE(status);
    // if NOT memo and stealable, then you have stolen CMEM by now
    // This means that Vector took the CMEM from the generator
    // as the data for its chunk and there is nothing more to do 
    if ( !is_malloc ) { 
      ptr_cmem->is_foreign   = true;
      ptr_S->chunk_dir->chunks[chunk_idx].data = ptr_cmem->data;
      ptr_cmem->data = NULL;
      ptr_cmem->size = 0;
      // following to tell cmem that it is okay for data to be NULL
      // when its free is invoked
      strcpy(ptr_cmem->fldtype, "XXX");
      strcpy(ptr_cmem->cell_name, "Uninitialized");
      //-----
      ptr_vec->num_elements += num_elements;
      return 0;
    }
  }
  chk_chunk_idx(chunk_idx);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;

  size_t sz = num_elements * ptr_vec->field_width;
  // handle special case for B1
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { 
    sz = ceil((double)num_elements / 8.0); 
  }
  l_memcpy(chunk->data, data, sz);

  ptr_vec->num_elements += num_elements;
  ptr_vec->chunks[chunk_num] = chunk_idx;

BYE:
  return status;
}


int
vec_put1(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    const void * const data
    )
{
  int status = 0;
  // START: Do some basic checks
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_S->chunk_size == 0 ) { go_BYE(-1); }
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  //---------------------------------------
  status = init_chunk_dir(ptr_vec, -1); cBYE(status);
  uint32_t chunk_num, chunk_idx;
  status = get_chunk_num_for_write(ptr_S, ptr_vec, &chunk_num); 
  cBYE(status);
  status = get_chunk_dir_idx(ptr_S, ptr_vec, chunk_num, 
      &(ptr_vec->num_chunks), &chunk_idx, true); 
  cBYE(status);
  CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) {
    // Unfortunately, need to handle B1 as a special case
    uint32_t num_in_chunk = ptr_vec->num_elements % ptr_S->chunk_size;
    const uint64_t *const in_bdata = (const uint64_t *const )data;
    uint64_t *out_bdata = (uint64_t *)chunk->data;
    uint64_t word_idx = num_in_chunk / 64;
    uint64_t  bit_idx = num_in_chunk % 64;
    uint64_t one = 1 ;
    uint64_t mask = one << bit_idx;
    /*
      int buflen = 32;
      char buf[buflen];
      memset(buf, '\0', buflen);
      as_hex(mask, buf, buflen);
      printf("%llu, %llu, %s \n", n_put1, *in_bdata, buf);
    */
    if ( *in_bdata == 0 ) { 
      mask = ~mask;
      out_bdata[word_idx] &= mask;
    }
    else if ( *in_bdata == 1 ) { 
      out_bdata[word_idx] |= mask;
    }
    else {
      go_BYE(-1);
    }
  }
  else {
    uint32_t in_chunk_idx = ptr_vec->num_elements % ptr_S->chunk_size;
    uint32_t offset = (in_chunk_idx*ptr_vec->field_width);
    char *data_ptr = chunk->data + offset;
    l_memcpy(data_ptr, data, ptr_vec->field_width);
  }
  ptr_vec->num_elements++;
BYE:
  return status;
}

int
vec_make_chunk_file(
    const qmem_struct_t *ptr_S,
    const VEC_REC_TYPE *const ptr_vec,
    bool is_free_mem,
    int chunk_num
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  uint32_t lb, ub;
  if ( chunk_num < 0 ) { 
    lb = 0;
    ub = ptr_vec->num_chunks; 
  }
  else {
    if ( (uint32_t)chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
    lb = chunk_num;
    ub = lb + 1; 
  }
  for ( unsigned int i = lb; i < ub; i++ ) { 
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    uint32_t chunk_idx = ptr_vec->chunks[i];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    if ( !chunk->is_file ) { 
      memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
      status = mk_file_name(chunk->uqid,file_name,Q_MAX_LEN_FILE_NAME);
      cBYE(status);
      if ( chunk->data == NULL ) { go_BYE(-1); }
      FILE *fp = fopen(file_name, "wb");
      return_if_fopen_failed(fp, file_name, "wb");
      fwrite(chunk->data, ptr_vec->chunk_size_in_bytes, 1, fp);
      fclose(fp);
      chunk->is_file = true;
    }
    if ( is_free_mem ) { 
      free_if_non_null(chunk->data);
    }
  }
BYE:
  return status;
}

int
vec_master(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    bool is_free_mem
    )
{
  int status = 0;
  status = make_master_file(ptr_S, ptr_vec, is_free_mem); cBYE(status);
BYE:
  return status;
}

int
vec_make_chunk_files(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    bool is_free_mem
    )
{
  int status = 0;

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  if ( ptr_vec->is_dead ) { go_BYE(-1); }

  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    status = vec_make_chunk_file(ptr_S, ptr_vec, i, is_free_mem);
    cBYE(status);
  }
BYE:
  return status;
}

int
vec_file_name(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    int32_t chunk_num,
    char *file_name,
    int len_file_name
    )
{
  int status = 0;

  if ( chunk_num == -1 ) { // want file name for vector 
    status = mk_file_name(ptr_vec->uqid, file_name, len_file_name); 
    cBYE(status);
  }
  else if ( chunk_num >= 0 ) {
    if ( (uint32_t)chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
    uint32_t chunk_idx = ptr_vec->chunks[chunk_num];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    status = mk_file_name(chunk->uqid, file_name, len_file_name); 
    cBYE(status);
  }
  else { 
    go_BYE(-1);
  }
BYE:
  return status;
}

int
vec_unmaster(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if  (  ptr_vec->is_dead ) { go_BYE(-1); }
  if  ( !ptr_vec->is_memo ) { go_BYE(-1); }
  if  ( !ptr_vec->is_file ) { return status; } // nothing to do 

  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    if ( ( chunk->is_file ) || ( chunk->data != NULL ) ) {
      /* all is well */
    }
    else {
      status = load_chunk(chunk, ptr_vec, &(chunk->t_last_get), 
          &(chunk->data)); 
      cBYE(status);
    }
  }
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  status = remove(file_name); cBYE(status);
  ptr_vec->is_file = false;
  ptr_vec->file_size = 0;
BYE:
  return status;
}
//--------------------------------------------
int
vec_delete_chunk_file(
    const qmem_struct_t *ptr_S,
    VEC_REC_TYPE *ptr_vec,
    int chunk_num
    )
{
  int status = 0;
  uint32_t lb, ub;
  if  ( ptr_vec->is_dead ) { go_BYE(-1); }
  if  ( !ptr_vec->is_memo ) { go_BYE(-1); }
  if ( (uint32_t)chunk_num > ptr_vec->num_chunks ) { go_BYE(-1); }
  if ( chunk_num < 0 ) { // delete ALL chunks 
    lb = 0;
    ub = ptr_vec->num_chunks;
  }
  else { // delete specified chunk
    lb = chunk_num;
    ub = lb + 1;
  }
  for ( uint32_t i = lb; i < ub; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *chunk = ptr_S->chunk_dir->chunks + chunk_idx;
    if ( !chunk->is_file ) { continue; }
    // can delete either if data in memory or master file exists
    if  ( ( ptr_vec->is_file ) || ( chunk->data != NULL ) ) {
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(chunk->uqid,file_name,Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      status = remove(file_name); cBYE(status);
      chunk->is_file = false;
    }
    else { // cannot delete the file; will cause loss of data 
      // TODO P4 Above statement is not strictly true, 
      // One can load from master file if it exists
      go_BYE(-1);
    }
  }
BYE:
  return status;
}
int
vec_same_state(
    VEC_REC_TYPE *ptr_v1,
    VEC_REC_TYPE *ptr_v2
    )
{
  int status = 0;
  if ( ptr_v1 == NULL ) { go_BYE(-1); }
  if ( ptr_v2 == NULL ) { go_BYE(-1); }
  if ( ptr_v1->num_elements != ptr_v2->num_elements ) { go_BYE(-1); }
  if ( ptr_v1->is_eov != ptr_v2->is_eov ) { go_BYE(-1); }
  if ( ptr_v1->is_memo != ptr_v2->is_memo ) { go_BYE(-1); }
  if ( ptr_v1->is_persist != ptr_v2->is_persist ) { go_BYE(-1); }
BYE:
  return status;
}
