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
  uint32_t field_size;
  uint32_t chunk_size;

  uint32_t num_elements;
  uint32_t num_in_chunk;
  uint32_t chunk_num;   

  // TODO Change 255 to  Q_MAX_LEN_FILE_NAME
  char file_name[255+1];

  int status;
  char *chunk;
} VEC_REC_TYPE;
#endif
