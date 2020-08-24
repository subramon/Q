#ifndef __VEC_STRUCT_H
#define __VEC_STRUCT_H
#include "qmem_struct.h"
//START_FOR_CDEF
#include "q_constants.h"

typedef struct _vec_rec_type {
  char fldtype[Q_MAX_LEN_QTYPE_NAME+1]; // set by vec_new()
  uint32_t field_width; // set by vec_new()
  // Redundant: uint32_t chunk_size_in_bytes; // set by vec_new()
  uint64_t uqid; // unique identifier across all vectors. Set by vec_new() 
  uint32_t whole_vec_dir_idx;  // points in to whole_vec_dir;
  // whole_vec_dir[whole_vec_dir_idx].uqid == uqid 

  uint64_t num_elements; // starts at 0, increases monotonically
  char name[Q_MAX_LEN_INTERNAL_NAME+1]; 
  // system does not enforce any constraints on name other than it be
  // alphanumeric and no more than specified length. Useful for debugging

  bool is_persist;
  bool is_memo;
  bool is_eov;
  bool is_dead; // true=> all C resources freed. Waiting for Lua to GC
  bool is_killable; 
  // if you get kill signal and is_killable = true, commit suicide
  // if you get kill signal and is_killable = false, ignore it 

  /* Difference between num_chunks and sz_chunks is as follows.
   * sz_chunks tells us how big the chunk array is.
   * num_chunks tells us how many of them have been used */
  uint32_t *chunks;  // [sz_chunks] 
  // i <= j and chunk[i] == 0 => chunk[j] = 0
  uint32_t num_chunks; 
  uint32_t sz_chunks; // num_chunks <= sz_chunks
  // if is_memo == false, sz_chunks = 1
} VEC_REC_TYPE;

//STOP_FOR_CDEF

#endif
