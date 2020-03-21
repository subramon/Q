#include "hmap_utils.h"
#include "hmap_common.h"
#include "hmap_types.h"
#ifndef __hmap_instantiate_H
#define __hmap_instantiate_H
extern int 
hmap_instantiate(
    hmap_t *ptr_hmap,
    size_t minsize,
    size_t maxsize
    );
#endif
