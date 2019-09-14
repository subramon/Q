#ifndef __AGG_STRUCT_H
#define __AGG_STRUCT_H
// TODO P3 Need to use these from UTILS/inc/q_consts.h and not hard coded
// #define Q_MAX_LEN_INTERNAL_NAME  31
// #define Q_MAX_LEN_QTYPE_NAME    3
typedef struct _agg_rec_type {
  char keytype[3+1]; 
  char valtype[3+1];
  char name[31+1];
  void *hmap; 
} AGG_REC_TYPE;
#endif
