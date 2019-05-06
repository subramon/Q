
#include "q_incs.h"
#include <string.h>
#define BSEARCH_LOWEST 1 
#define BSEARCH_HIGHEST 2
#define BSEARCH_DONTCARE 3
  extern int
    bin_search_I4(  
          const int32_t *X,
          uint64_t nX,
          int32_t key,
          const char * const str_direction,
          int64_t *ptr_pos
        ) 
    ;

  
