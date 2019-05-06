#ifndef __mmap_types_h
#define __mmap_types_h
#include "q_constants.h"
typedef struct _mmap_rec_type {
  // TODO Change 255 to  Q_MAX_LEN_FILE_NAME
  char file_name[255+1];
    void *map_addr;
    size_t map_len;
    int is_persist;
    int status;
} MMAP_REC_TYPE;

typedef struct _vec_rec_type {
  char field_type[3+1];
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
#endif
