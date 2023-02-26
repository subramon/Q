// START: RAMESH
#include "q_incs.h"
#include "q_macros.h"

#include "mod_mem_used.h"

extern int g_mem_lock; // used for locking

extern uint64_t g_mem_used;
extern uint64_t g_mem_allowed;

extern uint64_t g_dsk_used;
extern uint64_t g_dsk_allowed;

//-------------------------------------------------------
uint64_t 
get_mem_used(
    void
    )
{
  uint64_t l_mem_used;
  __atomic_load(&g_mem_used, &l_mem_used, 0);
  return l_mem_used;
}
//-------------------------------------------------------
uint64_t 
get_mem_allowed(
    void
    )
{
  uint64_t l_mem_allowed;
  __atomic_load(&g_mem_allowed, &l_mem_allowed, 0);
  return l_mem_allowed;
}
//-------------------------------------------------------
uint64_t 
get_dsk_used(
    void
    )
{
  uint64_t l_dsk_used;
  __atomic_load(&g_dsk_used, &l_dsk_used, 0);
  return l_dsk_used;
}
//-------------------------------------------------------
uint64_t 
get_dsk_allowed(
    void
    )
{
  uint64_t l_dsk_allowed;
  __atomic_load(&g_dsk_allowed, &l_dsk_allowed, 0);
  return l_dsk_allowed;
}
//-------------------------------------------------------
int
incr_mem_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > (1024*1048576 ) ) { go_BYE(-1); } // sanity test 
  status = lock_mem(); cBYE(status);
  if ( (x + g_mem_used) > g_mem_allowed ) { 
    WHEREAMI; status = -1; 
  }
  else {
    __atomic_add_fetch(&g_mem_used, x, 0); 
  }
  status = unlock_mem(); cBYE(status);
BYE:
  return status;
}
//-------------------------------------------------------
int
decr_mem_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > (1024*1048576 ) ) { go_BYE(-1); } // sanity test 
  status = lock_mem(); cBYE(status);
  if ( x > g_mem_used ) { 
    WHEREAMI; status = -1; 
  }
  else {
    __atomic_sub_fetch(&g_mem_used, x, 0); 
  }
  status = unlock_mem(); cBYE(status);
BYE:
  return status;
}
//-------------------------------------------------------
int
incr_dsk_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > (1024*1048576 ) ) { go_BYE(-1); } // sanity test 
  status = lock_mem(); cBYE(status);
  if ( (x + g_dsk_used) > g_dsk_allowed ) { 
    WHEREAMI; status = -1; 
  }
  else {
    __atomic_add_fetch(&g_dsk_used, x, 0); 
  }
  status = unlock_mem(); cBYE(status);
BYE:
  return status;
}
//-------------------------------------------------------
int
decr_dsk_used(
    uint64_t x
   )
{
  int status = 0;
  if ( x == 0 ) { go_BYE(-1); }
  if ( x > (1024*1048576 ) ) { go_BYE(-1); } // sanity test 
  status = lock_mem(); cBYE(status);
  if ( x > g_dsk_used ) { 
    WHEREAMI; status = -1; 
  }
  else {
    __atomic_sub_fetch(&g_dsk_used, x, 0); 
  }
  status = unlock_mem(); cBYE(status);
BYE:
  return status;
}
//-------------------------------------------------------
int 
lock_mem(
    void
    )
{
  int status = 0;

  for ( ; ; ) { 
    int l_expected = 0;
    int l_desired  = 1;
    bool rslt = __atomic_compare_exchange(
        &g_mem_lock, &l_expected, &l_desired, false, 
        __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
    if ( rslt ) { break; } 
  }
BYE:
  return status;
}

int 
unlock_mem(
    void
    )
{
  int status = 0;
  int l_expected = 1;
  int l_desired  = 0;
  bool rslt = __atomic_compare_exchange(
        &g_mem_lock, &l_expected, &l_desired, false, 
        __ATOMIC_SEQ_CST, __ATOMIC_SEQ_CST);
  if ( !rslt ) { go_BYE(-1); } 
BYE:
  return status;
}

