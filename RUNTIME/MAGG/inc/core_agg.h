#ifndef __AGG_H
#define __AGG_H
#include "agg_struct.h"
#include "cmem_struct.h"


extern int
agg_meta(
    AGG_REC_TYPE *ptr_agg,
    char *opbuf
    );
extern int
agg_new(
    const char * const keytype,
    const char * const valtype,
    uint32_t     initial_size,
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
extern int 
agg_put1(
    SCLR_REC_TYPE *ptr_key,
    SCLR_REC_TYPE *ptr_val,
    int update_type,
    CDATA_TYPE *ptr_oldval,
    AGG_REC_TYPE *ptr_agg
    );
extern int 
agg_get1(
    SCLR_REC_TYPE *ptr_key,
    const char *const valqtype,
    CDATA_TYPE *ptr_oldval,
    bool *ptr_is_found,
    AGG_REC_TYPE *ptr_agg
    );
extern int 
agg_del1(
    SCLR_REC_TYPE *ptr_key,
    const char *const valqtype,
    CDATA_TYPE *ptr_oldval,
    bool *ptr_is_found,
    AGG_REC_TYPE *ptr_agg
    );
extern int 
agg_get_meta(
    AGG_REC_TYPE *ptr_agg,
    uint32_t *ptr_nitems,
    uint32_t *ptr_size
    );
extern int 
agg_putn(
    AGG_REC_TYPE *ptr_agg,
    CMEM_REC_TYPE *keys,
    int update_type,
    CMEM_REC_TYPE *hashes,
    CMEM_REC_TYPE *locs,
    CMEM_REC_TYPE *tids,
    int nT,
    CMEM_REC_TYPE *vals,
    int nkeys, /* TODO P4 Undo Assumption that nkeys <= 2^31 */
    CMEM_REC_TYPE *is_founds
    );
extern int 
agg_getn(
    AGG_REC_TYPE *ptr_agg,
    CMEM_REC_TYPE *keys,
    CMEM_REC_TYPE *cmem_hashes,
    CMEM_REC_TYPE *cmem_locs,
    CMEM_REC_TYPE *vals,
    int nkeys
    );
#endif
