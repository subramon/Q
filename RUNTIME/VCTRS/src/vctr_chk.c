#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_is.h"
#include "vctr_chk.h"

extern vctr_rs_hmap_t g_vctr_hmap;

// TODO 
int
vctr_chk(
    uint32_t uqid
    )
{
  int status = 0;
  if ( uqid == 0 ) { go_BYE(-1); }
BYE:
  return status;
}
