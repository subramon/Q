#include "q_incs.h"
#include "qtypes.h"
#include "qjit_consts.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_cnt.h"

extern vctr_rs_hmap_t g_vctr_hmap[Q_MAX_NUM_TABLESPACES];

uint32_t
vctr_cnt(
    uint32_t tbsp
    )
{
  return g_vctr_hmap[tbsp].nitems;
}
