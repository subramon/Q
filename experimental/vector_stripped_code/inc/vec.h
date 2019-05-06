#ifndef __VEC_H
#define __VEC_H
#include "mmap_types.h"

extern int
vec_new(
    VEC_REC_TYPE *ptr_vec,
    uint32_t field_size,
    uint32_t chunk_size
    );

extern int
vec_free(
    VEC_REC_TYPE *ptr_vec
    );

extern bool 
file_exists (
    const char * constfilename
    );

extern int
vec_set(
    VEC_REC_TYPE *ptr_vec,
    char *addr, 
    uint32_t len
    );

#endif
