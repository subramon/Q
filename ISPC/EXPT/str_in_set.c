#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "fasthash.h"
#include "strcmp_ht_struct.h"
#include "str_in_set.h"
#include "str_in_set_ispc.h"
bool 
str_in_set(
    const char * const str,
    const strcmp_ht_t *const X
    )
{
  bool rslt;
  uint64_t hash = fasthash64(str, strlen(str), X->seed);
#undef SEQUENTIAL
#ifdef SEQUENTIAL
  for ( int i = 0; i < X->nvals; i++ ) { 
    if ( X->vals[i] == hash ) { return true; }
  }
  return false;
#else
  str_in_set_ispc(hash, X->vals, &rslt);
  return rslt;
#endif
}
