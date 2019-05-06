//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include "q_macros.h"
//STOP_INCLUDES
#include "_mix_UI4.h"
//START_FUNC_DECL
uint32_t
mix_UI4( 
    uint32_t a
    )
//STOP_FUNC_DECL
{
  a = (a+0x7ed55d16) + (a<<12);
  a = (a^0xc761c23c) ^ (a>>19);
  a = (a+0x165667b1) + (a<<5);
  a = (a+0xd3a2646c) ^ (a<<9);
  a = (a+0xfd7046c5) + (a<<3);
  a = (a^0xb55a4f09) ^ (a>>16);
  return a;
}
