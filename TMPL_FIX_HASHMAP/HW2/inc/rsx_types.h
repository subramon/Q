#ifndef __HW2_RSX_TYPES_H
#define __HW2_RSX_TYPES_H
#include <stdint.h>
typedef struct _rs_hmap_key_t { 
  double  f8;
  int16_t i2;
  float f4;
  int i4;
} rs_hmap_key_t;
typedef struct _rs_hmap_val_t {
  int64_t i8;
  char str[16];
  int8_t i1;
} rs_hmap_val_t;
#endif //  __HW2_RSX_TYPES_H
