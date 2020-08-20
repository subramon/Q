#ifndef __QMEM_STRUCT_H
#define __QMEM_STRUCT_H
//START_FOR_CDEF
typedef struct _chunk_rec_type {
  // Redundant uint32_t num_in_chunk; 
  uint64_t uqid; // unique identifier across all chunks
  //
  // (vec_uqid, chunk_num) are pointer back to parent
  uint64_t vec_uqid; // pointer to parent 
  uint32_t chunk_num;   // 0 <= chunk_num <  num_chunks
  uint64_t t_last_get; // time of last read acces

  bool is_file;  // has chunk been backed up to a file?
  // name of file is derived using mk_file_name()
  char *data; 
  // Invariant: (is_file == true) or (data != NULL) 
  int num_readers;
} CHUNK_REC_TYPE;

typedef struct _chunk_dir_t { 
  CHUNK_REC_TYPE *chunks;  // [sz]
  uint32_t sz; 
  uint32_t n;  // 0 <= n <= sz 
} chunk_dir_t;

typedef struct _qmem_struct_t { 
  char *q_data_dir; 
  uint64_t max_file_num; 

  chunk_dir_t *chunk_dir;
  uint64_t chunk_size;  // size of vector chunk

  uint64_t max_mem_KB; // how much memory Q can use 
  uint64_t now_mem_KB; // how much memory Q has used

} qmem_struct_t;
//STOP_FOR_CDEF
#endif
