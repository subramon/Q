#include "q_incs.h"
#include "qtypes.h"
#include "../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/rs_hmap_struct.h"
#include "vctr_cnt.h"

extern vctr_rs_hmap_t g_vctr_hmap;

uint32_t
vctr_cnt(
    void
    )
{
  return g_vctr_hmap.nitems;
}
