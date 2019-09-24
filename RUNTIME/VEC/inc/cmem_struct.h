#ifndef __CMEM_STRUCT_H
#define __CMEM_STRUCT_H

typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char fldtype[Q_MAX_LEN_QTYPE_NAME+1]; 
  char cell_name[Q_MAX_LEN_INTERNAL_NAME+1]; 
  bool is_foreign; // true => do not delete 
  int  ref_count; // Feature in progress
} CMEM_REC_TYPE;
#endif
