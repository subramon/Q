#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_cnt.h"

extern chnk_rs_hmap_t g_chnk_hmap[Q_MAX_NUM_TABLESPACES];

uint32_t
chnk_cnt(
    uint32_t tbsp
    )
{
  return g_chnk_hmap[tbsp].nitems;
}
