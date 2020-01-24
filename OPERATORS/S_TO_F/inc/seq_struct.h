#ifndef _SEQ_STRUCT_H
#define _SEQ_STRUCT_H
#include <stdint.h>
typedef struct _seq_F4_rec_type {
   float start;
   float by;
} SEQ_F4_REC_TYPE;

typedef struct _seq_F8_rec_type {
   double start;
   double by;
} SEQ_F8_REC_TYPE;

typedef struct _seq_I1_rec_type {
   int8_t start;
   int8_t by;
} SEQ_I1_REC_TYPE;

typedef struct _seq_I2_rec_type {
   int16_t start;
   int16_t by;
} SEQ_I2_REC_TYPE;

typedef struct _seq_I4_rec_type {
   int32_t start;
   int32_t by;
} SEQ_I4_REC_TYPE;

typedef struct _seq_I8_rec_type {
   int64_t start;
   int64_t by;
} SEQ_I8_REC_TYPE;
#endif
