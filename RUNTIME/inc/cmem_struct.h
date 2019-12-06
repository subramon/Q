#ifndef __CMEM_STRUCT_H
#define __CMEM_STRUCT_H

#define Q_MAX_LEN_CMEM_NAME 15
typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[Q_MAX_LEN_QTYPE_NAME+1]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[Q_MAX_LEN_CMEM_NAME+1]; // + 1 for nullc, mainly for debugging
  bool is_foreign; // true => do not delete 
  int  ref_count; // Feature in progress
} CMEM_REC_TYPE;
#endif
