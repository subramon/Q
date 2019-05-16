#ifndef __CMEM_STRUCT_H
#define __CMEM_STRUCT_H

typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
  bool is_foreign; // true => do not delete 
} CMEM_REC_TYPE;
#endif
