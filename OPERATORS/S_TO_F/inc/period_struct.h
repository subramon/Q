#ifndef _PERIOD_STRUCT_H
#define _PERIOD_STRUCT_H
//START_FOR_CDEF
typedef struct _period_F4_rec_type {
   float start;
   float by;
   int period;
} PERIOD_F4_REC_TYPE;

typedef struct _period_F8_rec_type {
   double start;
   double by;
   int period;
} PERIOD_F8_REC_TYPE;

typedef struct _period_I1_rec_type {
   int8_t start;
   int8_t by;
   int period;
} PERIOD_I1_REC_TYPE;

typedef struct _period_I2_rec_type {
   int16_t start;
   int16_t by;
   int period;
} PERIOD_I2_REC_TYPE;

typedef struct _period_I4_rec_type {
   int32_t start;
   int32_t by;
   int period;
} PERIOD_I4_REC_TYPE;

typedef struct _period_I8_rec_type {
   int64_t start;
   int64_t by;
   int period;
} PERIOD_I8_REC_TYPE;
//STOP_FOR_CDEF
#endif
