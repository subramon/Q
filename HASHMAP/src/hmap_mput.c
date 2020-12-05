// hmap_mput: put multiple keys
#include <omp.h>
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_get.h"
#include "hmap_put.h"
#include "hmap_mput.h"
#include "hmap_update.h"
int
hmap_mput(
    hmap_t *ptr_hmap, 
    hmap_multi_t *M,
    void **keys,  // [nkeys] 
    uint32_t nkeys,
    uint16_t *lens, // [nkeys] 
    void **vals // [nkeys] 
    )
{
  int status = 0;
  if ( nkeys == 0 ) { goto BYE; }

  uint32_t *idxs   = M->idxs;
  uint32_t *hashes = M->hashes;
  uint32_t *locs   = M->locs;
  int8_t *tids   = M->tids;
  bool *exists = M->exists;
  int num_procs = M->num_procs;
  if ( num_procs <= 0 ) { 
    num_procs = omp_get_num_procs();
  }
  num_procs = 1; // TODO DELETE 

  uint32_t lb = 0, ub;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
    uint32_t j = 0; // offset for M 
// TODO #pragma omp parallel for num_threads(num_procs)
    for ( uint32_t i = lb; i < ub; i++, j++ ) { 
      dbg_t dbg;
      int lstatus = 0;
      idxs[j]   = UINT_MAX; // bad value 
      hashes[j] = murmurhash3(keys[i], lens[i], ptr_hmap->hashkey);
      locs[j]   = fast_rem32(hashes[j], ptr_hmap->size, ptr_hmap->divinfo);
      dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
      lstatus = hmap_get(ptr_hmap, keys[i], lens[i], NULL, 
          exists+j, idxs+j, &dbg);
      // do not exist if bad status, this is an omp loop
      if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
      if ( !exists[j] ) { // new key=> insert in sequential loop
        tids[j] = -1; // assigned to nobody, done in sequential loop
      }
      else {
        tids[j] = hashes[j] % num_procs; // TODO use fast_rem32()
      }
    }
    cBYE(status); 
    //-----------------------------------

    int n1, n2 = 0;
    j = 0; // offset for M 
// TODO #pragma omp parallel 
    for ( int tid = 0; tid < num_procs; tid++ ) { 
      for ( uint32_t i = lb; i < ub; i++, j++ ) { 
        if ( tids[j] != tid ) { continue; } // not mine, skip
        int lstatus = hmap_update(ptr_hmap, idxs[j], vals[i]);  
        // do not exist if bad status, this is an omp loop
        if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
        n1++;
      }
    }
    cBYE(status); // exit if any thread had a problem
    // this must be a sequential loop
    j = 0; // offset for M 
    for ( uint32_t i = lb; i < ub; i++, j++ ) { 
      if ( exists[j] ) { continue; }
      status = hmap_put(ptr_hmap, keys[i], lens[i], true, vals[i], NULL);
      cBYE(status);
      n2++;
    }
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
BYE:
  return status;
}
