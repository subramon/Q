#ifndef __SCALAR_H
#define __SCALAR_H
//START_FOR_CDEF
#include "cmem_constants.h"
typedef union _cdata_type {
  bool    valB1;
  int8_t  valI1;
  int16_t valI2;
  int32_t valI4;
  int64_t valI8;
  float   valF4;
  double  valF8;
} CDATA_TYPE;

typedef struct _sclr_rec_type {
  char field_type[Q_MAX_LEN_QTYPE_NAME+1];
  uint32_t field_width;
  CDATA_TYPE cdata;
} SCLR_REC_TYPE;
//STOP_FOR_CDEF
#endif
