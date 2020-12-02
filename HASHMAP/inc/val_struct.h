#ifndef __VAL_STRUCT_H
#define __VAL_STRUCT_H

#include <stdint.h>
#ifdef CASEA
typedef uint64_t val_t;
#endif
#ifdef CASEB
typedef struct _val_t {
  char *strval;
} val_t;
#endif
#endif
