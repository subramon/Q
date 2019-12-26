#include "q_incs.h"
#include "core_vec.h"
#include "aux_core_vec.h"
#include "cmem.h"
#include "vec_globals.h"
#include "buf_to_file.h"
#include "copy_file.h"

#include "_file_exists.h"
#include "_get_file_size.h"
#include "_isfile.h"
#include "_isdir.h"
#include "_rdtsc.h"
#include "_rs_mmap.h"
#include "_txt_to_I4.h"

#include "lauxlib.h"

#define chk_chunk_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= g_sz_chunk_dir ) ) { go_BYE(-1); } \
}
#include "_reset_timers.c"
#include "_print_timers.c"

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
  uint64_t *r1 = (uint64_t *)p1;
  uint64_t *r2 = (uint64_t *)p2;
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
  VEC_UQID_CHUNK_NUM_REC_TYPE *r1 = (VEC_UQID_CHUNK_NUM_REC_TYPE *)p1;
  VEC_UQID_CHUNK_NUM_REC_TYPE *r2 = (VEC_UQID_CHUNK_NUM_REC_TYPE *)p2;
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
    char *opbuf
    )
{
  int status = 0;
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); cBYE(status);
  char  buf[65536]; // TODO P3 Need to avoid static allocation
  memset(buf, '\0', 65536);
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  strcpy(opbuf, "return { ");
  //------------------------------------------------
  sprintf(buf, "fldtype   = \"%s\", ", ptr_vec->fldtype);
  strcat(opbuf, buf);
  sprintf(buf, "field_width   = %d, ", ptr_vec->field_width);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_size_in_bytes   = %" PRIu32 ", ", ptr_vec->chunk_size_in_bytes);
  strcat(opbuf, buf);
  sprintf(buf, "uqid         = %" PRIu64 ", ", ptr_vec->uqid);
  strcat(opbuf, buf);

  //-------------------------------------
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  strcat(opbuf, buf);
  sprintf(buf, "name         = \"%s\", ", ptr_vec->name);
  strcat(opbuf, buf);

  //-------------------------------------
  sprintf(buf, "is_file = %s, ", ptr_vec->is_file ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "file_name    = \"%s\", ", file_name);
  strcat(opbuf, buf);
  sprintf(buf, "file_size    = %" PRIu64 ", ", ptr_vec->file_size);
  strcat(opbuf, buf);
  sprintf(buf, "num_readers   = %d, ", ptr_vec->num_readers);
  strcat(opbuf, buf);
  sprintf(buf, "num_writers   = %d, ", ptr_vec->num_writers);
  strcat(opbuf, buf);

  //-------------------------------------
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_eov = %s, ", ptr_vec->is_eov ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_no_memcpy = %s, ", ptr_vec->is_no_memcpy ? "true" : "false");
  strcat(opbuf, buf);
  //-------------------------------------
  sprintf(buf, "num_chunks = %" PRIu32 ", ", ptr_vec->num_chunks);
  strcat(opbuf, buf);
  sprintf(buf, "sz_chunks = %" PRIu32 ", ", ptr_vec->sz_chunks);
  strcat(opbuf, buf);
  // TODO P1 Need to print information about chunks in vector

  //-------------------------------------
  strcat(opbuf, "} ");
BYE:
  return status;
}

int
vec_free(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_free++;
  // printf("vec_free: Freeing vector\n");
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  if ( ptr_vec->is_dead ) {  
    fprintf(stderr, "Freeing Vector that is already dead\n");
    return status; // TODO Should this be an error?
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
  status = delete_vec_file(ptr_vec, &(ptr_vec->is_file), &(ptr_vec->file_size));
  cBYE(status);
  //-- Free all chunks that you own
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    status = free_chunk(ptr_vec->chunks[i], ptr_vec->is_persist);  
    cBYE(status);
  }
  memset(ptr_vec->fldtype, '\0', sizeof(Q_MAX_LEN_QTYPE_NAME+1));
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  ptr_vec->is_dead = true;
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_free += delta; }
  return status;
}
// vec_delete is *almost* identical as vec_free but hard delete of files
int
vec_delete(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  ptr_vec->is_persist = false; // IMPORTANT 
  status = vec_free(ptr_vec); cBYE(status);
BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_new++;

  status = vec_new_common(ptr_vec, field_type, field_width); cBYE(status);
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_new += delta; }
  return status;
}

int 
vec_rehydrate_multi(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_rehydrate_multi++;

  status = vec_new_common(ptr_vec, field_type, field_width); cBYE(status);
  fprintf(stderr," TODO: To be implemented  \n"); go_BYE(-1); 
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_rehydrate_multi += delta; }
  return status;
}

int 
vec_rehydrate_single(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_rehydrate_single++;

  status = vec_new_common(ptr_vec, field_type, field_width); cBYE(status);
  //
  // Note that we just accept the file (after some checking)
  // we do not "load" it into memory. We delay that until needed
  if ( !isfile(file_name) ) { go_BYE(-1); }
  int64_t expected_file_size = get_exp_file_size(ptr_vec->num_elements,
      ptr_vec->field_width, ptr_vec->fldtype);
  int64_t actual_file_size = get_file_size(file_name);
  if ( actual_file_size != expected_file_size ) { go_BYE(-1); }
  ptr_vec->file_size = actual_file_size;
  //------------
  // IMPORTANT: File gets renamed
  char new_file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, new_file_name, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  status = rename(file_name, new_file_name);
  //--------------------
  ptr_vec->is_eov    = true;
  ptr_vec->is_memo   = true;
  //------------
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_rehydrate_single += delta; }
  return status;
}

int
g_check_chunks(
    CHUNK_REC_TYPE *chunk_dir,
    uint32_t sz,
    uint32_t n
    )
{
  int status = 0;
  if ( n == 0 ) { return status;  }
  if ( n > sz ) { go_BYE(-1); }
  VEC_UQID_CHUNK_NUM_REC_TYPE *buf = NULL;
  uint64_t *buf2 = NULL;

  buf = malloc(n * sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE));
  return_if_malloc_failed(buf);

  buf2 = malloc(n * sizeof(uint64_t));
  return_if_malloc_failed(buf2);

  uint32_t alt_n = 0;
  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( chunk_dir[i].uqid == 0 ) { continue;}
    if ( alt_n >= n ) { go_BYE(-1); }
    buf[alt_n].vec_uqid = chunk_dir[i].vec_uqid;
    buf[alt_n].chunk_num = chunk_dir[i].chunk_num;
    buf2[alt_n] = chunk_dir[i].uqid;
    alt_n++;
    // other checks 
    if ( chunk_dir[i].num_readers < 0 ) { go_BYE(-1); }
    if ( chunk_dir[i].num_writers < 0 ) { go_BYE(-1); }
    if ( ( chunk_dir[i].num_readers > 0 ) && 
         ( chunk_dir[i].num_writers > 0 ) ) { 
      go_BYE(-1); 
    }
  }
  if ( alt_n != n ) { go_BYE(-1); }
  // check uniqueness of (vec_uqid, chunk_num);
  qsort(buf, n, sizeof(VEC_UQID_CHUNK_NUM_REC_TYPE), sortfn);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( ( buf[i].vec_uqid = buf[i-1].vec_uqid ) && 
         ( buf[i].chunk_num = buf[i-1].chunk_num ) ) {
      go_BYE(-1);
    }
  }
  // check uniqueness of (uqid);
  qsort(buf2, n, sizeof(uint64_t), sortfn2);
  for ( uint32_t i = 1; i < n; i++ )   {
    if ( buf2[i] == buf2[i-1] ) { go_BYE(-1); }
  }

BYE:
  free_if_non_null(buf);
  free_if_non_null(buf2);
  return status;


}
int
vec_check(
    VEC_REC_TYPE *v
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_check++;
  if ( v->num_elements == 0 ) {
    if ( v->chunks != NULL ) { go_BYE(-1); }
    if ( v->num_chunks != 0 ) { go_BYE(-1); }
    if ( v->sz_chunks != 0 ) { go_BYE(-1); }
    if ( v->file_size != 0 ) { go_BYE(-1); }
    if ( v->mmap_addr != NULL ) { go_BYE(-1); }
    if ( v->mmap_len  != 0 ) { go_BYE(-1); }
    if ( v->num_readers != 0 ) { go_BYE(-1); }
    if ( v->num_writers != 0 ) { go_BYE(-1); }
    if ( v->is_dead  ) { go_BYE(-1); }
    if ( v->is_eov  ) { go_BYE(-1); }
    if ( v->is_file  ) { go_BYE(-1); }
  }
  //------------------------------------------
  if ( v->is_file ) { 
    if ( v->file_size == 0 ) { go_BYE(-1); }
  }
  else {
    if ( v->file_size != 0 ) { go_BYE(-1); }
    if ( v->mmap_addr != NULL ) { go_BYE(-1); }
    if ( v->mmap_len  != 0 ) { go_BYE(-1); }
    if ( v->num_readers != 0 ) { go_BYE(-1); }
    if ( v->num_writers != 0 ) { go_BYE(-1); }
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
    if ( v->mmap_len == 0 ) { go_BYE(-1); }
    if ( ( v->num_readers == 0 ) && ( v->num_writers == 0 ) )  {
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
    status = chk_chunk(v->chunks[i], v->uqid);
    cBYE(status);
  }
  for ( uint32_t i = 0; i  < v->num_chunks; i++ ) {
    if (  v->chunks[i] == 0 ) { go_BYE(-1); }
    if (  v->chunks[i] >= g_sz_chunk_dir ) { go_BYE(-1); }
    for ( uint32_t j = i+1; j  < v->num_chunks; j++ ) {
      if (  v->chunks[i] == v->chunks[j] ) { go_BYE(-1); }
    }
  }
  //-------------------------------------------
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_check += delta; }
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
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx,
    char **ptr_data
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_get1++;
  uint32_t chunk_dir_idx, in_chunk_idx;

  status = chunk_dir_idx_for_read(ptr_vec, idx, &chunk_dir_idx);
  cBYE(status);
  in_chunk_idx = idx % g_chunk_size;

  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  status = load_chunk(ptr_chunk, ptr_vec, &(ptr_chunk->t_last_get), 
      &(ptr_chunk->data)); 
  cBYE(status);
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { 
    uint32_t word_idx = in_chunk_idx / 64;
    *ptr_data =  ptr_chunk->data + word_idx;
  }
  else {
    *ptr_data =  ptr_chunk->data + (in_chunk_idx * ptr_vec->field_width);
  }

BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_get1 += delta; }
  return status;
}
//--------------------------------------------------
int
vec_start_read(
    VEC_REC_TYPE *ptr_vec,
    char **ptr_data,
    uint64_t *ptr_num_elements,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_get_all++;
  if ( !ptr_vec->is_eov ) { go_BYE(-1); }
  if ( ptr_vec->num_writers > 0 ) { go_BYE(-1); }
  ptr_vec->num_readers++;
  *ptr_num_elements = ptr_vec->num_elements;
  if ( *ptr_num_elements == 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks == 1 ) { 
    // handle special case where everything fits in one chunk
    uint32_t chunk_idx = ptr_vec->chunks[0];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    status = load_chunk(ptr_chunk, ptr_vec, &(ptr_chunk->t_last_get), 
        &(ptr_chunk->data)); 
    cBYE(status);
    ptr_chunk->num_readers++;
    ptr_cmem->data = ptr_chunk->data;
    ptr_cmem->size = ptr_vec->chunk_size_in_bytes;
  }
  else {
    if ( ptr_vec->mmap_addr == NULL ) { 
      char *X = NULL; size_t nX = 0;
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME);
      status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
      ptr_vec->mmap_addr = X;
      ptr_vec->mmap_len  = nX;
    }
    ptr_cmem->data = ptr_vec->mmap_addr;
    ptr_cmem->size = ptr_vec->mmap_len;
    ptr_vec->num_readers++;
  }
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_get_all += delta; }
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
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_get_chunk++;
  if ( !ptr_vec->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); } 
  uint32_t chunk_idx = ptr_vec->chunks[chunk_num];
  chk_chunk_idx(chunk_idx);
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
  status = load_chunk(ptr_chunk, ptr_vec, &(ptr_chunk->t_last_get), 
      &(ptr_chunk->data)); 
  cBYE(status);
  if ( ptr_chunk->num_writers  > 0 ) { go_BYE(-1); }
  if ( ptr_chunk->num_readers  < 0 ) { go_BYE(-1); }
  ptr_chunk->num_readers++;

  ptr_cmem->data = ptr_chunk->data;
  ptr_cmem->size = ptr_vec->chunk_size_in_bytes;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;

  // set chunk size
  if ( chunk_num < ptr_vec->num_chunks - 1 ) {
    *ptr_num_in_chunk = g_chunk_size;
  }
  else {
    *ptr_num_in_chunk = ptr_vec->num_elements % g_chunk_size;
    if ( *ptr_num_in_chunk == 0 ) { 
      *ptr_num_in_chunk = g_chunk_size;
    }
  }
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_get_chunk += delta; }
  return status;
}
//------------------------------------------------
int
vec_shutdown(
    VEC_REC_TYPE *ptr_vec,
    char **ptr_str_to_reincarnate
    )
{
  int status = 0;
  *ptr_str_to_reincarnate = NULL;

  if (( !ptr_vec->is_memo )  && ( ptr_vec->num_elements > g_chunk_size )){ 
      // We have lost data and there is no hope of recovering it
      go_BYE(-1); 
  }
  if ( !ptr_vec->is_eov )  {
    status = vec_delete(ptr_vec); cBYE(status);
    return status;
  }
  // check if anybody is using it 
  if ( ( ptr_vec->num_readers > 0 ) || ( ptr_vec->num_writers > 0 ) ) {
    go_BYE(-1);
  }
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    if ( ( ptr_chunk->num_readers > 0 )||( ptr_chunk->num_writers > 0 ) ) {
      go_BYE(-1);
    }
  }
  //------------------------------------------
  status = vec_backup(ptr_vec); cBYE(status);
  if ( ptr_vec->is_persist ) { 
    status = reincarnate(ptr_vec, ptr_str_to_reincarnate);  cBYE(status);
  }
  status = vec_free(ptr_vec); cBYE(status);
BYE:
  return status;
}
//------------------------------------------------
int
vec_backup(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( !ptr_vec->is_eov  ) { go_BYE(-1); }
  if ( ptr_vec->is_file ) { return status; }
  if ( !ptr_vec->is_memo ) {  
    status = vec_flush_chunk(ptr_vec, false, 0); cBYE(status);
  }
  else {
    status = vec_flush_chunk(ptr_vec, false, -1); cBYE(status);
  }
BYE:
  return status;
}
//------------------------------------------------
int
vec_unget_chunk(
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num
    )
{
  int status = 0;
  if ( !ptr_vec->is_memo ) { chunk_num = 0; } // Important
  if ( chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  uint32_t chunk_idx = ptr_vec->chunks[chunk_num];
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
  if ( ptr_chunk->data     == NULL ) { go_BYE(-1); }
  if ( ptr_chunk->num_writers  > 0 ) { go_BYE(-1); }
  if ( ptr_chunk->num_readers == 0 ) { go_BYE(-1); }
  ptr_chunk->num_readers--;
BYE:
  return status;
}
//--------------------------------------------------


int
vec_start_write(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_start_write++;
  char *X = NULL; size_t nX = 0;
  if ( !ptr_vec->is_eov ) { go_BYE(-1); }
  if ( ptr_vec->num_writers != 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_readers != 0 ) { go_BYE(-1); }
  if ( !ptr_vec->is_file  ) { 
    fprintf(stderr, "TO BE IMPLEMENTED\n"); go_BYE(-1); 
  }
  if ( !ptr_vec->is_file  ) { go_BYE(-1); }

  char file_name[Q_MAX_LEN_FILE_NAME+1];
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  rs_mmap(file_name, &X, &nX, 1); cBYE(status);
  ptr_vec->mmap_addr = ptr_cmem->data     = X;
  ptr_vec->mmap_len  = ptr_cmem->size     = nX;
  ptr_cmem->is_foreign = true;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);

  ptr_vec->num_writers = 1;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_start_write += delta; }
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
vec_no_memcpy(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    size_t chunk_size
    )
{
  int status = 0;
#ifdef XXX
  if (  ptr_vec  == NULL        ) { go_BYE(-1); }
  if (  ptr_vec->chunk != NULL  ) { go_BYE(-1); }
  if (  ptr_vec->is_eov         ) { go_BYE(-1); }
  if (  ptr_vec->file_size != 0 ) { go_BYE(-1); }

  if (  ptr_cmem == NULL        ) { go_BYE(-1); }
  if ( ptr_cmem->is_foreign     ) { go_BYE(-1); }
  if ( ptr_cmem->data == NULL   ) { go_BYE(-1); }
  if ( ptr_cmem->size <= 0      ) { go_BYE(-1); }

  ptr_vec->chunk_sz = (ptr_vec->field_width * ptr_vec->chunk_size);
  // The CMEM must be the same size as the buffer that the Vector
  // would have allocated had it allocated it on its own
  if ( ptr_cmem->size != ptr_vec->chunk_sz ) { 
    go_BYE(-1); 
  }
  //------------------------------------
  ptr_vec->uqid  = RDTSC();
  ptr_vec->chunk = ptr_cmem->data;
  // ptr_vec->chunk_sz = ptr_cmem->size;
  // This is a necessary pre-condition ptr_vec->chunk_size = chunk_size; 
  ptr_vec->is_no_memcpy = true;
  ptr_cmem->is_foreign = true; // de-allocation is for Vector not CMEM

BYE:
#endif
  return status;
}


int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { 
    // fprintf(stderr, "Already eov, nothing to do\n"); 
    return status; 
  } 
  ptr_vec->is_eov = true;
BYE:
  return status;
}

int
vec_put_chunk(
    VEC_REC_TYPE *ptr_vec,
    const char * const data,
    uint32_t num_elements,
    int64_t size // for debugging only
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_put_chunk++;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data  == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_dead ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }

  if ( num_elements == 0 ) { num_elements = g_chunk_size; }
  if ( num_elements > g_chunk_size ) { go_BYE(-1); }
  if ( size > ptr_vec->chunk_size_in_bytes ) { go_BYE(-1); } 
  //-----------------------------------------
  status = init_chunk_dir(ptr_vec); cBYE(status);
  // is previous chunk full 
  if ( ( ( ptr_vec->num_elements / g_chunk_size ) * g_chunk_size ) !=
           ptr_vec->num_elements ) {
    go_BYE(-1);
  }
  uint32_t chunk_num, chunk_idx;
  if ( !ptr_vec->is_memo ) {
    if ( ptr_vec->num_chunks == 0 ) { // indicating no allocation done 
      chunk_num = 0;
      status = allocate_chunk(ptr_vec->chunk_size_in_bytes, chunk_num, 
          ptr_vec->uqid, &chunk_idx); 
      cBYE(status);
      if ( chunk_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
      ptr_vec->chunks[chunk_num] = chunk_idx;
      ptr_vec->num_chunks = 1;
    }
    else {
      chunk_idx = ptr_vec->chunks[chunk_num];
    }
  }
  else {
    status = get_chunk_num_for_write(ptr_vec, &chunk_num); cBYE(status);
    status = get_chunk_dir_idx(ptr_vec, chunk_num, ptr_vec->chunks, 
        &(ptr_vec->num_chunks), &chunk_idx); 
    cBYE(status);
  }
  chk_chunk_idx(chunk_idx);
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;

  memcpy(ptr_chunk->data, data, size);

  ptr_vec->num_elements += num_elements;
  ptr_vec->chunks[chunk_num] = chunk_idx;

BYE:
  delta = RDTSC()-t_start; if ( delta > 0 ) { t_put_chunk += delta; }
  return status;
}


int
vec_put1(
    VEC_REC_TYPE *ptr_vec,
    const char * const data
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_put1++;
  // START: Do some basic checks
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  //---------------------------------------
  status = init_chunk_dir(ptr_vec); cBYE(status);
  uint32_t chunk_num, chunk_idx;
  status = get_chunk_num_for_write(ptr_vec, &chunk_num); cBYE(status);
  status = get_chunk_dir_idx(ptr_vec, chunk_num, ptr_vec->chunks, 
      &(ptr_vec->num_chunks), &chunk_idx); 
  cBYE(status);
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) {
    // Unfortunately, need to handle B1 as a special case
    uint32_t num_in_chunk = ptr_vec->num_elements % g_chunk_size;
    uint64_t *in_bdata = (uint64_t *)data;
    uint64_t *out_bdata = (uint64_t *)ptr_chunk->data;
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
    uint32_t in_chunk_idx = ptr_vec->num_elements % g_chunk_size;
    char *data_ptr = ptr_chunk->data + (in_chunk_idx*ptr_vec->field_width);
    memcpy(data_ptr, data, ptr_vec->field_width);
  }
  ptr_vec->num_elements++;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_put1 += delta; }
  return status;
}
//------------------------------------------------------
int
vec_flush_chunk(
    const VEC_REC_TYPE *const ptr_vec,
    bool is_free_mem,
    int chunk_num
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_flush++;
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
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
    status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME);
    cBYE(status);
    if ( !ptr_chunk->is_file ) { 
      // flush buffer only if backup exists
      FILE *fp = fopen(file_name, "wb");
      return_if_fopen_failed(fp, file_name, "wb");
      fwrite(ptr_chunk->data, ptr_vec->chunk_size_in_bytes, 1, fp);
      fclose(fp);
      // data is redundant since we have backed it up in file 
      if ( is_free_mem ) { 
        free_if_non_null(ptr_chunk->data);
      }
      ptr_chunk->is_file = true;
    }
  }
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_flush += delta; }
  return status;
}

int
vec_flush_all(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  FILE *fp = NULL;
  uint64_t delta = 0, t_start = RDTSC(); n_flush++;

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  fp = fopen(file_name, "wb");
  return_if_fopen_failed(fp, file_name, "wb");
  uint64_t file_size = 0;
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    char chnk_file_name[Q_MAX_LEN_FILE_NAME+1];
    uint32_t chunk_idx = ptr_vec->chunks[i];
    chk_chunk_idx(chunk_idx);
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    if ( ptr_chunk->data == NULL ) {
      char *X = NULL; size_t nX = 0;
      memset(chnk_file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
      status = mk_file_name(ptr_chunk->uqid, chnk_file_name, Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      status = rs_mmap(chnk_file_name, &X, &nX, 0); cBYE(status);
      fwrite(X, nX, 1, fp);
      file_size += nX;
      munmap(X, nX);

    }
    else {
      fwrite(ptr_chunk->data, ptr_vec->chunk_size_in_bytes, 1, fp);
      file_size += ptr_vec->chunk_size_in_bytes;
      fflush(fp);
    }
  }
  ptr_vec->is_file = true;
  ptr_vec->file_size = file_size;
BYE:
  fclose_if_non_null(fp);
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_flush += delta; }
  return status;
}

int
vec_file_name(
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
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    status = mk_file_name(ptr_chunk->uqid, file_name, len_file_name); 
    cBYE(status);
  }
  else { 
    go_BYE(-1);
  }
BYE:
  return status;
}

int
vec_delete_master_file(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if  ( !ptr_vec->is_file ) { go_BYE(-1); }
  // can delete file only if data can be restored from elsewhere
  bool can_delete = true;
  for ( uint32_t i = 0; i < ptr_vec->num_chunks; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    if ( ( ptr_chunk->is_file ) || ( ptr_chunk->data != NULL ) ) {
      /* all is well */
    }
    else {
      can_delete = false; break;
    }
  }
  if ( can_delete ) {
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
    cBYE(status);
    status = remove(file_name); cBYE(status);
    ptr_vec->is_file = false;
    ptr_vec->file_size = 0;
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
int
vec_delete_chunk_file(
    VEC_REC_TYPE *ptr_vec,
    int chunk_num
    )
{
  int status = 0;
  uint32_t lb, ub;
  if ( (uint32_t)chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
  if ( chunk_num < 0 ) { 
    lb = 0;
    ub = ptr_vec->num_chunks;
  }
  else {
    lb = chunk_num;
    ub = lb + 1;
  }
  for ( uint32_t i = lb; i < ub; i++ ) { 
    uint32_t chunk_idx = ptr_vec->chunks[i];
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_idx;
    if ( !ptr_chunk->is_file ) { continue; }
    // can delete either if data in memory or msater file exists
    if  ( ( ptr_vec->is_file ) || ( ptr_chunk->data != NULL ) ) {
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(ptr_chunk->uqid,file_name,Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      status = remove(file_name); cBYE(status);
      ptr_chunk->is_file = false;
    }
  }
BYE:
  return status;
}
