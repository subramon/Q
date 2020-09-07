#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_macros.h"

extern int
I4_to_txt(
//    const int32_t * const in,
    int32_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );
  
