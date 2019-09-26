#include "q_incs.h"
#include "core_vec.h"
#include "aux_core_vec.h"
#include "cmem.h"
#include "vec_globals.h"
#include "buf_to_file.h"
#include "copy_file.h"

#include "_file_exists.h"
#include "_get_file_size.h"
#include "_get_time_usec.h"
#include "_isfile.h"
#include "_isdir.h"
#include "_rdtsc.h"
#include "_rs_mmap.h"
#include "_txt_to_I4.h"

#include "lauxlib.h"

#define INITIAL_NUM_CHUNKS_PER_VECTOR 32
#define chk_chunk_dir_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= g_sz_chunk_dir ) ) { go_BYE(-1); } \
}
void
vec_reset_timers(
    void
    )
{
  printf("reset timers\n");
  t_l_vec_check = 0;        n_l_vec_check = 0;
  t_l_vec_clone = 0;        n_l_vec_clone = 0;
  t_l_vec_flush = 0;        n_l_vec_flush = 0;
  t_l_vec_free = 0;         n_l_vec_free = 0;
  t_l_vec_get1 = 0;         n_l_vec_get1 = 0;
  t_l_vec_get_all = 0;      n_l_vec_get_all = 0;
  t_l_vec_get_chunk = 0;    n_l_vec_get_chunk = 0;
  t_l_vec_new = 0;          n_l_vec_new = 0;
  t_l_vec_put1 = 0;         n_l_vec_put1 = 0;
  t_l_vec_start_write = 0;  n_l_vec_start_write = 0;

  t_malloc = 0;             n_malloc = 0;
  t_memcpy = 0;             n_memcpy = 0;
  t_memset = 0;             n_memset = 0;
}

void
vec_print_timers(
    void
    )
{
  printf("print timers\n");
  fprintf(stdout, "0,add,%u,%" PRIu64 "\n",n_l_vec_put1, t_l_vec_put1);
  fprintf(stdout, "0,check,%u,%" PRIu64 "\n",n_l_vec_check, t_l_vec_check);
  fprintf(stdout, "0,clone,%u,%" PRIu64 "\n",n_l_vec_clone, t_l_vec_clone);
  fprintf(stdout, "0,free,%u,%" PRIu64 "\n",n_l_vec_free, t_l_vec_free);
  fprintf(stdout, "0,get,%u,%" PRIu64 "\n",n_l_vec_get1, t_l_vec_get1);
  fprintf(stdout, "0,get,%u,%" PRIu64 "\n",n_l_vec_get_all, t_l_vec_get_all);
  fprintf(stdout, "0,get,%u,%" PRIu64 "\n",n_l_vec_get_chunk, t_l_vec_get_chunk);
  fprintf(stdout, "0,new,%u,%" PRIu64 "\n",n_l_vec_new, t_l_vec_new);
  fprintf(stdout, "0,start_write,%u,%" PRIu64 "\n", n_l_vec_start_write, t_l_vec_start_write);

  fprintf(stdout, "1,flush,%u,%" PRIu64 "\n", n_l_vec_flush, t_l_vec_flush);
  fprintf(stdout, "1,memcpy,%u,%" PRIu64 "\n", n_memcpy, t_memcpy);
  fprintf(stdout, "1,memset,%u,%" PRIu64 "\n", n_memset, t_memset);
  fprintf(stdout, "1,malloc,%u,%" PRIu64 "\n", n_malloc, t_malloc);
}

int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    )
{
  int status = 0;
  // TODO P1 Need to print information about chunks in vector
  char  buf[1024];
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  strcpy(opbuf, "return { ");
  //------------------------------------------------
  sprintf(buf, "fldtype   = \"%s\", ", ptr_vec->fldtype);
  strcat(opbuf, buf);
  sprintf(buf, "field_width   = %d, ", ptr_vec->field_width);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_size_in_bytes   = %" PRIu32 ", ", ptr_vec->chunk_size_in_bytes);
  strcat(opbuf, buf);
  sprintf(buf, "num_chunks = %" PRIu32 ", ", ptr_vec->num_chunks);
  strcat(opbuf, buf);
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  strcat(opbuf, buf);
  sprintf(buf, "name         = \"%s\", ", ptr_vec->name);
  strcat(opbuf, buf);
  sprintf(buf, "uqid         = %" PRIu64 ", ", ptr_vec->uqid);
  strcat(opbuf, buf);
  sprintf(buf, "file_name    = \"%s\", ", ptr_vec->file_name);
  strcat(opbuf, buf);
  sprintf(buf, "file_size    = %" PRIu64 ", ", ptr_vec->file_size);
  strcat(opbuf, buf);
  //-------------------------------------
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_mono = %s, ", ptr_vec->is_mono ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_eov = %s, ", ptr_vec->is_eov ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_no_memcpy = %s, ", ptr_vec->is_no_memcpy ? "true" : "false");
  strcat(opbuf, buf);
  switch ( ptr_vec->access_mode ) {
    case 0 : strcpy(buf, "access_mode = \"NOT_OPEN\", "); break;
    case 1 : strcpy(buf, "access_mode = \"READ\", "); break;
    case 2 : strcpy(buf, "access_mode = \"WRITE\", "); break;
    default : go_BYE(-1); break;
  }
  strcat(opbuf, buf);
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
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_free++;
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  // If file has been opened, close it and delete it 
  if ( ( ptr_vec->mmap_addr  != NULL ) && ( ptr_vec->mmap_len > 0 ) )  {
    munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
    ptr_vec->mmap_addr = NULL;
    ptr_vec->mmap_len  = 0;
  }
  // delete file created for entire access
  if ( ptr_vec->is_file ) { 
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    status = mk_file_name(ptr_vec->uqid, file_name);
    if ( !isfile(file_name) ) { WHEREAMI; /* should not happen */ }
    status = remove(ptr_vec->file_name);
    if ( status != 0 ) { /* should not happen */ WHEREAMI; }
  }
  //-- Free all chunks that you own
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    free_chunk(ptr_vec->chunk_dir_idxs[i], ptr_vec->is_persist); 
  }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_free += delta; }
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
vec_clone(
    VEC_REC_TYPE *ptr_old_vec,
    VEC_REC_TYPE *ptr_new_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_clone++;
  if ( ptr_old_vec == NULL ) { go_BYE(-1); }
  if ( ptr_new_vec == NULL ) { go_BYE(-1); }
  if ( ptr_new_vec == ptr_old_vec ) { go_BYE(-1); }
  // TODO  P1
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_clone += delta; }
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
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_new++;

  g_chunk_size = Q_CHUNK_SIZE; // TODO P2 Where should this go for real?
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  strncpy(ptr_vec->fldtype, field_type, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_vec->field_width = field_width;
  status = chk_field_type(field_type, field_width); cBYE(status);
  ptr_vec->chunk_size_in_bytes = get_chunk_size(field_width, field_type);
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_new += delta; }
  return status;
}

int 
vec_mrehydrate(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_new++;
  g_chunk_size = Q_CHUNK_SIZE; // TODO P2 Where should this go for real?
// BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_new += delta; }
  return status;
}

int 
vec_rehydrate(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width,
    int64_t num_elements,
    const char *const file_name
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_new++;
  g_chunk_size = Q_CHUNK_SIZE; // TODO P2 Where should this go for real?
  //
  // Note that we just accept the file name (after some checking)
  // we do not "load" it into memory. We delay that until needed
  if ( !isfile(file_name) ) { go_BYE(-1); }
  int64_t expected_file_size = get_exp_file_size(ptr_vec->num_elements,
      ptr_vec->field_width, ptr_vec->fldtype);
  int64_t actual_file_size = get_file_size(file_name);
  if ( actual_file_size != expected_file_size ) { go_BYE(-1); }
  //------------
  strncpy(ptr_vec->fldtype, field_type, Q_MAX_LEN_QTYPE_NAME-1);
  strncpy(ptr_vec->file_name, file_name, Q_MAX_LEN_FILE_NAME-1);
  ptr_vec->file_size = actual_file_size;
  ptr_vec->chunk_size_in_bytes = get_chunk_size(field_width, field_type);
  ptr_vec->is_eov    = true;
  ptr_vec->is_memo   = true;
  //------------
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_new += delta; }
  return status;
}

int
vec_check(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_check++;
  if ( !isdir(g_q_data_dir) ) { go_BYE(-1); }
  // cast as int64_t to avoid overflow
  /*
  int64_t chunk_num    = ptr_vec->chunk_num;
  int64_t chunk_size   = ptr_vec->chunk_size;
  int64_t chunk_sz     = ptr_vec->chunk_sz;
  int64_t num_elements = ptr_vec->num_elements;
  int64_t num_in_chunk = ptr_vec->num_in_chunk;
  if ( !ptr_vec->is_memo ) { if ( ptr_vec->is_mono ) { go_BYE(-1); } }
  if ( ptr_vec->is_no_memcpy ) { if ( ptr_vec->chunk == NULL ) { go_BYE(-1); } }
  */
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_check += delta; }
  return status;
}

int
vec_mono(
    VEC_REC_TYPE *ptr_vec,
    bool is_mono
    )
{
  int status = 0;
  // Note that all error handling is done at the time memo was set to true
  if ( !ptr_vec->is_memo ) { go_BYE(-1); }
  ptr_vec->is_mono = is_mono;
BYE:
  return status;
}

int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    )
{
  int status = 0;
  if ( ptr_vec->is_eov == true ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks > 1 ) { go_BYE(-1); }
  //----------------------------------------
  if ( ( is_memo == false ) && ( ptr_vec->is_persist == true )) {
    // If Vector is to be persisted, it must be memoized 
    go_BYE(-1);
  }
  ptr_vec->is_memo = is_memo;
  // if memo is set on then mono must be set off
  if ( is_memo ) {
    ptr_vec->is_mono = false;
  }
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
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_get1++;
  if ( idx > ptr_vec->num_elements ) { go_BYE(-1); }
  uint32_t chunk_num = idx % g_chunk_size;
  if ( chunk_num > ptr_vec->num_chunks ) { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  chk_chunk_dir_idx(chunk_dir_idx);
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  status = load_chunk(ptr_chunk, chunk_num, ptr_vec); cBYE(status);
  *ptr_data = ptr_chunk->data; 

BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_get1 += delta; }
  return status;
}

int
vec_get_all(
    VEC_REC_TYPE *ptr_vec,
    char **ptr_data,
    uint64_t *ptr_num_elements,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_get_all++;
  char *data = NULL;
  if ( ptr_vec->access_mode == 2 ) { go_BYE(-1); }
  if ( ptr_vec->access_mode == 0 ) { 
    ptr_vec->access_mode = 1;
  }
  *ptr_num_elements = ptr_vec->num_elements;
  if ( *ptr_num_elements == 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks == 1 ) { 
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[0];
    chk_chunk_dir_idx(chunk_dir_idx);
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    if ( ptr_chunk->data != NULL ) { 
      data = ptr_chunk->data;
    }
    else {
      // TODO 
    }
  }
  else {
    // TODO ptr_vec->num_file_readers++; 
    if ( ptr_vec->mmap_addr != NULL ) { 
      data = ptr_vec->mmap_addr;
    }
    else {
      char *X = NULL; size_t nX = 0;
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(ptr_vec->uqid, file_name);
      status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
      if ( nX != ptr_vec->file_size ) { go_BYE(-1); }
      data = X;
    }
  }
  ptr_cmem->data = data;
  ptr_cmem->size = ptr_vec->file_size;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_get_all += delta; }
  return status;
}

int
vec_get_chunk(
    VEC_REC_TYPE *ptr_vec,
    uint32_t chunk_num,
    CMEM_REC_TYPE *ptr_cmem,
    uint32_t *ptr_num_in_chunk
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_get_chunk++;
  if ( chunk_num > ptr_vec->num_chunks ) { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  status = load_chunk(ptr_chunk, chunk_num, ptr_vec); cBYE(status);

  ptr_cmem->data = ptr_chunk->data;
  ptr_cmem->size = ptr_chunk->num_in_chunk;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_cmem->is_foreign = true;

  *ptr_num_in_chunk =  ptr_chunk->num_in_chunk;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_get_chunk += delta; }
  return status;
}

int
vec_start_write(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_start_write++;
  char *X = NULL; size_t nX = 0;
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  if ( ptr_vec->access_mode != 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_chunks == 1 ) { 
    uint32_t chunk_num = 0;
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    status = load_chunk(ptr_chunk, chunk_num, ptr_vec);  cBYE(status);
    X  = ptr_chunk->data;
    nX = ptr_chunk->num_in_chunk;
  }
  else {
    if ( ptr_vec->is_memo == false ) { go_BYE(-1); }
    if (( ptr_vec->mmap_addr != NULL ) && ( ptr_vec->mmap_len != 0 ) ) {
      munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
    }
    rs_mmap(ptr_vec->file_name, &X, &nX, 1); cBYE(status);
    ptr_vec->mmap_addr = X;
    ptr_vec->mmap_len  = nX;
  }
  ptr_cmem->data       = X;
  ptr_cmem->is_foreign = true;
  ptr_cmem->size       = nX;
  strncpy(ptr_cmem->fldtype, ptr_vec->fldtype, Q_MAX_LEN_QTYPE_NAME-1);

  ptr_vec->access_mode = 2; // for write
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_start_write += delta; }
  return status;
}

int
vec_end_write(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec->access_mode != 2 ) { go_BYE(-1); }
  if ( ptr_vec->mmap_addr  == NULL ) { go_BYE(-1); }
  if ( ptr_vec->mmap_len   == 0    )  { go_BYE(-1); }
  munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
  ptr_vec->mmap_addr  = NULL;
  ptr_vec->mmap_len   = 0;
  ptr_vec->access_mode = 0; // not opened for read or write
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
  if ( ptr_vec->is_memo == false ) { go_BYE(-1); }
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
    printf("hello world\n");
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
  if ( ptr_vec->is_eov       == true  ) { 
    // fprintf(stderr, "Already eov, nothing to do\n"); 
    return status; 
  } 
  ptr_vec->is_eov = true;
  return status;
}

int
vec_put_chunk(
    VEC_REC_TYPE *ptr_vec,
    const char * const data,
    uint32_t chunk_num,
    uint32_t num_elements
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data  == NULL ) { go_BYE(-1); }
BYE:
  return status;
}

int
vec_put1(
    VEC_REC_TYPE *ptr_vec,
    const char * const data
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_put1++;
  // START: Do some basic checks
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( data == NULL ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  uint32_t vsz = ptr_vec->chunk_size_in_bytes;
  uint32_t chunk_dir_idx;
  uint32_t chunk_num;
  //---------------------------------------
  // If no memcpy set, it is ignored by put1, only put_chunk cares
  if ( ptr_vec->num_chunks == 0 ) { 
    ptr_vec->chunk_dir_idxs = calloc(INITIAL_NUM_CHUNKS_PER_VECTOR, 
        sizeof(int32_t));
    return_if_malloc_failed(ptr_vec->chunk_dir_idxs);
    status =  allocate_chunk(vsz, &chunk_dir_idx);  cBYE(status);
    chk_chunk_dir_idx(chunk_dir_idx);
    ptr_vec->chunk_dir_idxs[ptr_vec->num_chunks] = chunk_dir_idx;
    ptr_vec->num_chunks++;
  }
  if ( ptr_vec->num_chunks == 0 ) { go_BYE(-1); }
  //------------------------------------------
  chunk_num = ptr_vec->num_chunks - 1 ;
  //-- Is current chunk allocated? If not, allocate a chunk
  //-- This may in turn cause a resizing of g_chunk_dir
  chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  if ( chunk_dir_idx == 0 ) {
    status =  allocate_chunk(vsz, &chunk_dir_idx);  cBYE(status);
    chk_chunk_dir_idx(chunk_dir_idx);
    ptr_vec->chunk_dir_idxs[chunk_num] = chunk_dir_idx;
  }
  chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  uint32_t num_in_chunk = ptr_chunk->num_in_chunk;
  // Is there space in current chunk; if not, allocate
  if ( num_in_chunk == g_chunk_size ) { 
    status =  allocate_chunk(vsz, &chunk_dir_idx);  cBYE(status);
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    ptr_vec->num_chunks++;
    chunk_num = ptr_vec->num_chunks - 1;
    ptr_vec->chunk_dir_idxs[chunk_num] = chunk_dir_idx;
  }
  chunk_num = ptr_vec->num_chunks - 1;
  chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  chk_chunk_dir_idx(chunk_dir_idx);
  ptr_chunk = g_chunk_dir + chunk_dir_idx;
  num_in_chunk = ptr_chunk->num_in_chunk;
  if ( num_in_chunk == g_chunk_size ) { go_BYE(-1); }
  //---------------------------------------
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { // special case
    go_BYE(-1); 
    // TODO 
  }
  else {
    uint32_t sz = ptr_vec->field_width;
    memcpy(ptr_chunk->data + (sz*num_in_chunk), data, sz);
  }
  ptr_chunk->num_in_chunk++;
  ptr_vec->num_elements++;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_put1 += delta; }
  return status;
}

int
vec_flush_to_disk(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_flush++;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[i];
    chk_chunk_dir_idx(chunk_dir_idx);
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    status = mk_file_name(ptr_chunk->uqid, file_name); cBYE(status);
    status = buf_to_file(ptr_chunk->data, ptr_vec->chunk_size_in_bytes,
        file_name);
    cBYE(status);
  }
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_flush += delta; }
  return status;
}

int
vec_file_name(
    VEC_REC_TYPE *ptr_vec,
    int32_t chunk_num,
    char *file_name
    )
{
  int status = 0;

  if ( chunk_num == -1 ) { // want file name for vector 
    status = mk_file_name(ptr_vec->uqid, file_name); cBYE(status);
  }
  else if ( chunk_num >= 0 ) {
    if ( (uint32_t)chunk_num >= ptr_vec->num_chunks ) { go_BYE(-1); }
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
    if ( chunk_dir_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    status = mk_file_name(ptr_chunk->uqid, file_name); cBYE(status);
  }
  else { 
    go_BYE(-1);
  }
BYE:
  return status;
}
