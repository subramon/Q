#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_cnt.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

// Returns number of vectors in this tablespace 
uint32_t
vctr_cnt(
    uint32_t tbsp
    )
{
  return g_vctr_hmap[tbsp].nitems;
}
