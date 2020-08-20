#ifndef __VEC_STRUCT_H
#define __VEC_STRUCT_H
//START_FOR_CDEF
#include "q_constants.h"
#include "qmem_struct.h"

typedef struct _vec_rec_type {
  char fldtype[Q_MAX_LEN_QTYPE_NAME+1]; // set by vec_new()
  uint32_t field_width; // set by vec_new()
  uint32_t chunk_size_in_bytes; // set by vec_new()
  uint64_t uqid; // unique identifier across all vectors. Set by vec_new() 

  uint64_t num_elements; // starts at 0, increases monotonically
  char name[Q_MAX_LEN_INTERNAL_NAME+1]; 
  // system does not enforce any constraints on name other than it be
  // alphanumeric and no more than specified length. Useful for debugging


  // if is_file = true, following fields are relavant
  // Used when entire vector access needed using mmap
  bool is_file;  // has Vector been backed up to a file? Only if is_eov=true
  // name of file is derived using mk_file_name()
  size_t file_size; // if entire vector access needed
  char *mmap_addr; // if opened for mmap
  size_t mmap_len; // if opened for mmap
  int num_readers;
  int num_writers;
  //----------------------------------

  bool is_persist;
  bool is_memo;
  bool is_eov;
  bool is_dead; // true=> all C resources freed. Waiting for Lua to GC
  bool is_killable; 
  // if you get kill signal and is_killable = true, commit sicide
  // if you get kill signal and is_killable = false, ignore it 

  /* Difference between num_chunks and sz_chunks is as follows.
   * sz_chunks tells us how big the chunk array is.
   * num_chunks tells us how many of them have been used */
  uint32_t num_chunks; 
  uint32_t sz_chunks; // num_chunks <= sz_chunks
  // if is_memo == false, sz_chunks = 1
  uint32_t *chunks;  // [sz_chunks] 
  // i <= j and chunk[i] == 0 => chunk[j] = 0
} VEC_REC_TYPE;

//STOP_FOR_CDEF

#endif
