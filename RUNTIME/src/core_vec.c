#include <stdlib.h>
#include <time.h>
#include <malloc.h>
#include "q_incs.h"
#include "core_vec.h"
#include "cmem.h"
#include "mm.h"
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

#define CORE_VEC_ALIGNMENT  256 // TODO P3 DOCUMENT AND PLACE CAREFULLY

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


uint64_t t_l_vec_add;         static uint32_t n_l_vec_add;
uint64_t t_l_vec_check;       static uint32_t n_l_vec_check;
uint64_t t_l_vec_clone;       static uint32_t n_l_vec_clone;
uint64_t t_l_vec_end_write;   static uint32_t n_l_vec_end_write;
uint64_t t_l_vec_eov;         static uint32_t n_l_vec_eov;
uint64_t t_l_vec_free;         static uint32_t n_l_vec_free;
uint64_t t_l_vec_get;         static uint32_t n_l_vec_get;
uint64_t t_l_vec_memo;        static uint32_t n_l_vec_memo;
uint64_t t_l_vec_mono;        static uint32_t n_l_vec_mono;
uint64_t t_l_vec_new;         static uint32_t n_l_vec_new;
uint64_t t_l_vec_persist;     static uint32_t n_l_vec_persist;
uint64_t t_l_vec_set;         static uint32_t n_l_vec_set;
uint64_t t_l_vec_start_write; static uint32_t n_l_vec_start_write;

uint64_t t_flush_buffer;      static uint32_t n_flush_buffer;
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
    size_t n,
    VEC_REC_TYPE *ptr_vec // TODO P3 DELETE later just for debugging
    )
{
  int status = 0;
  void  *x = NULL;
  uint64_t delta = 0, t_start = RDTSC(); n_malloc++;
  uint64_t sz1, sz2;

  status = posix_memalign(&x, CORE_VEC_ALIGNMENT, n); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  // printf("core_vec.c : Malloc'd %llu \n", n);
  if ( x == NULL ) { WHEREAMI; return NULL; }
  bool is_incr = true, is_vec = true;
  status = mm(n, is_incr, is_vec, &sz1, &sz2); 
  if ( status < 0 ) { WHEREAMI; return NULL; }
  ptr_vec->uqid = t_start; 
  // set a unique ID for debugging
  // TODO P3 Above is good idea but not sure this is right place to set it
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_malloc += delta; }

  return x;
}

void
vec_reset_timers(
    void
    )
{
  printf("reset timers\n");
  t_l_vec_add = 0;          n_l_vec_add = 0;
  t_l_vec_check = 0;        n_l_vec_check = 0;
  t_l_vec_clone = 0;        n_l_vec_clone = 0;
  t_l_vec_end_write = 0;    n_l_vec_end_write = 0;
  t_l_vec_eov = 0;          n_l_vec_eov = 0;
  t_l_vec_free = 0;         n_l_vec_free = 0;
  t_l_vec_get = 0;          n_l_vec_get = 0;
  t_l_vec_memo = 0;         n_l_vec_memo = 0;
  t_l_vec_mono = 0;         n_l_vec_mono = 0;
  t_l_vec_new = 0;          n_l_vec_new = 0;
  t_l_vec_persist = 0;      n_l_vec_persist = 0;
  t_l_vec_set = 0;          n_l_vec_set = 0;
  t_l_vec_start_write = 0;  n_l_vec_start_write = 0;

  t_flush_buffer = 0;       n_flush_buffer = 0;
  t_memcpy = 0;             n_memcpy = 0;
  t_memset = 0;             n_memset = 0;
}

void
vec_print_timers(
    void
    )
{
  printf("print timers\n");
  fprintf(stdout, "0,add,%u,%" PRIu64 "\n",n_l_vec_add, t_l_vec_add);
  fprintf(stdout, "0,check,%u,%" PRIu64 "\n",n_l_vec_check, t_l_vec_check);
  fprintf(stdout, "0,clone,%u,%" PRIu64 "\n",n_l_vec_clone, t_l_vec_clone);
  fprintf(stdout, "0,end_write,%u,%" PRIu64 "\n", n_l_vec_end_write, t_l_vec_end_write);
  fprintf(stdout, "0,eov,%u,%" PRIu64 "\n", n_l_vec_eov, t_l_vec_eov);
  fprintf(stdout, "0,free,%u,%" PRIu64 "\n",n_l_vec_free, t_l_vec_free);
  fprintf(stdout, "0,get,%u,%" PRIu64 "\n",n_l_vec_get, t_l_vec_get);
  fprintf(stdout, "0,memo,%u,%" PRIu64 "\n",n_l_vec_memo, t_l_vec_memo);
  fprintf(stdout, "0,mono,%u,%" PRIu64 "\n",n_l_vec_mono, t_l_vec_mono);
  fprintf(stdout, "0,new,%u,%" PRIu64 "\n",n_l_vec_new, t_l_vec_new);
  fprintf(stdout, "0,persist,%u,%" PRIu64 "\n",n_l_vec_persist, t_l_vec_persist);
  fprintf(stdout, "0,set,%u,%" PRIu64 "\n", n_l_vec_set, t_l_vec_set);
  fprintf(stdout, "0,start_write,%u,%" PRIu64 "\n", n_l_vec_start_write, t_l_vec_start_write);

  fprintf(stdout, "1,flush_buffer,%u,%" PRIu64 "\n", n_flush_buffer, t_flush_buffer);
  fprintf(stdout, "1,memcpy,%u,%" PRIu64 "\n", n_memcpy, t_memcpy);
  fprintf(stdout, "1,memset,%u,%" PRIu64 "\n", n_memset, t_memset);
  fprintf(stdout, "1,malloc,%u,%" PRIu64 "\n", n_malloc, t_malloc);
}

static bool 
is_file_size_okay(
    VEC_REC_TYPE *ptr_vec 
    )
{
  if ( ptr_vec->is_memo == false ) {
    return true; // TODO P4: what should be appropriate return value
  }
  int64_t actual_fsz = get_file_size(ptr_vec->file_name);
  int64_t expected_fsz;
  int num_elements;
  if ( ptr_vec->is_eov ) {
    num_elements = ptr_vec->num_elements;
  }
  else {
    num_elements = ( ptr_vec->chunk_num * ptr_vec->chunk_size );
  }
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    expected_fsz = ceil( num_elements / 64.0 ) * 8;
  }
  else {
    expected_fsz = num_elements * ptr_vec->field_size;
  }
  if ( expected_fsz != actual_fsz ) {
    fprintf(stderr, "Expected %" PRIu64 " elements, got %" PRIu64 "\n",
        expected_fsz,  actual_fsz);
    WHEREAMI; return false;
  }
  else {
    return true;
  }
}

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
chk_field_type(
    const char * const field_type,
    uint32_t field_size
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
    if ( field_size != 1 ) { go_BYE(-1); }
  }
  else {
    if ( field_size == 0 ) { go_BYE(-1); }
  }
  if ( strcmp(field_type, "SC") == 0 )  {
    if ( field_size < 2 ) { go_BYE(-1); }
  }
BYE:
  return status;
}

/* Deprecated vec_get_buf() */

int 
vec_cast(
    VEC_REC_TYPE *ptr_vec,
    const char * const new_field_type,
    uint32_t new_field_size
    )
{
  int status = 0;
  //--- START ERROR CHECKING
  status = chk_field_type(new_field_type, new_field_size); cBYE(status);
  if ( !ptr_vec->is_eov ) { go_BYE(-1); }
  if ( !isfile(ptr_vec->file_name) ) { go_BYE(-1); }
  if ( strcmp(new_field_type, "B1") == 0 ) {
    if ( ( ( ptr_vec->file_size / 8 )  * 8 ) != ptr_vec->file_size ) {
      go_BYE(-1);
    }
  }
  else {
    if ( ( ( ptr_vec->file_size / new_field_size )  * new_field_size ) != 
        ptr_vec->file_size ) {
      go_BYE(-1);
    }
  }
  if ( ptr_vec->open_mode == 2 ) { go_BYE(-1); }
  //--- STOP ERROR CHECKING
  strcpy(ptr_vec->field_type, new_field_type);
  if ( strcmp(new_field_type, "B1") == 0 ) {
    ptr_vec->num_elements = ptr_vec->file_size * 8;
    ptr_vec->num_in_chunk = ptr_vec->num_in_chunk * ptr_vec->field_size * 8;
    if ( new_field_size != 0 ) { go_BYE(-1); } // special case for B1
  }
  else {
    ptr_vec->num_elements = ptr_vec->file_size / new_field_size;
  }
  ptr_vec->field_size   = new_field_size;
  status = vec_clean_chunk(ptr_vec); cBYE(status);
BYE:
  return status;
}

int
update_file_name(VEC_REC_TYPE *ptr_vec) {
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  char temp_buf_file[Q_MAX_LEN_BASE_FILE+1];

  // TODO P2 We are gamblng on the fact that the file name is
  // indeed unique. Should check that no such file already exists
  memset(temp_buf_file, '\0', Q_MAX_LEN_BASE_FILE+1);
  status = rand_file_name(temp_buf_file, Q_MAX_LEN_BASE_FILE);
  cBYE(status);

  strncat(ptr_vec->file_name, temp_buf_file, Q_MAX_LEN_FILE_NAME);
BYE:
  return status;
}

int 
flush_buffer(
          VEC_REC_TYPE *ptr_vec
          )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_flush_buffer++;
  if ( ptr_vec->num_in_chunk == 0 ) { go_BYE(-1); }
  if ( ptr_vec->is_memo ) {
    if ( !isfile(ptr_vec->file_name) ) {
      // append randomly generated file name to ptr_vec->file_name 
      status = update_file_name(ptr_vec); cBYE(status);
    }
    status = buf_to_file(ptr_vec->chunk, ptr_vec->field_size, 
        ptr_vec->field_type, ptr_vec->num_in_chunk, ptr_vec->file_name);
    cBYE(status);
  }
  // flushing buffer does not change number of elements in Vector
  ptr_vec->num_in_chunk = 0;
  ptr_vec->chunk_num++;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_flush_buffer += delta; }
  return status;
}
int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ( file_name == NULL ) || ( *file_name == '\0' ) ) { go_BYE(-1); }
  if ( strlen(file_name) > Q_MAX_LEN_FILE_NAME ) { go_BYE(-1); }

  int64_t fsz = get_file_size(file_name);
  if ( fsz <= 0 ) { go_BYE(-1); }
  // check fsz
  // For B1, file can be larger than necessary, not smaller
  // For all others, size must match number of elements
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    if ( ptr_vec->num_elements == 0 ) { go_BYE(-1); }
    uint64_t num_words = ceil(ptr_vec->num_elements/64.0);
    uint64_t num_bytes = num_words * 8;
    if ( num_bytes < (uint64_t)fsz ) { go_BYE(-1); }
  }
  else {
    ptr_vec->num_elements = fsz / ptr_vec->field_size;
    if (( ptr_vec->num_elements * ptr_vec->field_size) != (uint64_t)fsz ) { 
      go_BYE(-1);
    }
  }
  ptr_vec->file_size  = fsz;
  ptr_vec->is_nascent = false;
  ptr_vec->is_eov     = true;
  ptr_vec->is_memo    = true;
  strcpy(ptr_vec->file_name, file_name);
  // now unmap the file
BYE:
  return status;
}

int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    )
{
  int status = 0;
  // TODO P4 This is slow. Can be speeded up
  char  buf[1024];
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  strcpy(opbuf, "return { ");
  //------------------------------------------------
  sprintf(buf, "field_type = \"%s\", ", ptr_vec->field_type);
  strcat(opbuf, buf);
  sprintf(buf, "field_size = %d, ", ptr_vec->field_size);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_size = %" PRIu32 ", ", ptr_vec->chunk_size);
  strcat(opbuf, buf);
  //-------------------------------------
  sprintf(buf, "num_elements = %" PRIu64 ", ", ptr_vec->num_elements);
  strcat(opbuf, buf);
  sprintf(buf, "num_in_chunk = %" PRIu32 ", ", ptr_vec->num_in_chunk);
  strcat(opbuf, buf);
  sprintf(buf, "chunk_num = %" PRIu32 ", ", ptr_vec->chunk_num);
  strcat(opbuf, buf);
  //-------------------------------------
  sprintf(buf, "name = \"%s\", ", ptr_vec->name);
  strcat(opbuf, buf);
  if ( isfile(ptr_vec->file_name) ) {
    sprintf(buf, "file_name = \"%s\", ", ptr_vec->file_name);
    strcat(opbuf, buf);
    int64_t file_size = get_file_size(ptr_vec->file_name);
    if ( file_size <= 0 ) { go_BYE(-1);}
    sprintf(buf, "file_size = %lld, ", (unsigned long long)file_size);
    strcat(opbuf, buf);
  }
  //-------------------------------------
  sprintf(buf, "is_persist = %s, ", ptr_vec->is_persist ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_nascent = %s, ", ptr_vec->is_nascent ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_memo = %s, ", ptr_vec->is_memo ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_mono = %s, ", ptr_vec->is_mono ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_eov = %s, ", ptr_vec->is_eov ? "true" : "false");
  strcat(opbuf, buf);
  sprintf(buf, "is_no_memcpy = %s, ", ptr_vec->is_no_memcpy ? "true" : "false");
  strcat(opbuf, buf);
  switch ( ptr_vec->open_mode ) {
    case 0 : strcpy(buf, "open_mode = \"NOT_OPEN\", "); break;
    case 1 : strcpy(buf, "open_mode = \"READ\", "); break;
    case 2 : strcpy(buf, "open_mode = \"WRITE\", "); break;
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
  if ( ( ptr_vec->map_addr  != NULL ) && ( ptr_vec->map_len > 0 ) )  {
    munmap(ptr_vec->map_addr, ptr_vec->map_len);
    ptr_vec->map_addr = NULL;
    ptr_vec->map_len  = 0;
  }
  if ( ptr_vec->chunk != NULL ) {
    free(ptr_vec->chunk);
    uint64_t sz1, sz2;
    bool is_incr = false, is_vec = true;
    status = mm(ptr_vec->chunk_sz, is_incr, is_vec, &sz1, &sz2); 
    if ( status != 0 ) { WHEREAMI; }
    ptr_vec->chunk = NULL;
    ptr_vec->chunk_sz = 0;
  }
  if ( !ptr_vec->is_persist ) {
    if ( isfile(ptr_vec->file_name) ) {
      // printf("Deleting %s \n", ptr_vec->file_name); 
      status = remove(ptr_vec->file_name); 
      if ( status != 0 ) { WHEREAMI; }
    }
    /* NOTE Remove can fail because (1) file does not exist 
       (2) permission to delete not there */
    if ( isfile(ptr_vec->file_name) ) { go_BYE(-1); }
    memset(ptr_vec->file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  }
  else {
    if ( file_exists(ptr_vec->file_name) ) {
      // printf("NOT Deleting %s \n", ptr_vec->file_name); 
    }
  }
  // Don't do this in C. Lua will do it: free(ptr_vec);
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_free += delta; }
  return status;
}

int
vec_delete(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  vec_free(ptr_vec); 
  if ( isfile(ptr_vec->file_name) ) {
    remove(ptr_vec->file_name); 
  }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  ptr_vec->is_dead = true; 
BYE:
  return status;
}

int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( ptr_vec->chunk        != NULL ) { go_BYE(-1); }
  if ( ptr_vec->chunk_num    != 0    ) { go_BYE(-1); }
  if ( ptr_vec->num_in_chunk != 0    ) { go_BYE(-1); }

  // chunk size must be multiple of 64
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    ptr_vec->chunk_sz = ptr_vec->chunk_size / 8;
  }
  else {
    ptr_vec->chunk_sz = ptr_vec->field_size * ptr_vec->chunk_size;
  }


  ptr_vec->is_nascent = true;
  ptr_vec->is_eov     = false;

BYE:
  return status;
}

int 
vec_clone(
    VEC_REC_TYPE *ptr_old_vec,
    VEC_REC_TYPE *ptr_new_vec,
    const char *const q_data_dir
    )
{
  int status = 0;
  if ( q_data_dir == NULL ) { go_BYE(-1); }
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_clone++;
  // supporting clone operation for non_eov vectors, so commenting below condition
  // if ( ptr_old_vec->is_eov == false ) { go_BYE(-1); }
  // quit if opened for writing
  if ( ptr_old_vec->open_mode == 2 ) { go_BYE(-1); }
  // Commenting memcpy as we are setting fields explicitly
  // l_memcpy(ptr_new_vec, ptr_old_vec, sizeof(VEC_REC_TYPE));

  ptr_new_vec->open_mode = 0; // unopened
  ptr_new_vec->field_size = ptr_old_vec->field_size;
  ptr_new_vec->chunk_size = ptr_old_vec->chunk_size;
  ptr_new_vec->is_memo = ptr_old_vec->is_memo;
  strcpy(ptr_new_vec->field_type, ptr_old_vec->field_type);
  ptr_new_vec->num_elements = ptr_old_vec->num_elements;
  ptr_new_vec->is_nascent = ptr_old_vec->is_nascent;
  ptr_new_vec->is_eov = ptr_old_vec->is_eov;
  ptr_new_vec->chunk_sz = ptr_old_vec->chunk_sz;
  // Set is_persist to false, if required, user will set it to true
  ptr_new_vec->is_persist = false;
  // Set name to null
  memset(ptr_new_vec->name, '\0', Q_MAX_LEN_INTERNAL_NAME+1);

  if ( ptr_old_vec->chunk != NULL ) { 
    ptr_new_vec->chunk = l_malloc(ptr_new_vec->chunk_sz, ptr_new_vec);
    return_if_malloc_failed(ptr_new_vec->chunk); 
    l_memcpy(ptr_new_vec->chunk, ptr_old_vec->chunk, ptr_new_vec->chunk_sz);
    // Update num_in_chunk and chunk_num
    ptr_new_vec->chunk_num = ptr_old_vec->chunk_num;
    ptr_new_vec->num_in_chunk = ptr_old_vec->num_in_chunk;
  }
  else {
    ptr_new_vec->chunk_num = 0;
    ptr_new_vec->num_in_chunk = 0;
  }
  ptr_new_vec->map_addr = NULL; // unopened
  ptr_new_vec->map_len  = 0;    // unopened
  if ( isfile(ptr_old_vec->file_name) ) {
    // copying q_data_dir to file_name field, will append the randomly generated file_name to it
    strcpy(ptr_new_vec->file_name, q_data_dir);
    strcat(ptr_new_vec->file_name, "/");
    // create randomly generated file name and append to ptr_new_vec->file_name field
    status = update_file_name(ptr_new_vec);
    cBYE(status);
    // copy old to new
    status = copy_file(ptr_old_vec->file_name, ptr_new_vec->file_name);
    cBYE(status);
    // Update file size
    ptr_new_vec->file_size = ptr_old_vec->file_size;
  }
  else {
    ptr_new_vec->file_size = 0;
  }
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_clone += delta; }
BYE:
  return status;
}

int
get_qtype_and_field_size(
    const char * const field_type,
    char * res_qtype,
    int * res_field_size
    )
{
  int status = 0;

  if ( res_field_size == NULL ) { go_BYE(-1); }
  if ( res_qtype == NULL ) { go_BYE(-1); }
  if ( field_type == NULL ) { go_BYE(-1); }

  char qtype[4]; int field_size = 0;
  memset(qtype, '\0', 4);
  if ( strcmp(field_type, "B1") == 0 ) {
    // What should be the field_size for B1?
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
    char *cptr = (char *)field_type + 3;
    status = txt_to_I4(cptr, &field_size); cBYE(status);
    if ( field_size < 2 ) { go_BYE(-1); }
    strcpy(qtype, "SC");
  }
  else {
    go_BYE(-1);
  }
  strcpy(res_qtype, qtype);
  *res_field_size = field_size;
BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    const char *const q_data_dir,
    uint32_t chunk_size,
    bool is_memo,
    const char *const file_name,
    int64_t num_elements
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_new++;
  if ( q_data_dir == NULL ) { go_BYE(-1); }

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  if ( chunk_size == 0 ) { go_BYE(-1); }

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
  ptr_vec->chunk_size = chunk_size; 
  ptr_vec->is_memo    = is_memo;
  strcpy(ptr_vec->field_type, qtype);

  if ( file_name != NULL ) { // filename provided for materialized vec
    if ( strcmp(qtype, "B1") == 0 ) { // Set num_elements for materialized B1 vec
      if ( num_elements <= 0 ) { go_BYE(-1); }
      ptr_vec->num_elements = (uint64_t) num_elements;
    }
    status = vec_materialized(ptr_vec, file_name); cBYE(status);
  }
  else {
    status = vec_nascent(ptr_vec); cBYE(status);
    // For nascent vector, file_name = q_data_dir + randomly generated file name
    // copying q_data_dir to file_name field, will append the randomly generated file_name later
    strncpy(ptr_vec->file_name, q_data_dir, Q_MAX_LEN_DIR);
    strcat(ptr_vec->file_name, "/");
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
  if ( !ptr_vec->is_memo ) { if ( ptr_vec->is_mono ) { go_BYE(-1); } }
  if ( ptr_vec->is_no_memcpy ) { if ( ptr_vec->chunk == NULL ) { go_BYE(-1); } }
  /*
is_nascent = true, is_eov = false (nascent vector without eov())
is_nascent = true, is_eov = true (nascent vector, after eov() call)
is_nascent = false, is_eov = true (file_mode or start_write call or materialized vec)
  */
  /* When a vector is created from a file,
   * is_nascent = false, is_eov = true, is_memo = true */
  /* State changes
   * is_nascent = true, is_eov = false
   * is_nascent = true, is_eov = true
   * is_nascent = false, is_eov = true
   * is_nascent = false, is_eov = false // ILLEGAL
   * */
  // Field type, field size must be defined and legit 
  status = chk_field_type(ptr_vec->field_type, ptr_vec->field_size);
  cBYE(status);
  // chunk size must be multiple of 64
  if ( ptr_vec->chunk_size == 0 ) { go_BYE(-1); }
  if ( ( ( ptr_vec->chunk_size / 64 ) * 64 ) != ptr_vec->chunk_size ) { 
    go_BYE(-1);
  }
  // Cannot persist a vector that is not memo-ized
  if ( ptr_vec->is_memo == false ) {
    if ( ptr_vec->is_persist == true ) { go_BYE(-1); }
  }
  /* file size set only after is_eov */
  if ( ptr_vec->is_eov == false ) {
    if ( ptr_vec->file_size != 0 ) { go_BYE(-1); }
  }
  /* if name set, should be valid */
  if ( ptr_vec->name[0] != '\0' ) {
    status = chk_name(ptr_vec->name); cBYE(status);
  }
  // Open mode == 0 IFF map_addr == \bot
  // Open mode == 0 IFF map_len  == 0
  switch ( ptr_vec->open_mode ) { 
    case 0 :
      if ( ptr_vec->map_addr != NULL ) { go_BYE(-1); }
      if ( ptr_vec->map_len  != 0 ) { go_BYE(-1); }
      break;
    case 1 :
      break;
    case 2 :
      if ( ptr_vec->map_addr == NULL ) { go_BYE(-1); }
      if ( ptr_vec->map_len  == 0 ) { go_BYE(-1); }
      if ( ptr_vec->is_nascent == true ) { go_BYE(-1); }
      if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
      break;
    default : 
      go_BYE(-1);
      break;
  }
  /* Cannot have vector with 0 elements. 
   * Should this be handled by Lua or C? TODO P3
  if ( ptr_vec->is_eov == true ) {
    if ( ptr_vec->num_elements == 0    ) { go_BYE(-1); }
  }
  */
  if ( ptr_vec->is_eov == true ) {
    return status;
  }
  // when map_len > 0, must match file_size 
  // It is possible for map_len == 0 and file_size > 0
  if ( ptr_vec->map_len > 0 ) {
    if ( ptr_vec->file_size != ptr_vec->map_len ) { 
      go_BYE(-1); 
    }
    if (get_file_size(ptr_vec->file_name) != (int64_t)ptr_vec->file_size){ 
      go_BYE(-1); 
    }
  }
  else {
    if ( ptr_vec->map_addr != NULL ) { go_BYE(-1); }
  }
  /* When is_eov and is_memo, 
     Backup file should exist and have space for num_elements in it */
  if ( ( ptr_vec->is_eov == true ) && ( ptr_vec->is_memo == true ) ) {
    bool exists = file_exists(ptr_vec->file_name); 
    if ( !exists ) { go_BYE(-1); }
    if ( !is_file_size_okay(ptr_vec) ) { go_BYE(-1);}
  }
  //-----------------------------------------------
  if ( ( ptr_vec->is_nascent == true ) && ( ptr_vec->is_eov == false ) ) {
    if ( ptr_vec->chunk_sz == 0 ) { go_BYE(-1); }
    /* Not an error because of lazy malloc 
      if ( ptr_vec->chunk == NULL ) { go_BYE(-1); }
    */
    if ( ( ptr_vec->is_memo ) && ( ptr_vec->chunk_num >= 1 ) ) {
      // Check that file exists 
      bool exists = file_exists(ptr_vec->file_name); 
      if ( !exists ) { go_BYE(-1); }
      // Check that file is of proper size
      if ( !is_file_size_okay(ptr_vec) )  {
          go_BYE(-1);
      }
    }
    else {
      if ( isfile(ptr_vec->file_name) ) { go_BYE(-1); }
    }
    if ( ptr_vec->num_elements != 
        ( ( ptr_vec->chunk_num * ptr_vec->chunk_size) + 
          ptr_vec->num_in_chunk ) ) {
      go_BYE(-1);
    }
    if ( ptr_vec->map_addr   != NULL ) { go_BYE(-1); }
    if ( ptr_vec->map_len    != 0    ) { go_BYE(-1); }
    if ( ptr_vec->open_mode  != 0    ) { go_BYE(-1); }
  }
  else if (( ptr_vec->is_nascent == false ) && ( ptr_vec->is_eov == true )){
    /* file mode (as opposed to buffer mode */
    if ( ptr_vec->num_in_chunk != 0    ) { go_BYE(-1); }
    if ( ptr_vec->chunk        != NULL ) { go_BYE(-1); }
    if ( ptr_vec->chunk_num    != 0    ) { go_BYE(-1); }
  }
  else if (( ptr_vec->is_nascent == true )&&( ptr_vec->is_eov == true ) ){
    if ( ptr_vec->num_in_chunk == 0    ) { go_BYE(-1); }
    if ( ptr_vec->chunk        == NULL ) { go_BYE(-1); }
    // May be only 1 chunk if ( ptr_vec->chunk_num    == 0    ) { go_BYE(-1); }
    if ( ptr_vec->open_mode    != 0 ) { 
      go_BYE(-1); }
    if ( ptr_vec->map_addr     != NULL ) { go_BYE(-1); }
    if ( ptr_vec->map_len      != 0    ) { go_BYE(-1); }
  }
  else if (( ptr_vec->is_nascent == false )&&( ptr_vec->is_eov == false )){
    go_BYE(-1);
  }
  else {
    // Control cannot come here
    go_BYE(-1);
  }

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
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_mono++;
  // Note that all error handling is done at the time memo was set to true
  if ( !ptr_vec->is_memo ) { go_BYE(-1); }
  ptr_vec->is_mono = is_mono;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_mono += delta; }
  return status;
}

int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_memo++;
  if ( ptr_vec->is_eov == false ) {
    if ( ptr_vec->chunk_num >= 1 ) { go_BYE(-1); }
    if (( is_memo == false ) && ( ptr_vec->is_persist == true )) {
      // you can not modify is_memo to false if is_persist flag is set to true 
      // because this will push vector in a state where is_memo = false and is_persist = true which is not a proper state for vector
      // for more discussion on this, please refer doc Q/RUNTIME/doc/memo_flag_setting.txt
      go_BYE(-1);
    }
    ptr_vec->is_memo = is_memo;
    // if memo is set on then mono must be set off
    if ( is_memo ) {
      ptr_vec->is_mono = false;
    }
  }
  else {
    go_BYE(-1);
  }

BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_memo += delta; }
  return status;
}

int
vec_clean_chunk(
    VEC_REC_TYPE *ptr_vec
)
{
  int status = 0;
  if ( ptr_vec->is_eov == false ) { go_BYE(-1); }
  if ( ptr_vec->chunk != NULL ) {
    uint64_t sz1, sz2;
    bool is_incr = false, is_vec = true;
    status = mm(ptr_vec->chunk_sz, is_incr, is_vec, &sz1, &sz2); 
    cBYE(status);
    // Clean the chunk and chunk metadata
    free(ptr_vec->chunk);
    ptr_vec->chunk = NULL;
    ptr_vec->chunk_sz = 0;
    ptr_vec->chunk_num    = 0;
    ptr_vec->num_in_chunk = 0;          
    ptr_vec->is_nascent   = false;          
  }
  else {
    if ( ptr_vec->chunk_num    != 0 ) { go_BYE(-1); }
    if ( ptr_vec->num_in_chunk != 0 ) { go_BYE(-1); }          
  }
BYE:
  return status;      
}

int
vec_get(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx, 
    uint32_t len,
    char **ptr_ret_addr,
    uint64_t *ptr_ret_len
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_get++;
  FILE *fp = NULL;
  char *addr = NULL;
  char *ret_addr = NULL;
  uint64_t ret_len  = 0;
  char *X = NULL; uint64_t nX = 0;
  // If len == 0 => vector must be materialized, we want everything
  if ( ( len == 0 ) && ( !ptr_vec->is_eov ) ) { go_BYE(-1); }

  // requested idx should not be greater than available vector elements
  if ( idx >= ptr_vec->num_elements ) {
    *ptr_ret_addr = NULL;
    *ptr_ret_len  = 0;
    status = -2;
    goto BYE;
  }

  // START RAMESH TODO P1 Is following okay?
  if ( ( idx == 0 ) && ( len > ptr_vec->num_elements ) ) {
    len = ptr_vec->num_elements;
  }
  // STOP  RAMESH

  // If B1 and you ask for 5 elements starting from 67th, then 
  // this is translated to asking for (8 = 5+3) elements starting 
  // from 64 = (67 -3) position. In other words, if you wanted
  // 67, 68, 69, 60, 71, you will get 
  // 64, 65, 66, 67, 68, 69, 60, 71 and
  // you have to index into it yourself to get the bits you want
  // Note that idx has gone down by 3 and len has gone up by 3 
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) { 
    uint32_t bit_idx = idx % 64;
    len += bit_idx;
    idx -= bit_idx; 
  }
  uint32_t chunk_num = idx / ptr_vec->chunk_size;
  uint32_t chunk_idx = idx %  ptr_vec->chunk_size;
  // Can we satisfy from current chunk? 
  // Yes if required chunk is current chunk and chunk is not yet cleaned
  if ( ( chunk_num == ptr_vec->chunk_num ) && 
      ( ptr_vec->chunk != NULL ) && ( ptr_vec->is_nascent == true ) ) {
    // printf("Serving request from in-memory buffer\n");
    if ( chunk_idx + len > ptr_vec->chunk_size ) { go_BYE(-1); }
    uint32_t offset;
    if ( strcmp(ptr_vec->field_type, "B1") == 0 ) { 
      offset = chunk_idx / 8; // 8 bits in a byte 
    }
    else {
      offset = chunk_idx * ptr_vec->field_size;
    }
    ret_addr = ptr_vec->chunk + offset;
    if ( len == 0 ) {
      ret_len  = (ptr_vec->num_in_chunk - chunk_idx);
    }
    else {
      ret_len  = mcr_min(len, (ptr_vec->num_in_chunk - chunk_idx));
    }
    *ptr_ret_addr = ret_addr;
    *ptr_ret_len  = ret_len;
    // Nothing more to do. Get out of here
    goto BYE;
  }
  else if ( ( ptr_vec->is_nascent == false ) || ( ( ptr_vec->is_eov == true ) && ( chunk_num < ptr_vec->chunk_num ) ) ) {
    // printf("Serving request using mmap pointer\n");
    switch ( ptr_vec->open_mode ) {
      case 0 :
        // TODO P2: Delete folllowing check
        // Should not be setting file_name when no file created
        if ( isdir(ptr_vec->file_name) ) { 
          fprintf(stderr, "XXXXX directory not file\n");
          go_BYE(-1); 
        }
        if ( ptr_vec->file_size == 0 ) { go_BYE(-1); }
        // TODO P2: Delete above
        status = rs_mmap(ptr_vec->file_name, &X, &nX, 0);
        cBYE(status);
        ptr_vec->map_addr = X;
        ptr_vec->map_len  = nX;
        ptr_vec->open_mode = 1; // indicating read */
        break;
      case 1 : /* opened in read mode */
        /* nothing to do */
        break;
      case 2 : /* opened in write mode */
        go_BYE(-1);
        break;
      default :  /* invalid value */
        go_BYE(-1);
        break;
    }
    if ( ptr_vec->map_addr == NULL ) { go_BYE(-1); }
    if ( ptr_vec->map_len  == 0 ) { go_BYE(-1); }
    if ( len == 0 ) {  // nothing more to do
      ret_addr = ptr_vec->map_addr;
      ret_len  = ptr_vec->num_elements;
    }
    else {
      if ( idx >= ptr_vec->num_elements ) { 
        // not clear this is an error even though it cannot be fulfilled
        status = -2; goto BYE;
      }
      if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
        ret_addr = ptr_vec->map_addr + ( idx / 8 );
      }
      else {
        ret_addr = ptr_vec->map_addr + ( idx * ptr_vec->field_size);
      }
      ret_len  = mcr_min(ptr_vec->num_elements - idx, len);            
    }
  }
  else {
    if ( chunk_num < ptr_vec->chunk_num ) {
      // printf("Serving request from file\n");
      if ( ptr_vec->is_memo ) {
        // If memo is on, should be able to serve data from previous chunks 
        // as long as request does not bleed into current chunk
        // this option only works for whole chunks
        uint64_t offset = 0;
        if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
          offset = idx / 8;
        }
        else {
          offset = idx * ptr_vec->field_size;
        }
        if ( chunk_idx != 0 ) { go_BYE(-1); } 
        if ( len != ptr_vec->chunk_size ) { go_BYE(-1); }
        addr = *ptr_ret_addr; // has been allocated before call 
        if ( addr == NULL ) { go_BYE(-1); }
        fp = fopen(ptr_vec->file_name, "r");
        return_if_fopen_failed(fp, ptr_vec->file_name, "r");
        status = fseek(fp, offset, SEEK_SET); cBYE(status);
        size_t nr = fread(addr, ptr_vec->field_size, len, fp);
        if ( nr != len ) { go_BYE(-1); }
        fclose_if_non_null(fp);
        ret_len = len;
      }
      else {
        // printf(" we have no hope of serving this chunk\n");
        *ptr_ret_addr = NULL;
        *ptr_ret_len  = 0;
        status = -2;
        goto BYE;
      }
    }
    else { // asking for a chunk ahead of where we currently are
      // printf(" we have no hope of serving this chunk\n");
      *ptr_ret_addr = NULL;
      *ptr_ret_len  = 0;
      status = -2;
      goto BYE;
    }
    /*
     * Consider a following use-case
     * - Create a nascent vector of any type say I4
     *   - Append 10 elements to it (num_in_chunk = 10)
     *   - Get first two elements i.e index=0 and length=2
     *
     *   Is this a valid use-case? 
     *   If yes, then what will the value of ret_len?
     *
     *   I tried this test (test_read_write.lua) and 
     *   my expectation was value of ret_len will be 2
     *   but I got different value i.e 10.
     *
     *   ret_len should be min(ptr_vec->num_in_chunk - chunk_idx, len)
     */
    ret_addr = addr; 
  }
  *ptr_ret_addr = ret_addr;
  *ptr_ret_len  = ret_len;
BYE:
  fclose_if_non_null(fp);
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_get += delta; }
  return status;
}

int
vec_add_B1(
    VEC_REC_TYPE *ptr_vec,
    char * addr, 
    int32_t len
    )
{
  int status = 0;
  uint32_t space_in_chunk;
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( addr == NULL ) { go_BYE(-1); }
  if ( len <  0 ) { go_BYE(-1); }
  if ( len == 0 ) { /* not an error, nothing to do */ goto BYE; }
  if ( !ptr_vec->is_nascent ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  //---------------------------------------
  if ( ptr_vec->is_no_memcpy ) {
    if ( ptr_vec->chunk != addr ) { go_BYE(-1); }
    if ( (uint32_t)len > ptr_vec->chunk_size ) { go_BYE(-1); }
    if ( ptr_vec->num_in_chunk != 0 ) { go_BYE(-1); }
  }
  //---------------------------------------
  if ( ptr_vec->chunk == NULL ) { 
    ptr_vec->chunk = l_malloc(ptr_vec->chunk_sz, ptr_vec);
    return_if_malloc_failed(ptr_vec->chunk);
    l_memset( ptr_vec->chunk, '\0', ptr_vec->chunk_sz);
  }

  if ( ( ptr_vec->num_in_chunk % 8 ) ==  0 ) {
    // we are nicely byte aligned
    for ( ; len > 0 ; ) { 
      space_in_chunk = ptr_vec->chunk_size - ptr_vec->num_in_chunk;
      if ( space_in_chunk == 0 ) { 
        status = flush_buffer(ptr_vec); cBYE(status);
        continue;
      }
      uint32_t num_bits_to_copy;
      uint32_t num_byts_to_copy;
      if ( (uint32_t)len < space_in_chunk ) { 
        num_bits_to_copy = len;
        num_byts_to_copy = ceil(num_bits_to_copy / 8.0);
      }
      else {
        num_bits_to_copy = space_in_chunk; 
        // this has to be a multiple of 8
        if ( ( ( num_bits_to_copy / 8 ) * 8 ) != num_bits_to_copy ) {
          go_BYE(-1);
        }
        num_byts_to_copy = num_bits_to_copy / 8;
      }
      char *dst = ptr_vec->chunk + (ptr_vec->num_in_chunk / 8);
      // Don't copy if generator already wrote into your internal buffer
      if ( !ptr_vec->is_no_memcpy ) { 
        l_memcpy(dst, addr, num_byts_to_copy);
      }
      ptr_vec->num_in_chunk += num_bits_to_copy;
      len  -= num_bits_to_copy;
      addr += num_byts_to_copy;
      ptr_vec->num_elements += num_bits_to_copy;
    }
  }
  else {
    // TODO P1: This needs some serious attention
    uint32_t src_bit_idx = 0;
    uint32_t src_wrd_idx = 0;
    for ( int32_t i = 0; i < len; i++ ) { // put 1 bit at a time 
      if ( ptr_vec->num_in_chunk == ptr_vec->chunk_size ) {
        // no space in buffer => flush it 
        status = flush_buffer(ptr_vec); cBYE(status);
      }
      uint32_t dst_bit_idx = ( ptr_vec->num_in_chunk % 8 );
      uint32_t dst_wrd_idx = ( ptr_vec->num_in_chunk / 8 );

      uint8_t src_bit = (((uint8_t *)addr)[src_wrd_idx] >> src_bit_idx) & 0x1;
      if ( src_bit == 1 ) {
        uint8_t mask = 1 << dst_bit_idx;
        ((uint8_t *)ptr_vec->chunk)[dst_wrd_idx] |= mask;
      }
      else {
        uint8_t mask = ~(1 << dst_bit_idx);
        ((uint8_t *)ptr_vec->chunk)[dst_wrd_idx] &= mask;
      }
      //----------------------------
      ptr_vec->num_in_chunk++;
      ptr_vec->num_elements++;
      src_bit_idx++; 
      dst_bit_idx++;
      if ( src_bit_idx == 8 ) { src_wrd_idx++; src_bit_idx = 0; }
      if ( dst_bit_idx == 8 ) { dst_wrd_idx++; dst_bit_idx = 0; }      
    }
  }

BYE:
  return status;
}

int
vec_add(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    int32_t len
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_add++;
  // START: Do some basic checks
  if ( ptr_vec == NULL ) { go_BYE(-1); }
  if ( addr == NULL ) { go_BYE(-1); }
  if ( len <  0 ) { go_BYE(-1); }
  if ( len == 0 ) { /* not an error, nothing to do */ goto BYE; }
  if ( !ptr_vec->is_nascent ) { go_BYE(-1); }
  if ( ptr_vec->is_eov ) { go_BYE(-1); }
  //---------------------------------------
  if ( ptr_vec->is_no_memcpy ) {
    if ( ptr_vec->chunk != addr ) { go_BYE(-1); }
    if ( (uint32_t)len > ptr_vec->chunk_size ) { go_BYE(-1); }
    // if ( ptr_vec->num_in_chunk != 0 ) { printf("hello world\n"); go_BYE(-1); }
  }
  //---------------------------------------
  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    status = vec_add_B1(ptr_vec, addr, len); cBYE(status);
    goto BYE; 
  }
  //---------------------------------------
  if ( ptr_vec->chunk == NULL ) { 
    ptr_vec->chunk = l_malloc(ptr_vec->chunk_sz, ptr_vec);
    return_if_malloc_failed(ptr_vec->chunk);
  }

  uint64_t initial_num_elements = ptr_vec->num_elements;
  uint32_t num_copied = 0;
  for ( uint32_t num_left_to_copy = len; num_left_to_copy > 0; ) {
    uint32_t space_in_chunk = 
      ptr_vec->chunk_size - ptr_vec->num_in_chunk;
    if ( space_in_chunk == 0 )  {
      status = flush_buffer(ptr_vec); cBYE(status);
    }
    else {
      uint32_t num_to_copy = mcr_min(space_in_chunk, num_left_to_copy);
      char *dst = ptr_vec->chunk + 
        (ptr_vec->num_in_chunk * ptr_vec->field_size);
      char *src = addr + (num_copied * ptr_vec->field_size);
      // Don't copy if generator already wrote into your internal buffer
      if ( !ptr_vec->is_no_memcpy ) { 
        l_memcpy(dst, src, (num_to_copy * ptr_vec->field_size));
      }
      ptr_vec->num_in_chunk += num_to_copy;
      ptr_vec->num_elements += num_to_copy;
      num_left_to_copy      -= num_to_copy;
      num_copied            += num_to_copy;
    }
  }
  if ( num_copied != (uint32_t)len ) { go_BYE(-1); }
  if ( ptr_vec->num_elements != initial_num_elements + len) {
    go_BYE(-1);
  }
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_add += delta; }
BYE:
  return status;
}

int
vec_start_write(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_start_write++;
  char *X = NULL; uint64_t nX = 0;
  if ( ( ptr_vec->is_eov == true ) && ( ptr_vec->is_memo == true ) ) {
    /* all is well */
  }
  else {
    go_BYE(-1);
  }
  // TODO P2: I am going to allow open in write even if opened 
  // in read mode but this needs more thought 
  if ( ptr_vec->open_mode == 0 ) {
    /* this situation is fine */
  }
  else if ( ptr_vec->open_mode == 1 ) {
    if ( ptr_vec->map_addr != NULL ) { 
      munmap(ptr_vec->map_addr, ptr_vec->map_len);
      ptr_vec->map_addr = NULL;
      ptr_vec->map_len = 0;
    }
  }
  if ( ptr_vec->map_addr  != NULL ) { go_BYE(-1); }
  if ( ptr_vec->map_len   != 0    ) { go_BYE(-1); }
  if ( ptr_vec->chunk     != NULL ) {
    status = vec_clean_chunk(ptr_vec); cBYE(status);
  }
  bool is_write = true;
  status = rs_mmap(ptr_vec->file_name, &X, &nX, is_write); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
  ptr_vec->map_addr  = X;
  ptr_vec->map_len   = nX;
  ptr_vec->open_mode = 2; // for write
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
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_end_write++;
  if ( ( ptr_vec->is_eov == true ) && ( ptr_vec->is_nascent == false ) &&
       ( ptr_vec->is_memo == true ) ) {
    /* all is well */
  }
  else {
    go_BYE(-1);
  }
  if ( ptr_vec->open_mode != 2    ) { go_BYE(-1); }
  if ( ptr_vec->map_addr  == NULL ) { go_BYE(-1); }
  if ( ptr_vec->map_len   == 0    )  { go_BYE(-1); }
  munmap(ptr_vec->map_addr, ptr_vec->map_len);
  ptr_vec->map_addr  = NULL;
  ptr_vec->map_len   = 0;
  ptr_vec->open_mode = 0; // not opened for read or write
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_end_write += delta; }
  return status;
}

int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint64_t idx, 
    uint32_t len
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_set++;
  if ( addr == NULL ) { go_BYE(-1); }
  if ( len == 0 ) { go_BYE(-1); }
  if ( ptr_vec->open_mode != 2 ) { go_BYE(-1); }
  if ( idx >= ptr_vec->num_elements ) { go_BYE(-1); }
  if ( idx+len > ptr_vec->num_elements ) { go_BYE(-1); }
  uint64_t offset = ( idx * ptr_vec->field_size);
  if ( offset > ptr_vec->map_len ) { go_BYE(-1); }

  if ( strcmp(ptr_vec->field_type, "B1") == 0 ) {
    /* you can either set one bit or set on word boundary */
    if ( ( len == 1 ) || ( ( idx % 64 ) == 0 ) ) { 
      if ( len == 1 ) {
        int64_t word_idx = idx / 64;
        int64_t bit_idx = idx % 64;
        uint64_t *X  =(uint64_t *)ptr_vec->map_addr;
        // TODO P2: To review following and test carefully
        bool bit_val = (((uint8_t *)addr)[0]) & 0x1; 
        if ( bit_val ) { 
          X[word_idx] = X[word_idx] | (1 << bit_idx);
        }
        else {
          X[word_idx] = X[word_idx] & ~((1 << bit_idx));
        }
      }
      else {
        // TODO P2: Needs to be finished. 
      }
    }
    else {
      go_BYE(-1);
    }
  }
  else {
    char *dst = ptr_vec->map_addr + offset;
    l_memcpy(dst, addr,len * ptr_vec->field_size); 
  }
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_set += delta; }
  return status;
}

int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    )
{
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_persist++;
  int status = 0;
  if ( ptr_vec->is_memo == false ) { go_BYE(-1); }
  ptr_vec->is_persist = is_persist;
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_persist += delta; }
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
  strcpy(ptr_vec->name, name);
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
int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  uint64_t delta = 0, t_start = RDTSC(); n_l_vec_eov++;
  if ( ptr_vec->is_eov       == true  ) { 
    // fprintf(stderr, "Already eov, nothing to do\n"); 
    return status; 
  } 
  if ( ptr_vec->is_nascent   == false ) { go_BYE(-1); }
  if ( ptr_vec->num_elements == 0     ) { 
    // unlikely but one has to account for this corner case 
    ptr_vec->is_eov = true;
    return status;
  } 
  //----------------------------------------
  if ( ptr_vec->chunk        == NULL  ) { go_BYE(-1); }
  ptr_vec->is_eov = true;
  // If memo NOT set, return now; do not persist to disk
  if ( ptr_vec->is_memo == false ) { goto BYE; }
  // If you don't have a file name as yet, create one. 
  // this is the case when all data fits into one chunk
  if ( !isfile(ptr_vec->file_name) ) {
    // create randomly generated file name and append to ptr_vec->file_name field
    status = update_file_name(ptr_vec); cBYE(status);
  }
  if ( ptr_vec->num_in_chunk == 0 ) {
    // in case of no_memcpy, flush buffer might have been called already
    if ( !ptr_vec->is_no_memcpy ) { go_BYE(-1); }
  }
  else {
    status = buf_to_file(ptr_vec->chunk, ptr_vec->field_size, 
        ptr_vec->field_type, ptr_vec->num_in_chunk, ptr_vec->file_name);
    cBYE(status);
  }
  ptr_vec->file_size = get_file_size(ptr_vec->file_name);
  // Commenting this out ptr_vec->is_nascent = false;

  // We defer mmaping the file to when access is requested
  // We defer deleting the chunk until vec_clean_chunk is called
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_eov += delta; }
  return status;
}
