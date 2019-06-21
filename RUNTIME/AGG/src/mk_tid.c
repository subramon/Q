#include "q_incs.h"
#include "mk_tid.h"
#include "fastdiv.h"
//------------------------------------------------------
int 
mk_tid(
    uint32_t *hashes, // input  [nkeys] 
    uint32_t nkeys, // input 
    uint32_t nT, // input , number of threads
    uint8_t *tids // output [nkeys] 
    )
{
  int status = 0;
  int chunk_size = 1024;
  uint64_t divinfo = fast_div32_init(nT);
#pragma omp parallel for schedule(static, chunk_size)
  for ( uint32_t i = 0; i < nkeys; i++ ) {
    tids[i] = fast_rem32(hashes[i], nT, divinfo);
  }
  return status;
}
//------------------------------------------------------
