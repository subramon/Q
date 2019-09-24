#ifndef __VEC_STRUCT_H
#define __VEC_STRUCT_H
#include "q_constants.h"

typedef struct _chunk_rec_type {
  uint32_t num_in_chunk; // 0 < num_in_chunk <= num_elements_in_chunk 
  uint64_t uqid; // unique identifier across all chunks
  // (vec_uqid, chunk_num) are pointer back to parent
  uint32_t chunk_num;   // 0 <= chunk_num <  num_chunks
  uint64_t vec_uqid; // pointer to parent 
  char file_name[Q_MAX_LEN_FILE_NAME+1];
  void *data; 
} CHUNK_REC_TYPE;

typedef struct _vec_rec_type {
  char fldtype[Q_MAX_LEN_QTYPE_NAME+1]; // set by vec_new()
  uint32_t field_width; // set by vec_new()
  uint32_t chunk_size_in_bytes; // set by vec_new()
  uint32_t num_chunks; 

  uint64_t num_elements;
  char name[Q_MAX_LEN_VEC_NAME+1]; 

  uint64_t uqid; // unique identifier across all vectors
  char file_name[Q_MAX_LEN_FILE_NAME+1]; // if entire vector access needed
  size_t file_size; // if entire vector access needed
  char *mmap_addr; // if opened for mmap
  size_t mmap_len; // if opened for mmap

  bool is_persist;
  bool is_memo;
  bool is_mono;
  bool is_eov;
  bool is_no_memcpy; // true=> we are trying to reduce memcpy
  bool is_dead; // true=> all C resources freed. Waiting for Lua to GC

  int access_mode; // 0 = unopened, 1 = read, 2 = write
  int sz_chunk_dir_idx; // num_chunks <= sz_chunks
  uint32_t *chunk_dir_idxs;  // [sz_chunk_dir_idx] 0 indicates empty
} VEC_REC_TYPE;

#endif
