#ifndef _SEQ_STRUCT_H
#define _SEQ_STRUCT_H
#include <stdint.h>
// START_FOR_CDEF
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

typedef struct _seq_UI1_rec_type {
   uint8_t start;
   uint8_t by;
} SEQ_UI1_REC_TYPE;

typedef struct _seq_UI2_rec_type {
   uint16_t start;
   uint16_t by;
} SEQ_UI2_REC_TYPE;

typedef struct _seq_UI4_rec_type {
   uint32_t start;
   uint32_t by;
} SEQ_UI4_REC_TYPE;

typedef struct _seq_UI8_rec_type {
   uint64_t start;
   uint64_t by;
} SEQ_UI8_REC_TYPE;
// STOP_FOR_CDEF
#endif
