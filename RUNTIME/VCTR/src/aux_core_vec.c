#include "q_incs.h"
#include "core_vec_struct.h"

#include "aux_core_vec.h"
#include "_get_file_size.h"
#include "_isfile.h"
#include "_isdir.h"
#include "_rdtsc.h"
#include "_rs_mmap.h"
#include "vec_globals.h"

#define INITIAL_NUM_CHUNKS_PER_VECTOR 32
#define NUM_HEX_DIGITS_IN_UINT64 31 

// TODO P4 Following macro duplicated. Eliminate that.
#define chk_chunk_dir_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= g_sz_chunk_dir ) ) { go_BYE(-1); } \
}
void 
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

void 
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

void *
l_malloc(
    size_t n
    )
{
  int status = 0;
  void  *x = NULL;
  uint64_t delta = 0, t_start = RDTSC(); n_malloc++;

  status = posix_memalign(&x, Q_CORE_VEC_ALIGNMENT, n); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  if ( x == NULL ) { WHEREAMI; return NULL; }
  if ( status < 0 ) { WHEREAMI; return NULL; }
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_malloc += delta; }

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
chk_field_type(
    const char * const field_type,
    uint32_t field_width
    )
{
  int status = 0;
  if ( field_type == NULL ) { go_BYE(-1); }
  // TODO P3: SYNC with qtypes in q_consts.lua
  if ( ( strcmp(field_type, "B1") == 0 ) || 
       ( strcmp(field_type, "I1") == 0 ) || 
       ( strcmp(field_type, "I2") == 0 ) || 
       ( strcmp(field_type, "I4") == 0 ) || 
       ( strcmp(field_type, "I8") == 0 ) || 
       ( strcmp(field_type, "F4") == 0 ) || 
       ( strcmp(field_type, "F8") == 0 ) || 
       ( strcmp(field_type, "SC") == 0 ) || 
       ( strcmp(field_type, "TM") == 0 ) ) {
    /* all is well */
  }
  else {
    fprintf(stderr, "Bad field type = [%s] \n", field_type);
    go_BYE(-1);
  }
  if ( strcmp(field_type, "B1") == 0 )  {
    if ( field_width != 1 ) { go_BYE(-1); }
  }
  else {
    if ( field_width == 0 ) { go_BYE(-1); }
  }
  if ( strcmp(field_type, "SC") == 0 )  {
    if ( field_width < 2 ) { go_BYE(-1); }
  }
BYE:
  return status;
}

int
free_chunk(
    uint32_t chunk_dir_idx,
    bool is_persist
    )
{
  int status = 0;
  chk_chunk_dir_idx(chunk_dir_idx); 

  CHUNK_REC_TYPE *ptr_chunk =  g_chunk_dir+chunk_dir_idx;
  if ( ptr_chunk->num_readers > 0 ) { go_BYE(-1); }
  if ( ptr_chunk->num_writers > 0 ) { go_BYE(-1); }
  free_if_non_null(ptr_chunk->data);
  status = delete_chunk_file(ptr_chunk, is_persist, &(ptr_chunk->is_file));
  ptr_chunk->is_file = false;
  cBYE(status);
  g_n_chunk_dir--;
  memset(ptr_chunk, '\0', sizeof(CHUNK_REC_TYPE));
BYE:
  return status;
}


int
load_chunk(
    const CHUNK_REC_TYPE *const ptr_chunk, 
    const VEC_REC_TYPE *const ptr_vec,
    uint64_t *ptr_t_last_get,
    char **ptr_data
    )
{
  int status = 0;
  char *data = NULL;
  *ptr_t_last_get = RDTSC();
  if ( ptr_chunk->data != NULL ) { return status; } // already loaded
  // double check that this chunk is yours
  if ( ptr_chunk->vec_uqid != ptr_vec->uqid ) { go_BYE(-1); }
  if ( ptr_chunk->num_readers != 0 ) { go_BYE(-1); }
  if ( ptr_chunk->num_writers != 0 ) { go_BYE(-1); }

  // must be able to backup data from chunk file or vector file 
  if ( ( !ptr_chunk->is_file ) && ( !ptr_vec->is_file ) ) { go_BYE(-1); }

  char file_name[Q_MAX_LEN_FILE_NAME+1];
  memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  char *X = NULL; size_t nX = 0;
  data = l_malloc(ptr_vec->chunk_size_in_bytes);
  return_if_malloc_failed(data);
  memset(data, '\0', ptr_vec->chunk_size_in_bytes);

  if ( ptr_chunk->is_file ) { // chunk has a backup file 
    status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME);
    cBYE(status);
    status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
    if ( X == NULL ) { go_BYE(-1); }
    if ( nX > ptr_vec->chunk_size_in_bytes ) { go_BYE(-1); }
    memcpy(data, X, nX);
  }
  else { // vector has a backup file 
    status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
    cBYE(status);
    status = rs_mmap(file_name, &X, &nX, 0); cBYE(status);
    if ( X == NULL ) { go_BYE(-1); }
    if ( nX != ptr_vec->file_size ) { go_BYE(-1); }
    size_t offset = ptr_vec->chunk_size_in_bytes * ptr_chunk->chunk_num;
    if ( offset >= nX ) { go_BYE(-1); }
    size_t num_to_copy = ptr_vec->chunk_size_in_bytes;
    if ( nX - offset < num_to_copy ) { num_to_copy = nX - offset; }
    memcpy(data, X + offset, num_to_copy);
  }
  *ptr_data = data;
  munmap(X, nX);
BYE:
  return status;
}

int
chk_chunk(
      uint32_t chunk_dir_idx,
      uint64_t vec_uqid
      )
{
  int status = 0;
  if ( chunk_dir_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  /* What checks on these guys?
  if ( ptr_vec->num_readers > 0 ) { go_BYE(-1); }
  if ( ptr_vec->num_writers > 0 ) { go_BYE(-1); }
  */
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  memset(file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
  cBYE(status);
  if ( ptr_chunk->uqid == 0 ) { // we expect this to be free 
    if ( ptr_chunk->chunk_num != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->uqid != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->vec_uqid != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->is_file ) { go_BYE(-1); }
    if ( isfile(file_name) ) { go_BYE(-1); }
    if ( ptr_chunk->data != NULL ) { go_BYE(-1); }
  }
  else {
    if ( ptr_chunk->data == NULL ) { 
      if ( !ptr_chunk->is_file ) { go_BYE(-1); }
    }
    if ( ptr_chunk->is_file ) { 
      if ( !isfile(file_name) ) { 
        printf("hello world\n");
        go_BYE(-1); }
    }
  }
BYE:
  return status;
}

int
init_globals(
    void
    )
{
  int status = 0;
  static bool globals_initialized = false;

  if  ( globals_initialized ) {
    fprintf(stderr, "Cannot initialize globals twice\n"); go_BYE(-1);
  }
  else {
    if ( g_chunk_size    ==   0  ) { go_BYE(-1); }
    if ( g_q_data_dir[0] == '\0' ) { go_BYE(-1); }
    if ( g_sz_chunk_dir  ==   0  )  { go_BYE(-1); }

    g_chunk_dir = calloc(g_sz_chunk_dir, sizeof(CHUNK_REC_TYPE));
    return_if_malloc_failed(g_chunk_dir);
    g_n_chunk_dir = 0;
    globals_initialized = true;
  }
BYE:
  return status;
}

static int
chk_space_in_chunk_dir(
    )
{
  int status = 0;
  if ( g_chunk_dir == NULL ) { 
    status = init_globals(); 
    cBYE(status);
  }
  else {
    if ( g_n_chunk_dir >= g_sz_chunk_dir ) { 
      fprintf(stderr, "TO BE IMPLEMENTED: allocate space\n"); go_BYE(-1);
    }
  }
BYE:
  return status;
}

int
allocate_chunk(
    size_t sz,
    uint32_t chunk_num,
    uint64_t vec_uqid,
    uint32_t *ptr_chunk_dir_idx,
    bool is_malloc
    )
{
  int status = 0;
  static unsigned int start_search = 1;
  status = chk_space_in_chunk_dir();  cBYE(status); 
  // NOTE: we do not allocate 0th entry
  for ( int iter = 0; iter < 2; iter++ ) { 
    unsigned int lb, ub;
    if ( iter == 0 ) { 
      lb = start_search; // note not 0
      ub = g_sz_chunk_dir;
    }
    else {
      lb = 1; 
      ub = start_search; // note not 0
    }
    for ( unsigned int i = lb ; i < ub; i++ ) { 
      if ( g_chunk_dir[i].uqid == 0 ) {
        g_chunk_dir[i].uqid = RDTSC(); 
        g_chunk_dir[i].chunk_num = chunk_num;
        g_chunk_dir[i].is_file = false;
        g_chunk_dir[i].vec_uqid = vec_uqid;
        if ( is_malloc ) { 
          if ( sz == 0 ) { go_BYE(-1); }
          g_chunk_dir[i].data = malloc(sz);
          return_if_malloc_failed(g_chunk_dir[i].data);
        }
        *ptr_chunk_dir_idx = i; 
        g_n_chunk_dir++;
        start_search = i+1;
        if ( start_search >= g_sz_chunk_dir ) { start_search = 1; }
        return status;
      }
    }
  }
  /* control should not come here */
  go_BYE(-1); 
BYE:
  return status;
}

int64_t 
get_exp_file_size(
    uint64_t num_elements,
    uint32_t field_width,
    const char * const fldtype
    )
{
  // TODO: Currently we write entire chunk even if partially used
  num_elements = ceil((double)num_elements / g_chunk_size) * g_chunk_size;
  int64_t expected_file_size = num_elements * field_width;
  if ( strcmp(fldtype, "B1") == 0 ) {
    uint64_t num_words = num_elements / 64;
    if ( ( num_words * 64 ) != num_elements ) { num_words++; }
    expected_file_size = num_words * 8;
  }
  return expected_file_size;
}

int32_t
get_chunk_size_in_bytes(
      uint32_t field_width, 
      const char * const field_type
      )
{
  int32_t chunk_size_in_bytes = g_chunk_size * field_width;
  if ( strcmp(field_type, "B1") == 0 ) {  // SPECIAL CASE
    chunk_size_in_bytes = g_chunk_size / 8;
    if ( ( ( g_chunk_size / 64 ) * 64 ) != g_chunk_size ) { 
      WHEREAMI; return -1; 
    }
  }
  return chunk_size_in_bytes;
}

int
as_hex(
    uint64_t n,
    char *buf,
    size_t buflen
    )
{
  int status = 0;
  if ( buflen < 16+1 ) { go_BYE(-1); }
  for ( int i = 0; i < 16; i++ ) { 
    char c;
    switch ( n & 0xF )  {
      case 0 : c = '0'; break;
      case 1 : c = '1'; break;
      case 2 : c = '2'; break;
      case 3 : c = '3'; break;
      case 4 : c = '4'; break;
      case 5 : c = '5'; break;
      case 6 : c = '6'; break;
      case 7 : c = '7'; break;
      case 8 : c = '8'; break;
      case 9 : c = '9'; break;
      case 10 : c = 'A'; break;
      case 11 : c = 'B'; break;
      case 12 : c = 'C'; break;
      case 13 : c = 'D'; break;
      case 14 : c = 'E'; break;
      case 15 : c = 'F'; break;
      default : go_BYE(-1); break; 
    }
    buf[16-1-i] = c;
    n = n >> 4;
  }
BYE:
  return status;
}

int
mk_file_name(
    uint64_t uqid, 
    char *file_name, // [sz]
    int len_file_name
    )
{
  int status = 0;
  int len = NUM_HEX_DIGITS_IN_UINT64;
  char buf[len+1];
  memset(buf, '\0', len+1);
  if ( len_file_name > 0 ) { memset(file_name, '\0', len_file_name+1); }
  status = as_hex(uqid, buf, len); cBYE(status);
  // TODO P3 Need to avoid repeated initialization
  char *data_dir = getenv("Q_DATA_DIR");
  if ( data_dir == NULL ) { go_BYE(-1); }
  if ( !isdir(data_dir) ) { go_BYE(-1); }
  int nw = snprintf(file_name, Q_MAX_LEN_FILE_NAME, 
      "%s/_%s.bin", data_dir, buf);
  if ( nw == Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }
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
    chunk_num = idx / g_chunk_size;
  }
  if ( chunk_num >= ptr_vec->num_chunks ) { 
    printf("hello world\n");
    go_BYE(-1); 
  }

  *ptr_chunk_dir_idx = ptr_vec->chunks[chunk_num];
  if ( *ptr_chunk_dir_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
BYE:
  return status;
}
// tells us which chunk to write this element into
int 
get_chunk_num_for_write(
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
  uint32_t chunk_num =  (ptr_vec->num_elements / g_chunk_size);
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
    const VEC_REC_TYPE *const ptr_vec,
    uint32_t chunk_num,
    uint32_t *chunks,
    uint32_t *ptr_num_chunks,
    uint32_t *ptr_chunk_dir_idx
    )
{
  int status = 0;
  if ( chunk_num >= ptr_vec->sz_chunks )  { go_BYE(-1); }
  uint32_t chunk_dir_idx = ptr_vec->chunks[chunk_num];
  if ( chunk_dir_idx == 0 ) { // we need to set it 
    status = allocate_chunk(ptr_vec->chunk_size_in_bytes, chunk_num, 
        ptr_vec->uqid, &chunk_dir_idx, true); 
    cBYE(status);
    *ptr_num_chunks = *ptr_num_chunks + 1;
  }
  *ptr_chunk_dir_idx = chunk_dir_idx;
  if ( chunk_dir_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
  ptr_vec->chunks[chunk_num] = chunk_dir_idx;
BYE:
  return status;
}

int
vec_new_common(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    uint32_t field_width
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  status = chk_field_type(field_type, field_width); cBYE(status);

  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));

  strncpy(ptr_vec->fldtype, field_type, Q_MAX_LEN_QTYPE_NAME-1);
  ptr_vec->field_width = field_width;
  ptr_vec->chunk_size_in_bytes = get_chunk_size_in_bytes(field_width, field_type);
  ptr_vec->uqid = RDTSC();
  ptr_vec->is_memo = true;
BYE:
  return status;
}

int
delete_vec_file(
    const VEC_REC_TYPE *ptr_vec,
    bool *ptr_is_file, 
    uint64_t *ptr_file_size
    )
{
  int status = 0;
  if ( ptr_vec->is_file ) { 
    if ( !ptr_vec->is_persist ) {
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(ptr_vec->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      if ( !isfile(file_name) ) { 
        WHEREAMI; /* error. Should not happen  */ 
      }
      status = remove(file_name);
      if ( status != 0 ) { 
        WHEREAMI; /* error. Should not happen */ 
      }
      *ptr_is_file = false;
      *ptr_file_size = 0;
    }
  }
BYE:
  return status;
}
int
delete_chunk_file(
    const CHUNK_REC_TYPE *ptr_chunk,
    bool is_persist,
    bool *ptr_is_file
    )
{
  int status = 0;
  if ( ptr_chunk->is_file ) { 
    if ( !is_persist ) {
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      status = mk_file_name(ptr_chunk->uqid, file_name, Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      if ( !isfile(file_name) ) { 
        WHEREAMI; /* error. Should not happen  */ 
      }
      status = remove(file_name);
      if ( status != 0 ) { 
        WHEREAMI; /* error. Should not happen */ 
      }
      *ptr_is_file = false;
    }
  }
BYE:
  return status;
}

int
reincarnate(
    VEC_REC_TYPE *ptr_v,
    char **ptr_x
    )
{
  int status = 0;
  char buf[65536]; // TODO P3 Undo this hard code; 
  char *x = NULL;
  x = malloc(65536); // TODO P3 Undo this hard code
  memset(x, '\0', 65536);
  strcpy(x, " return { ");

  sprintf(buf, "qtype = \"%s\", ", ptr_v->fldtype); 
  strcat(x, buf);

  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_v->num_elements); 
  strcat(x, buf);

  sprintf(buf, "chunk_size = %d, ", g_chunk_size);
  strcat(x, buf);

  sprintf(buf, "width = %u, ", ptr_v->field_width); 
  strcat(x, buf);

  if ( ptr_v->is_file ) { 
    char file_name[Q_MAX_LEN_FILE_NAME+1];
    status = mk_file_name(ptr_v->uqid, file_name, Q_MAX_LEN_FILE_NAME);
    cBYE(status);
    sprintf(buf, "file_name = \"%s\", ",  file_name);
    strcat(x, buf);
  }
  else {
    if ( ptr_v->num_chunks == 1 ) { 
      strcat(x, "file_name = ");
    }
    else {
      strcat(x, "file_names = { ");
    }
    for ( unsigned int i = 0; i < ptr_v->num_chunks; i++ ) { 
      char file_name[Q_MAX_LEN_FILE_NAME+1];
      uint32_t chunk_idx = ptr_v->chunks[i];
      chk_chunk_dir_idx(chunk_idx);
      CHUNK_REC_TYPE *ptr_c = g_chunk_dir + chunk_idx;
      if ( !ptr_c->is_file ) { go_BYE(-1); }
      status = mk_file_name(ptr_c->uqid,file_name,Q_MAX_LEN_FILE_NAME); 
      cBYE(status);
      sprintf(buf, "\"%s\", ",  file_name);
      strcat(x, buf);
    }
    if ( ptr_v->num_chunks > 1 ) { 
      strcat(x, " }, ");
    }
  }
  strcat(x, " }  ");
  *ptr_x = x;
BYE:
  if ( status < 0 ) { free_if_non_null(x); }
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
