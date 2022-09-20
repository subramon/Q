#ifndef _SUM_STRUCT_H
#define _SUM_STRUCT_H
#include <stdint.h>
//START_FOR_CDEF
typedef struct _sum_F_args {
  double   val;
  uint64_t num; // number of values consumed so far
  uint64_t num_good; // number of non-null values seen so far
} SUM_F_ARGS;
  
typedef struct _sum_I_args {
  int64_t  val;
  uint64_t num; // number of values consumed so far
  uint64_t num_good; // number of non-null values seen so far
} SUM_I_ARGS;
//STOP_FOR_CDEF
  
#endif
