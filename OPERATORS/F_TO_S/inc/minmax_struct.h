#ifndef _MINMAX_STRUCT_H
#define _MINMAX_STRUCT_H
//START_FOR_CDEF
typedef struct _minmax_F4_args {
  float  val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_F4_ARGS;
  
typedef struct _minmax_F8_args {
  double val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_F8_ARGS;
  
typedef struct _min_BL_args {
  int8_t val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_BL_ARGS;
  
typedef struct _min_I1_args {
  int8_t val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_I1_ARGS;
  
typedef struct _min_I2_args {
  int16_t  val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_I2_ARGS;
  
typedef struct _min_I4_args {
  int32_t  val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_I4_ARGS;
  
typedef struct _min_I8_args {
  int64_t  val;
  int64_t idx; // where min (or max) was found 
  uint64_t num; // number of values consumed so far
  uint64_t num_seen; // number of values seen so far
} MINMAX_I8_ARGS;
//STOP_FOR_CDEF
#endif
