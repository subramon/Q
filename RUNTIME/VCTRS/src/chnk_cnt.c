#include "q_incs.h"
#include "qtypes.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"

extern chnk_rs_hmap_t g_chnk_hmap;

uint32_t
chnk_cnt(
    void
    )
{
  return g_chnk_hmap.nitems;
}
