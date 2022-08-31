#include "q_incs.h"

#include "rs_hmap_common.h"
#include "qtypes.h"
#include "rs_hmap_int_types.h"
#include "rs_hmap_struct.h"

#include "vctr_cnt.h"

extern rs_hmap_t g_vctr_hmap;

uint32_t
vctr_cnt(
    void
    )
{
  return g_vctr_hmap.nitems;
}
