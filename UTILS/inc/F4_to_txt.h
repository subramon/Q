#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_macros.h"

extern int
F4_to_txt(
//    const float * const in,
    float * in,
    const char * const fmt,
    char *X,
    size_t nX
    );
  
