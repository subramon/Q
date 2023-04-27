#include "q_incs.h"
#include "lua_state.h"

extern int g_L_status;

static int
chk_owner(
    int owner
    )
{
  int status = 0;
  if ( ( owner == 1 ) // main Lua thread 
      || ( owner == 2 ) ) {  // webserver thread
    // all is well
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
//-------------------------------------------------
int
acquire_lua_state(
    int new_owner
    )
{
  int status = 0;
  status = chk_owner(new_owner); cBYE(status);
  // acquire Lua state
  for ( ; ; ) { 
    int l_expected = 0; int l_desired = new_owner;
    bool rslt = __atomic_compare_exchange(
        &g_L_status, &l_expected, &l_desired, false, 0, 0);
    if ( rslt ) { break; }
    // take a short nap for 10 ms
    struct timespec tmspec = {.tv_sec = 0, .tv_nsec = 10 * 1000000};
    nanosleep(&tmspec, NULL);
  }
BYE:
  return status;
}
int
release_lua_state(
    int old_owner
    )
{
  int status = 0;
  status = chk_owner(old_owner); cBYE(status);
  // release state 
  int l_expected = old_owner; int l_desired = 0;
  bool rslt = __atomic_compare_exchange(
      &g_L_status, &l_expected, &l_desired, false, 0, 0);
  if ( !rslt ) { go_BYE(-1); }
BYE:
  return status;
}
