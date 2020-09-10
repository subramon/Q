#ifndef __CMEM_STRUCT_H
#define __CMEM_STRUCT_H
//START_FOR_CDEF
#include "cmem_constants.h"
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  int width;
  char fldtype[Q_MAX_LEN_QTYPE_NAME+1]; 
  char *cell_name;
  bool is_foreign; // true => do not delete 
  bool is_stealable; // true => data can be stolen
} CMEM_REC_TYPE;
//STOP_FOR_CDEF
#endif
