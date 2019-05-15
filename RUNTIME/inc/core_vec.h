#ifndef __VEC_H
#define __VEC_H
#include "cmem.h"

typedef struct _vec_rec_type {
  char field_type[3+1]; // TODO Do not hard code length
  uint32_t field_size;
  uint32_t chunk_size;

  uint64_t num_elements;
  uint32_t num_in_chunk;
  uint32_t chunk_num;   

  // TODO Change 31 to  Q_MAX_LEN_INTERNAL_NAME
  char name[31+1]; 
  // TODO Change 255 to  Q_MAX_LEN_FILE_NAME
  char file_name[255+1];
  uint64_t file_size; // valid only after eov()
  char *map_addr;
  size_t map_len;

  bool is_persist;
  bool is_nascent;
  bool is_memo;
  bool is_eov;
  int open_mode; // 0 = unopened, 1 = read, 2 = write
  uint64_t uqid; // used for matching chunk free with malloc
  char *chunk;
  uint32_t chunk_sz; // number of bytes allocated for chunk
  bool is_no_memcpy; // true=> we are trying to reduce memcpy
  bool is_virtual; // TO BE DEPRECATED
} VEC_REC_TYPE;

extern void
vec_reset_timers(
    void
    );
extern void
vec_print_timers(
    void
    );
extern uint64_t
vec_print_mem(
   void 
    );
extern int
chk_field_type(
    const char * const field_type,
    uint32_t field_size
    );
extern int
vec_meta(
    VEC_REC_TYPE *ptr_vec,
    char *opbuf
    );
extern int
vec_nascent(
    VEC_REC_TYPE *ptr_vec
    );
extern int
update_file_name(
    VEC_REC_TYPE *ptr_vec
    );
extern int
get_qtype_and_field_size(
    const char * const field_type,
    char * res_qtype,
    int * res_field_size
    );
extern int
vec_new(
    VEC_REC_TYPE *ptr_vec,
    const char * const field_type,
    const char *const q_data_dir,
    uint32_t chunk_size,
    bool is_memo,
    const char *const file_name,
    int64_t num_elements
    );
extern int
vec_new_virtual(
    VEC_REC_TYPE *ptr_vec,
    char * map_addr,
    const char * const field_type,
    uint32_t chunk_size,
    int64_t num_elements
    );
extern int
vec_materialized(
    VEC_REC_TYPE *ptr_vec,
    const char *const file_name
    );
extern int
vec_check(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint64_t idx, 
    uint32_t len
    );
extern int
vec_eov(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_persist(
    VEC_REC_TYPE *ptr_vec,
    bool is_persist
    );
extern int
vec_get(
    VEC_REC_TYPE *ptr_vec,
    uint64_t idx, 
    uint32_t len,
    char **ptr_ret_addr,
    uint64_t *ptr_ret_len
    );
extern int
is_eq_I4(
    void *X,
    int val
    );
extern int
vec_memo(
    VEC_REC_TYPE *ptr_vec,
    bool is_memo
    );
extern int
vec_add(
    VEC_REC_TYPE *ptr_vec,
    char * const addr, 
    uint32_t len
    );
extern int
vec_add_B1(
    VEC_REC_TYPE *ptr_vec,
    char * addr, 
    uint32_t len
    );
extern int flush_buffer_B1(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
flush_buffer(
          VEC_REC_TYPE *ptr_vec
          );
extern int
vec_start_write(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_end_write(
    VEC_REC_TYPE *ptr_vec
    );
extern int
vec_set_name(
    VEC_REC_TYPE *ptr_vec,
    const char * const name
    );
extern char *
vec_get_name(
    VEC_REC_TYPE *ptr_vec
    );
extern int 
vec_cast(
    VEC_REC_TYPE *ptr_vec,
    const char * const new_qtype,
    uint32_t new_width
    );
extern int
vec_clean_chunk(
    VEC_REC_TYPE *ptr_vec
    );
extern char *
vec_get_buf(
  VEC_REC_TYPE *ptr_vec
);
extern int 
vec_clone(
    VEC_REC_TYPE *ptr_old_vec,
    VEC_REC_TYPE *ptr_new_vec,
    const char *const q_data_dir
    );
extern int 
vec_no_memcpy(
    VEC_REC_TYPE *ptr_vec,
    CMEM_REC_TYPE *ptr_cmem,
    size_t chunk_size
    );
extern int
vec_delete(
    VEC_REC_TYPE *ptr_vec
    );
#endif
