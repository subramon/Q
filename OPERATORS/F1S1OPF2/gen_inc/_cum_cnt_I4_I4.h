
#include "q_incs.h"

typedef struct _cum_cnt_I4_I4_args {
  int32_t prev_val;
  int32_t prev_cnt;
  int32_t max_val;
  int32_t max_cnt;
  } CUM_CNT_I4_I4_ARGS;
  
extern int
cum_cnt_I4_I4(  
      const int32_t * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_I4_I4_ARGS *ptr_args,
      int32_t * restrict out,
      void *dummy2
      ) 
;

   
