#ifndef __AGG_H
#define __AGG_H

typedef struct _agg_rec_type {
  char keytype[Q_MAX_LEN_QTYPE_NAME+1]; 
  char valtype[Q_MAX_LEN_QTYPE_NAME+1];
  char name[Q_MAX_LEN_INTERNAL_NAME+1];
  void *hmap; 
} AGG_REC_TYPE;

extern int
agg_meta(
    AGG_REC_TYPE *ptr_agg,
    char *opbuf
    );
extern int
agg_new(
    uint32_t     initial_size,
    const char * const keytype,
    const char * const valtype,
    AGG_REC_TYPE *ptr_agg
    );
extern int
agg_check(
    AGG_REC_TYPE *ptr_agg
    );
extern int
agg_delete(
    AGG_REC_TYPE *ptr_agg
    );
extern int
agg_num_elements(
    AGG_REC_TYPE *ptr_agg
    );
extern int
agg_free(
    AGG_REC_TYPE *ptr_agg
    );
extern int
agg_set_name(
    AGG_REC_TYPE *ptr_agg,
    const char * const name
    );
#endif

