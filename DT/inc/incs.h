#ifndef __Q_INCS
#define __Q_INCS
#include <alloca.h>
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
// TODO P4 do not think this is needed:#include <malloc.h>
#include <math.h>
#include <memory.h>
#include <omp.h>
#include <string.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#include "macros.h"
#include "constants.h"

typedef struct _four_nums_t {  
  uint32_t n_T_L;
  uint32_t n_H_L;
  uint32_t n_T_R;
  uint32_t n_H_R;
} four_nums_t; 
typedef struct _metrics_t {  
  uint32_t yval;
  uint32_t yidx;
  uint32_t cnt[2];
  double metric;
} metrics_t; 

#endif
