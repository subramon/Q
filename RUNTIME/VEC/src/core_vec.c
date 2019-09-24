#include "q_incs.h"
#include "core_vec.h"
#include "aux_core_vec.h"
#include "cmem.h"
#include "mm.h"
#include "vec_globals.h"
#include "_rs_mmap.h"
#include "_rand_file_name.h"
#include "_get_file_size.h"
#include "buf_to_file.h"
#include "copy_file.h"
#include "_file_exists.h"
#include "_txt_to_I4.h"
#include "_isfile.h"
#include "_isdir.h"
#include "_get_time_usec.h"

#include "lauxlib.h"

#define ALIGNMENT  256 // TODO P4 DOCUMENT AND PLACE CAREFULLY

static uint64_t
RDTSC(
    )
//STOP_FUNC_DECL
{
#ifdef RASPBERRY_PI
  return get_time_usec();
#else
  unsigned int lo, hi;
  asm volatile("rdtsc" : "=a" (lo), "=d" (hi));
  return ((uint64_t)hi << 32) | lo;
#endif
}


uint64_t t_l_vec_check;       static uint32_t n_l_vec_check;
uint64_t t_l_vec_clone;       static uint32_t n_l_vec_clone;
uint64_t t_l_vec_free;        static uint32_t n_l_vec_free;
uint64_t t_l_vec_get1;        static uint32_t n_l_vec_get1;
uint64_t t_l_vec_get_all;     static uint32_t n_l_vec_get_all;
uint64_t t_l_vec_get_chunk;   static uint32_t n_l_vec_get_chunk;
uint64_t t_l_vec_new;         static uint32_t n_l_vec_new;
uint64_t t_l_vec_put1;         static uint32_t n_l_vec_put1;
uint64_t t_l_vec_start_write; static uint32_t n_l_vec_start_write;

uint64_t t_l_vec_flush;             static uint32_t n_l_vec_flush;
uint64_t t_memcpy;            static uint32_t n_memcpy;
uint64_t t_memset;            static uint32_t n_memset;

//-- for memory allocation
uint64_t t_malloc;            static uint32_t n_malloc;

static inline void 
l_memcpy(
    void *dest,
    const void *src,
    size_t n
    )
{
  uint64_t delta = 0, t_start = RDTSC(); n_memcpy++;
  memcpy(dest, src, n);
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_memcpy += delta; }
}

static inline void 
l_memset(
    void *s, 
    int c, 
    size_t n
    )
{
  uint64_t delta = 0, t_start = RDTSC(); n_memset++;
  memset(s, c, n);
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_memset += delta; }
}

static inline void *
l_malloc(
    size_t n
    )
{
  int status = 0;
  void  *x = NULL;
  uint64_t delta = 0, t_start = RDTSC(); n_malloc++;
  uint64_t sz1, sz2;

  status = posix_memalign(&x, ALIGNMENT, n); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  // printf("core_vec.c : Malloc'd %llu \n", n);
  if ( x == NULL ) { WHEREAMI; return NULL; }
  bool is_incr = true, is_vec = true;
  status = mm(n, is_incr, is_vec, &sz1, &sz2); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_malloc += delta; }

  return x;
}

void
vec_reset_timers(
    void
    )
{
  printf("reset timers\n");
  t_l_vec_put1 = 0;         n_l_vec_put1 = 0;
  t_l_vec_check = 0;        n_l_vec_check = 0;
  t_l_vec_clone = 0;        n_l_vec_clone = 0;
  t_l_vec_free = 0;         n_l_vec_free = 0;
  t_l_vec_get1 = 0;         n_l_vec_get1 = 0;
  t_l_vec_get_all = 0;      n_l_vec_get_all = 0;
  t_l_vec_get_chunk = 0;    n_l_vec_get_chunk = 0;
  t_l_vec_new = 0;          n_l_vec_new = 0;
  t_l_vec_start_write = 0;  n_l_vec_start_write = 0;

  t_l_vec_flush= 0;               n_l_vec_flush= 0;
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
  sprintf(buf, "field_size   = %d, ", ptr_vec->field_size);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_size_in_bytes   = %" PRIu32 ", ", ptr_vec->chunk_size_in_bytes);
  strcat(opbuf, buf);
  sprintf(buf, "num_chunks = %" PRIu32 ", ", ptr_vec->num_chunks);
  strcat(opbuf, buf);
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  strcat(opbuf, buf);
  sprintf(buf, "name         = \"%s\", ", ptr_vec->name);
  strcat(opbuf, buf);
  sprintf(buf, "num_chunks   = %u, ", ptr_vec->num_chunks);
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
  if ( ( ptr_vec->mmap_addr  != NULL ) && ( ptr_vec->mmap_len > 0 ) )  {
    munmap(ptr_vec->mmap_addr, ptr_vec->mmap_len);
    ptr_vec->mmap_addr = NULL;
    ptr_vec->mmap_len  = 0;
  }
  // delete file created for entire access
  if ( *ptr_vec->file_name != '\0' ) {
    if ( isfile(ptr_vec->file_name) ) { 
      status = remove(ptr_vec->file_name);
      if ( status != 0 ) { WHEREAMI; }
    }
  }
  //------------
  for ( unsigned int i = 0; i < ptr_vec->num_chunks; i++ ) { 
    free_chunk(ptr_vec->chunk_dir_idxs[i], ptr_vec->is_persist); 
  }
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
vec_from_file(
    VEC_REC_TYPE *ptr_vec,
    const char * const file_name
    )
{
  int status = 0;
  if ( !isfile(file_name) ) { go_BYE(-1); }

  // check file size
  uint64_t num_elements = ptr_vec->num_elements;
  int64_t expected_file_size = num_elements * ptr_vec->field_size;

  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) {
    uint64_t num_words = num_elements / 64;
    if ( ( num_words * 64 ) != num_elements ) { num_words++; }
    expected_file_size = num_words * 8;
  }
  int64_t actual_file_size = get_file_size(file_name);
  if ( actual_file_size != expected_file_size ) { go_BYE(-1); }
  //------------
  strcpy(ptr_vec->file_name, file_name);
  ptr_vec->file_size = actual_file_size;
  ptr_vec->is_eov    = true;
  //------------
BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    bool is_memo,
    const char *const file_name,
    int64_t num_elements
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_new++;

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));

  char qtype[4]; int field_size = 0;
  memset(qtype, '\0', 4);
  if ( strcmp(field_type, "B1") == 0 ) {
    strcpy(qtype, field_type); field_size = 1; // SPECIAL CASE
  }
  else if ( strcmp(field_type, "I1") == 0 ) {
    strcpy(qtype, field_type); field_size = 1;
  }
  else if ( strcmp(field_type, "I2") == 0 ) {
    strcpy(qtype, field_type); field_size = 2;
  }
  else if ( strcmp(field_type, "I4") == 0 ) {
    strcpy(qtype, field_type); field_size = 4;
  }
  else if ( strcmp(field_type, "I8") == 0 ) {
    strcpy(qtype, field_type); field_size = 8;
  }
  else if ( strcmp(field_type, "F4") == 0 ) {
    strcpy(qtype, field_type); field_size = 4;
  }
  else if ( strcmp(field_type, "F8") == 0 ) {
    strcpy(qtype, field_type); field_size = 8;
  }
  else if ( strncmp(field_type, "SC:", 3) == 0 ) {
    char *xptr = (char *)field_type + 3;
    status = txt_to_I4(xptr, &field_size); cBYE(status);
    if ( field_size < 2 ) { go_BYE(-1); }
    strcpy(qtype, "SC");
  }
  else if ( strcmp(field_type, "TM") == 0 ) {
    strcpy(qtype, field_type); field_size = sizeof(struct tm); 
  }
  else {
    fprintf(stderr, "Unknown field_type = ]%s] \n", field_type);
    go_BYE(-1);
  }

  status = chk_field_type(qtype, field_size); cBYE(status);
  ptr_vec->field_size = field_size;
  ptr_vec->chunk_size_in_bytes = g_chunk_size * field_size;
  if ( strcmp(qtype, "B1") == 0 ) {  // SPECIAL CASE
    ptr_vec->chunk_size_in_bytes = g_chunk_size / 8;
    if ( ( ( g_chunk_size / 64 ) * 64 ) != g_chunk_size ) { go_BYE(-1); }
  }
  ptr_vec->is_memo    = is_memo;
  strcpy(ptr_vec->fldtype, qtype);

  if ( file_name != NULL ) { // filename provided for materialized vec
    if ( strcmp(qtype, "B1") == 0 ) { // Set num_elements for materialized B1 vec
      if ( num_elements <= 0 ) { go_BYE(-1); }
      ptr_vec->num_elements = (uint64_t) num_elements;
    }
    status = vec_from_file(ptr_vec, file_name); cBYE(status);
  }
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
  if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  status = load_chunk(ptr_chunk, ptr_vec); cBYE(status);
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
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
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
      status = rs_mmap(ptr_vec->file_name, &X, &nX, 0); cBYE(status);
      if ( nX != ptr_vec->file_size ) { go_BYE(-1); }
      data = X;
    }
  }
  ptr_cmem->data = data;
  ptr_cmem->size = ptr_vec->file_size;
  strcpy(ptr_cmem->fldtype, ptr_vec->fldtype);
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
  status = load_chunk(ptr_chunk, ptr_vec); cBYE(status);

  ptr_cmem->data = ptr_chunk->data;
  ptr_cmem->size = ptr_chunk->num_in_chunk;
  strcpy(ptr_cmem->fldtype, ptr_vec->fldtype);
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
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[0];
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    status = load_chunk(ptr_chunk, ptr_vec);  cBYE(status);
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
  strcpy(ptr_cmem->fldtype, ptr_vec->fldtype);

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

#ifdef XXX
int
vec_no_memcpy(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    size_t chunk_size
    )
{
  int status = 0;
  if (  ptr_vec  == NULL        ) { go_BYE(-1); }
  if (  ptr_vec->chunk != NULL  ) { go_BYE(-1); }
  if (  ptr_vec->is_eov         ) { go_BYE(-1); }
  if (  ptr_vec->file_size != 0 ) { go_BYE(-1); }

  if (  ptr_cmem == NULL        ) { go_BYE(-1); }
  if ( ptr_cmem->is_foreign     ) { go_BYE(-1); }
  if ( ptr_cmem->data == NULL   ) { go_BYE(-1); }
  if ( ptr_cmem->size <= 0      ) { go_BYE(-1); }

  ptr_vec->chunk_sz = (ptr_vec->field_size * ptr_vec->chunk_size);
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

  // Adjust the memory counters 
  uint64_t sz, sz1, sz2;
  sz = ptr_vec->chunk_sz;
  bool is_incr = true, is_vec = true;
  status = mm(sz, is_incr, is_vec, &sz1, &sz2); cBYE(status);
  is_incr = false; is_vec = false;
  status = mm(sz, is_incr, is_vec, &sz1, &sz2); cBYE(status);
BYE:
  return status;
}
#endif

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
  //---------------------------------------
  // TODO Deal with if ( ptr_vec->is_no_memcpy ) 
  // What if num_chunks == 0 ?
  uint32_t chunk_num = ptr_vec->num_chunks - 1 ;
  //-- Is current chunk allocated? If not, allocate a chunk
  //-- This may in turn cause a resizing of g_chunk_dir
  uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  if ( chunk_dir_idx == 0 ) {
    chunk_dir_idx = allocate_chunk(); 
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    ptr_vec->chunk_dir_idxs[chunk_num] = chunk_dir_idx;
  }
  chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  uint32_t num_in_chunk = ptr_chunk->num_in_chunk;
  // Is there space in current chunk; if not, allocate
  if ( num_in_chunk == g_chunk_size ) { 
    chunk_dir_idx = allocate_chunk(); 
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    ptr_vec->num_chunks++;
    chunk_num = ptr_vec->num_chunks - 1;
    ptr_vec->chunk_dir_idxs[chunk_num] = chunk_dir_idx;
  }
  chunk_num = ptr_vec->num_chunks - 1;
  chunk_dir_idx = ptr_vec->chunk_dir_idxs[chunk_num];
  if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
  ptr_chunk = g_chunk_dir + chunk_dir_idx;
  num_in_chunk = ptr_chunk->num_in_chunk;
  //---------------------------------------
  if ( strcmp(ptr_vec->fldtype, "B1") == 0 ) { // special case
    // TODO 
  }
  else {
    uint32_t sz = ptr_vec->field_size;
    memcpy(ptr_chunk + (sz*num_in_chunk), data, sz);
  }
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
    uint32_t chunk_dir_idx = ptr_vec->chunk_dir_idxs[i];
    if ( chunk_dir_idx == 0 ) { go_BYE(-1); }
    CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
    if ( *ptr_chunk->file_name == '\0' ) { 
      char buf[32];
      status = rand_file_name(buf, 32);
      snprintf(ptr_chunk->file_name, Q_MAX_LEN_FILE_NAME, 
          "%s/%s", g_q_data_dir, buf);
    }
    else {
      int64_t actual_size = get_file_size(ptr_chunk->file_name);
      if ( actual_size != ptr_vec->chunk_size_in_bytes ) { go_BYE(-1); }
    }
    status = buf_to_file(ptr_chunk->data, ptr_vec->chunk_size_in_bytes,
        ptr_chunk->file_name);
    cBYE(status);
  }
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_flush += delta; }
  return status;
}
