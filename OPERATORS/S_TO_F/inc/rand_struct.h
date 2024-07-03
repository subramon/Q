#ifndef _RAND_STRUCT_H
#define _RAND_STRUCT_H
//START_FOR_CDEF
typedef struct _rand_F4_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  float lb;
  float ub;
} RAND_F4_REC_TYPE;

typedef struct _rand_F8_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  double lb;
  double ub;
} RAND_F8_REC_TYPE;

typedef struct _rand_I1_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  int8_t lb;
  int8_t ub;
} RAND_I1_REC_TYPE;

typedef struct _rand_I2_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  int16_t lb;
  int16_t ub;
} RAND_I2_REC_TYPE;

typedef struct _rand_I4_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  int32_t lb;
  int32_t ub;
} RAND_I4_REC_TYPE;

typedef struct _rand_I8_rec_type {
  uint64_t seed;
  uint32_t usage_counter; // incremented from chunk to chunk
  int64_t lb;
  int64_t ub;
} RAND_I8_REC_TYPE;
//STOP_FOR_CDEF
#endif
