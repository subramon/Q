#ifndef __AGG_STRUCT_H
#define __AGG_STRUCT_H
typedef struct _agg_rec_type {
  char keytype[Q_MAX_LEN_QTYPE_NAME+1]; 
  char valtype[Q_MAX_LEN_QTYPE_NAME+1];
  char name[Q_MAX_LEN_INTERNAL_NAME+1];
  void *hmap; 
} AGG_REC_TYPE;
#endif
