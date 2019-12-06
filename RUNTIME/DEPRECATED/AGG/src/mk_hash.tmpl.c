#include "q_incs.h"
#include "q_rhashmap_utils.h"
#include "_mk_hash___KEY__.h"
//------------------------------------------------------
int 
mk_hash___KEY__(
    __KCTYPE__ *keys, // input  [nkeys] 
    uint32_t nkeys, // input 
    uint64_t hmap_hashkey, // input 
    uint32_t *hashes// output 
    )
{
  int status = 0;
  int chunk_size = 1024;
#pragma omp parallel for schedule(static, chunk_size)
  for ( uint32_t i = 0; i < nkeys; i++ ) {
    hashes[i] = murmurhash3(&(keys[i]), sizeof(__KCTYPE__), hmap_hashkey);
  }
  return status;
}
//------------------------------------------------------
