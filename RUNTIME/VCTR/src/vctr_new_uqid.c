#include "q_incs.h"
#include "vctr_new_uqid.h"

extern uint32_t g_vctr_uqid;

uint32_t
vctr_new_uqid(
    void
    )
{
  return ++g_vctr_uqid;
}

uint32_t
vctr_uqid(
    void
    )
{
  return g_vctr_uqid;
}
