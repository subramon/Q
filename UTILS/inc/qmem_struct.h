#ifndef __QMEM_STRUCT_H
#define __QMEM_STRUCT_H
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
//START_FOR_CDEF
typedef struct _chunk_rec_type {
  // Redundant uint32_t num_in_chunk; 
  uint64_t uqid; // unique identifier across all chunks
  //
  // (vec_uqid, chunk_num) are pointer back to parent
  uint64_t vec_uqid; // pointer to parent 
  uint32_t chunk_num;   // 0 <= chunk_num <  num_chunks
  // chunk_num is a reverse pointer to chunks in VEC_REC_TYPE
  uint64_t t_last_get; // time of last read acces
  // TODO P3 Be precise on when above is updated

  bool is_file;  // has chunk been backed up to a file?
  // name of file is derived using mk_file_name()
  char *data; 
  // Invariant: (is_file == true) or (data != NULL) 
  int num_readers;
} CHUNK_REC_TYPE;

typedef struct _whole_vec_rec_type { 
  uint64_t uqid; // unique identifier across all vectors
  bool is_file;  
  // if is_file = true, following fields are relevant
  // Used when entire vector access needed using mmap
  // In qmem_struct: name of file is derived using mk_file_name()
  size_t file_size; 
  char *mmap_addr; // if opened for mmap
  size_t mmap_len; // if opened for mmap
  int num_readers;
  int num_writers;
}  WHOLE_VEC_REC_TYPE;

typedef struct _whole_vec_dir_t { 
  WHOLE_VEC_REC_TYPE *whole_vecs;  // [sz]
  uint32_t sz; 
  uint32_t n;  // 0 <= n <= sz 
} whole_vec_dir_t;

typedef struct _chunk_dir_t { 
  CHUNK_REC_TYPE *chunks;  // [sz]
  uint32_t sz; 
  uint32_t n;  // 0 <= n <= sz 
} chunk_dir_t;

typedef struct _qmem_struct_t { 
  char *q_data_dir; 
  uint64_t uqid_gen;  // used to generate unique IDs

  whole_vec_dir_t *whole_vec_dir;
  chunk_dir_t *chunk_dir;
  uint64_t chunk_size;  // size of vector chunk

  uint64_t max_mem_KB; // how much memory Q can use 
  uint64_t now_mem_KB; // how much memory Q has used

} qmem_struct_t;
//STOP_FOR_CDEF
#endif
