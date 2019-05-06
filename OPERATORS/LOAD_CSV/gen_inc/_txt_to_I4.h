#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
#include "q_macros.h"
#include "_is_valid_chars_for_num.h"

extern int
txt_to_I4(
      const char * const X,
      int32_t *ptr_out
      );

