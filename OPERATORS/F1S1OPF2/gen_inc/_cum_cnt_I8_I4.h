
#include "q_incs.h"

typedef struct _cum_cnt_I8_I4_args {
  int64_t prev_val;
  int32_t prev_cnt;
  int64_t max_val;
  int32_t max_cnt;
  } CUM_CNT_I8_I4_ARGS;
  
extern int
cum_cnt_I8_I4(  
      const int64_t * restrict in,  
      void *dummy1,
      uint64_t nR,
      CUM_CNT_I8_I4_ARGS *ptr_args,
      int32_t * restrict out,
      void *dummy2
      ) 
;

   
