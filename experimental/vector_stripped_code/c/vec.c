#include "q_incs.h"
#include "mmap_types.h"
#include "vec.h"
#include "_mmap.h"
#include "_rand_file_name.h"
#include "_get_file_size.h"
#include "_buf_to_file.h"

int
vec_free(
    VEC_REC_TYPE *ptr_vec
    )
{
  printf("#################################################################################################################################\n");
  printf("vec_free called\n");
  int status = 0;
  if ( ptr_vec == NULL ) {  go_BYE(-1); }
  if ( ptr_vec->chunk != NULL ) { 
    // printf("%8x\n", ptr_vec->chunk);
    free(ptr_vec->chunk);
    ptr_vec->chunk = NULL;
  }
// Commenting below code, not sure whether to delete file or not
/*
  if ( ptr_vec->is_persist != 1 ) {
    if ( ptr_vec->file_name[0] != '\0' ) {
      status = remove(ptr_vec->file_name); cBYE(status);
    }
    if ( file_exists(ptr_vec->file_name) ) { go_BYE(-1); }
    memset(ptr_vec->file_name, '\0', Q_MAX_LEN_FILE_NAME+1);
  }
*/
  free(ptr_vec);
BYE:
  return status;
}

int 
vec_new(
    VEC_REC_TYPE *ptr_vec,
    uint32_t field_size,
    uint32_t chunk_size
    )
{
  int status = 0;

  if ( ptr_vec == NULL ) { go_BYE(-1); }
  memset(ptr_vec, '\0', sizeof(VEC_REC_TYPE));
  if ( field_size == 0 ) { go_BYE(-1); }
  if ( chunk_size == 0 ) { go_BYE(-1); }

  ptr_vec->field_size = field_size;
  ptr_vec->chunk_size = chunk_size; 
  uint32_t sz = ptr_vec->field_size * ptr_vec->chunk_size;
  ptr_vec->chunk = malloc(sz);
BYE:
  return status;
}

bool 
file_exists (
    const char * const filename
    )
{
  int status = 0; struct stat buf;
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { return false; }
  status = stat(filename, &buf );
  if ( status == 0 ) { /* File found */
    return true;
  }
  else {
    return false;
  }
}

int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char *addr, 
    uint32_t len
    )
{
  int status = 0;
  uint64_t initial_num_elements = ptr_vec->num_elements;
  uint32_t num_copied = 0;
  for ( uint32_t num_left_to_copy = len; num_left_to_copy > 0; ) {
     uint32_t space_in_chunk = 
       ptr_vec->chunk_size - ptr_vec->num_in_chunk;
     if ( space_in_chunk == 0 )  {
       printf("Space in chunk is zero");
       if ( ptr_vec->file_name[0] == '\0' ) {
         status = rand_file_name(ptr_vec->file_name, Q_MAX_LEN_FILE_NAME);
         cBYE(status);
       }
       printf("Writing buffer to file\n");
       status = buf_to_file(ptr_vec->chunk, ptr_vec->field_size, 
           ptr_vec->num_in_chunk, ptr_vec->file_name);
       printf("Writing Done\n");
       cBYE(status);
       ptr_vec->num_in_chunk = 0;
       ptr_vec->chunk_num++;
       memset(ptr_vec->chunk, '\0', 
           (ptr_vec->field_size * ptr_vec->chunk_size));
     }
     else {
       uint32_t num_to_copy = mcr_min(space_in_chunk, len);
       printf("num_in_chunk: %d, ............ num_elements: %d\n", ptr_vec->num_in_chunk, ptr_vec->num_elements);
       char *dst = ptr_vec->chunk + 
         (ptr_vec->num_in_chunk * ptr_vec->field_size);
       char *src = addr + (num_copied * ptr_vec->field_size);
       printf("Copying contents\n");
       memcpy(dst, src, (num_to_copy * ptr_vec->field_size));
       printf("Copying done\n");
       ptr_vec->num_in_chunk += num_to_copy;
       ptr_vec->num_elements += num_to_copy;
       num_left_to_copy      -= num_to_copy;
       num_copied            += num_to_copy;
     }
  }
  if ( num_copied != len ) { go_BYE(-1); }
  if ( ptr_vec->num_elements != initial_num_elements + len) {
    go_BYE(-1);
  }
BYE:
  return status;
}

