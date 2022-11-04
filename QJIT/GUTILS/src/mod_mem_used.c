// START: RAMESH
#include "q_incs.h"
#include "q_macros.h"

#include "mod_mem_used.h"

// TODO P2 Need to protect atomic accesses better 

extern uint64_t g_mem_used;
extern uint64_t g_mem_allowed;

extern uint64_t g_dsk_used;
extern uint64_t g_dsk_allowed;

uint64_t 
get_mem_used(
    void
    )
{
  return g_mem_used;
}
//-------------------------------------------------------
uint64_t 
get_mem_allowed(
    void
    )
{
  return g_mem_allowed;
}
//-------------------------------------------------------
uint64_t 
get_dsk_used(
    void
    )
{
  return g_dsk_used;
}
//-------------------------------------------------------
uint64_t 
get_dsk_allowed(
    void
    )
{
  return g_dsk_allowed;
}
//-------------------------------------------------------
int
incr_mem_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( (x + g_mem_used) > g_mem_allowed ) { go_BYE(-1); }
  __atomic_add_fetch(&g_mem_used, x, 0); 
BYE:
  return status;
}

int
decr_mem_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > g_mem_used ) { go_BYE(-1); }
  __atomic_sub_fetch(&g_mem_used, x, 0); 
BYE:
  return status;
}
// TODO P3 Note that the checks made before the increment/decrement
// are not that good. Ideally they should happen atomically with the
// increment/decrement. But, good enough for now
int
incr_dsk_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( (x + g_dsk_used) > g_dsk_allowed ) { go_BYE(-1); }
  __atomic_add_fetch(&g_dsk_used, x, 0); 
BYE:
  return status;
}

int
decr_dsk_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > g_dsk_used ) { go_BYE(-1); }
  __atomic_sub_fetch(&g_dsk_used, x, 0); 
BYE:
  return status;
}
