#include "q_incs.h"
#include "aux_core_vec.h"
#include "cmem.h"
int
chk_chunk(
      uint32_t chunk_dir_idx,
      bool is_free
      )
{
  int status = 0;
  if ( chunk_dir_idx >= g_sz_chunks ) { go_BYE(-1); }
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  if ( is_free ) { // we expect this to be free 
    if ( ptr_chunk->num_in_chunk != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->chunk_num != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->uqid != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->vec_uqid != 0 ) { go_BYE(-1); }
    if ( *ptr_chunk->file_name != '\0' ) { go_BYE(-1); }
    if ( ptr_chunk->data != NULL ) { go_BYE(-1); }
  }
  else {
    if ( ptr_chunk->uqid == 0 ) { go_BYE(-1); }
    if ( ptr_chunk->vec_uqid == 0 ) { go_BYE(-1); }
    if ( ptr_chunk->data == NULL ) { go_BYE(-1); }
  }
BYE:
  return status;
}

bool 
is_file_size_okay(
    const char *const file_name,
    size_t expected_size
    )
{
  if ( ( file_name == '\0' ) && ( expected_size == 0 ) ) { return true; }
  actual_size = get_file_size(file_name);
  if ( actual_fsz !=  expected_size ) { return false; }
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

int
free_chunk(
    uint32_t chunk_dir_idx,
    bool is_persist
    )
{
  int status = 0;
  status = chk_chunk(chunk_dir_idx, false); cBYE(status);

  CHUNK_REC_TYPE *ptr_chunk =  g_chunk_dir+chunk_dir_idx;
  free_if_non_null(ptr_chunk->chunks[i].data);
  if ( !is_persist ) { 
    if isfile(ptr_chunk->chunks[i].file_name)  {
      remove(ptr_chunk->chunks[i].file_name);
    }
  }
  memset(ptr_chunk, '\0', sizeof(CHUNK_REC_TYPE));
BYE:
  delta = RDTSC() - t_start; if ( delta > 0 ) { t_l_vec_free += delta; }
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
load_chunk(
    CHUNK_REC_TYPE *ptr_chunk, 
    VEC_REC_TYPE *ptr_vec
    )
{
  int status = 0;
  if ( ptr_chunk->data != NULL ) { return status; } // already loaded
  //-- Get the chunk from its backup file if it exists
  if ( *ptr_chunk->file_name != '\0' ) {
    char *X = NULL; size_t nX = 0;
    status = rs_mmap(ptr_chunk->file_name, &X, &nX, 0); cBYE(status);
    if ( X == NULL ) { go_BYE(-1); }
    if ( nX != ptr_vec->chunk_size_in_bytes ) { go_BYE(-1); }
    ptr_chunk->data = l_malloc(ptr_vec->chunk_size_in_bytes);
    return_if_malloc_failed( ptr_chunk->data);
    memcpy( ptr_chunk->data, X, nX);
    munmap(X, nX);
    *ptr_data = ptr_chunk->data; 
    // TODO P1 Need to set num_in_chunk
  }
  else {
  //-- Get the chunk from vector's backup file if it exists
  if ( *ptr_vec->file_name != '\0' ) {
    char *X = NULL; size_t nX = 0;
    status = rs_mmap(ptr_vec->file_name, &X, &nX, 0); cBYE(status);
    if ( X == NULL ) { go_BYE(-1); }
    if ( nX != ptr_vec->file_size ) { go_BYE(-1); }
    ptr_chunk->data = l_malloc(ptr_vec->chunk_size_in_bytes);
    return_if_malloc_failed( ptr_chunk->data);
    size_t offset = ptr_vec->chunk_size_in_bytes*chunk_num;
    memcpy( ptr_chunk->data, X+offset, nX);
    munmap(X, nX);
  }
BYE:
  return status;
}
int
chk_chunk(
      uint32_t chunk_dir_idx,
      bool is_free
      )
{
  int status = 0;
  if ( chunk_dir_idx >= g_sz_chunk_dir ) { go_BYE(-1); }
  CHUNK_REC_TYPE *ptr_chunk = g_chunk_dir + chunk_dir_idx;
  if ( is_free ) { // we expect this to be free 
    if ( ptr_chunk->num_in_chunk != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->chunk_num != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->uqid != 0 ) { go_BYE(-1); }
    if ( ptr_chunk->vec_uqid != 0 ) { go_BYE(-1); }
    if ( *ptr_chunk->file_name != '\0' ) { go_BYE(-1); }
    if ( ptr_chunk->data != NULL ) { go_BYE(-1); }
  }
  else {
    if ( ptr_chunk->uqid == 0 ) { go_BYE(-1); }
    if ( ptr_chunk->vec_uqid == 0 ) { go_BYE(-1); }
    if ( ptr_chunk->data == NULL ) { go_BYE(-1); }
    if ( ptr_chunk->num_in_chunk == 0 ) { 
      // if no data, then can be no file
      if ( *ptr_chunk->file_name != '\0' ) { go_BYE(-1); }
    }
  }
BYE:
  return status;
}

int32_t 
allocate_chunk(
    void
    )
{
  return 1;
}

int64_t 
get_exp_file_size(
    uint64_t num_elements,
    uint32_t field_size,
    const char * const fldtype
    )
{
  int64_t expected_file_size = num_elements * ptr_vec->field_size;
  if ( strcmp(fldtype, "B1") == 0 ) {
    uint64_t num_words = num_elements / 64;
    if ( ( num_words * 64 ) != num_elements ) { num_words++; }
    expected_file_size = num_words * 8;
  }
  return expected_file_size;
}

