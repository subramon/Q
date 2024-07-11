#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_macros.h"

extern int
I2_to_txt(
//    const int16_t * const in,
    int16_t * in,
    const char * const fmt,
    char *X,
    size_t nX
    );
  
