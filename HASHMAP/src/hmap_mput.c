// hmap_mput: put multiple keys
#include <omp.h>
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_get.h"
#include "hmap_put.h"
#include "hmap_mput.h"
int
hmap_mput(
    hmap_t *ptr_hmap, 
    hmap_multi_t *M,
    void **keys,  // [nkeys] 
    uint32_t nkeys,
    uint16_t *lens, // [nkeys] 
    val_t *vals // [nkeys] 
    )
{
  int status = 0;
  if ( nkeys == 0 ) { goto BYE; }

  uint32_t *idxs   = M->idxs;
  uint32_t *hashes = M->hashes;
  uint32_t *locs   = M->locs;
  uint8_t *tids   = M->tids;
  bool *exists = M->exists;
  int num_procs = M->num_procs;
  if ( num_procs <= 0 ) { 
    num_procs = omp_get_num_procs();
  }

  uint32_t lb = 0, ub;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
// #pragma omp parallel for num_threads(num_procs)
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t j = i - lb; // offset for M 
      int tid = omp_get_thread_num();
      status = hmap_get(ptr_hmap, keys[i], lens[i], NULL, 
          exists+j, idxs+j, NULL); 
      hashes[j] = set_hash(keys[i], lens[i], ptr_hmap, NULL);
      locs[j] = set_probe_loc(hashes[j], ptr_hmap, NULL);
      tids[j] = hashes[j] % num_procs; // TODO use fast_rem32()
      if ( !exists[j] ) { continue; }
      if ( tids[j] != tid ) { continue; }
      // status = hmap_update(ptr_hmap, idxs[i], vals[i]); 
    }
    // this must be a sequential loop
    for ( uint32_t i = lb; i < ub; i++ ) { 
      uint32_t j = i - lb; // offset for M 
      if ( exists[j] ) { continue; }
      status = hmap_put(ptr_hmap, keys[i], lens[i], true, vals[i], NULL);
      cBYE(status);
    }
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
BYE:
  return status;
}
