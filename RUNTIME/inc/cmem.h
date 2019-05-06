#ifndef __CMEM_H
#define __CMEM_H

typedef struct _cmem_rec_type {
  void *data;
  int64_t size;
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  char cell_name[16]; // 15 chaarcters + 1 for nullc, mainly for debugging
  bool is_foreign; // true => do not delete 
} CMEM_REC_TYPE;

extern int cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    const char *field_type,
    const char *cell_name
    );
extern int cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    const char *field_type,
    const char *cell_name,
    int alignment
    );
extern void cmem_undef( // USED FOR DEBUGGING
    CMEM_REC_TYPE *ptr_cmem
    );
extern int cmem_decrement_sz_malloc( 
    uint64_t sz
    );
extern int
cmem_get_sz_malloc( 
    void
);
#undef MM
#ifdef MM
extern int
incr_vec_mem(
    uint64_t sz
    );
extern int
decr_vec_mem(
    uint64_t sz
    );
extern uint64_t
get_vec_mem(
    void
    );
extern int
incr_cmem_mem(
    uint64_t sz
    );
extern int
decr_cmem_mem(
    uint64_t sz
    );
extern uint64_t
get_cmem_mem(
    void
    );
#endif

#endif
