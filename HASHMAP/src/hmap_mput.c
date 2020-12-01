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
  uint16_t *locs   = M->locs;
  uint8_t *tids   = M->tids;
  bool *exists = M->exists;
  int num_procs = M->num_procs;
  if ( num_procs <= 0 ) { 
    num_procs = omp_get_num_procs();
  }

  uint32_t lb = 0, ub;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + (iter*M->num_at_once);
    if ( ub > nkeys ) { ub = nkeys; }
#pragma omp parallel for num_threads(num_procs)
    for ( uint32_t i = lb; i < ub; i++ ) { 
      int tid = omp_get_thread_num();
      status = hmap_get(ptr_hmap, keys[i], lens[i], NULL, 
          exists+i, idxs+i, NULL); 
      hashes[i] = set_hash(keys[i], lens[i], ptr_hmap, NULL);
      locs[i] = set_probe_loc(hashes[i], ptr_hmap, NULL);
      tids[i] = hashes[i] % num_procs; // TODO use fast_rem32()
      if ( !exists[i] ) { continue; }
      if ( tids[i] != tid ) { continue; }
      // status = hmap_update(ptr_hmap, idxs[i], vals[i]); 
    }
    for ( uint32_t i = lb; i < ub; i++ ) { 
      if ( exists[i] ) { continue; }
      status = hmap_put(ptr_hmap, keys[i], lens[i], true, vals[i], NULL);
      cBYE(status);
    }
  }
BYE:
  return status;
}
