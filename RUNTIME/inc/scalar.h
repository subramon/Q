#ifndef __SCALAR_H
#define __SCALAR_H

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
  char field_type[4]; // MAX_LEN_FIELD_TYPE TODO Fix hard coding
  uint32_t field_size;
  CDATA_TYPE cdata;
} SCLR_REC_TYPE;
#endif
