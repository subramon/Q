#ifndef __CMEM_STRUCT_H
#define __CMEM_STRUCT_H
//START_FOR_CDEF
#include "cmem_consts.h"
#include "qtypes.h"
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  qtype_t qtype;
  char cell_name[Q_MAX_LEN_CELL_NAME+1];
  bool is_foreign; // true => do not delete 
  bool is_stealable; // true => data can be stolen
} CMEM_REC_TYPE;
//STOP_FOR_CDEF
#endif
