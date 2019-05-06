//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include "q_macros.h"
#include "_mix_UI4.h"
//STOP_INCLUDES
#include "_mix_UI8.h"
//START_FUNC_DECL
uint64_t 
mix_UI8(
    uint64_t a
    )
//STOP_FUNC_DECL
{
  uint64_t ultemp;
  ultemp = a >> 32;
  uint64_t i1 = (uint32_t)ultemp;
  ultemp = ( a << 32 ) >> 32;
  uint64_t i2 = (uint32_t)ultemp;
  i1 = mix_UI4(i1);
  i2 = mix_UI4(i2);
  uint64_t i3 = ( i1 << 32 ) | i2;
  return i3;
} 
