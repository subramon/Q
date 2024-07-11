#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "q_macros.h"

extern int
F8_to_txt(
//    const double * const in,
    double * in,
    const char * const fmt,
    char *X,
    size_t nX
    );
  
