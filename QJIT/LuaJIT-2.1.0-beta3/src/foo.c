#include <pthread.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
extern int g_foobar;
extern int g_halt;
extern int g_L_status;
extern lua_State *L; 

int
foo(
   int x
   )
{
  printf("hello world %d \n", g_foobar);
  g_foobar = x;
  return 0;
}

void *
bar_fn(
    void *arg
    )
{
  int status = 0;
  for ( int i = 0; ; i++ ) {
    int l_halt;
    __atomic_add_fetch(&g_foobar, 1, 0);
    sleep(2);  // give other threads a chance to acquire lock 
    // Attempt to acquire lock 
    for ( int j = 0; ; j++ ) {
      int expected = 0; int desired = 2; 
      bool rslt = __atomic_compare_exchange(
          &g_L_status, &expected, &desired, false, 0, 0);
      if ( rslt ) { 
        printf("Slave has control \n"); 
        break; 
      }
      // printf("Slave Sleeping %d:%d \n", i, j); 
      sleep(1); 
      // see if you need to quit  TODO Not sure this is needed here
      __atomic_load(&g_halt, &l_halt, 0);
      if ( l_halt == 1 ) { 
        printf("Slave halting\n"); 
        break; 
      }
    }
    if ( l_halt == 1 ) { break; }
    // do some work 
    char line[64]; memset(line, 0, 64);
    fprintf(stdout, "Slave: Please enter a command\n");
    char *cptr = fgets(line, 64-1, stdin);
    if ( cptr != NULL ) { 
      status = luaL_dostring(L, line);
      if ( status != 0 ) { 
        fprintf(stderr, "Error executing [%s]\n", line);
      }
      else {
        fprintf(stdout, "Success with command [%s] \n", line);
      }
    }

    { // release lock 
      int expected = 2; int desired = 0;
      bool rslt = __atomic_compare_exchange(
          &g_L_status, &expected, &desired, false, 0, 0);
      if ( !rslt ) { 
        printf("Slave: g_L_status = %d  \n", g_L_status);
        printf("Slave: desired  = %d  \n", desired);
        printf("Slave: expected  = %d  \n", expected);
        printf("Slave: %d Catastrophic error\n", __LINE__); exit(1);
      }
    }
    // see if you need to quit 
    __atomic_load(&g_halt, &l_halt, 0);
    if ( l_halt == 1 ) { 
      printf("Slave halting\n"); 
      break; 
    }
    printf("Slave done: i = %d \n", i);
  }
  pthread_exit(NULL);
}
