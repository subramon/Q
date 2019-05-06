#ifndef __Q_INCS
#define __Q_INCS
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <float.h>
#include <inttypes.h>
#include <limits.h>
#include <math.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include "q_constants.h"
#include "q_macros.h"

// for load_csv
typedef enum _qtype_type { undef_qtype, I1, I2, I4, I8, F4, F8, B1, SC } qtype_type;
#endif
