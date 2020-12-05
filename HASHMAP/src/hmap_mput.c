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
  int nP = M->num_procs;
  if ( nP <= 0 ) { 
    nP = omp_get_num_procs();
  }

  uint32_t lb = 0, ub;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
    uint32_t j = 0; // offset for M 
    int chnk_sz = 16; // so that no false sharing on write
#pragma omp parallel for num_threads(nP) schedule(static, chnk_sz)
    for ( uint32_t i = lb; i < ub; i++ ) {
      dbg_t dbg;
      idxs[j]   = UINT_MAX; // bad value 
      hashes[j] = murmurhash3(keys[i], lens[i], ptr_hmap->hashkey);
      locs[j]   = fast_rem32(hashes[j], ptr_hmap->size, ptr_hmap->divinfo);
      dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
      int lstatus = hmap_get(ptr_hmap, keys[i], lens[i], NULL, 
          exists+j, idxs+j, &dbg);
      // do not exist if bad status, this is an omp loop
      if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
      if ( !exists[j] ) { // new key=> insert in sequential loop
        tids[j] = -1; // assigned to nobody, done in sequential loop
      }
      else {
        tids[j] = hashes[j] % nP; // TODO use fast_rem32()
      }
      j++;
    }
    cBYE(status); 
#define  DEBUG
#ifdef  DEBUG
    for ( j = 0; j < ub -lb; j++ ) { 
      if ( j > M->num_at_once ) { go_BYE(-1); }
      if ( exists[j] ) { 
        if ( idxs[j] >= ptr_hmap->size ) { go_BYE(-1); }
      }
      else {
        if ( idxs[j] != UINT_MAX ) { 
          go_BYE(-1); }
      }
    }
#endif
    //-----------------------------------

    // int n1, n2 = 0;// Only for sequential testing 
#pragma omp parallel 
    {
      uint32_t jj = 0; // offset for M 
      int tid = omp_get_thread_num();
      for ( uint32_t i = lb; i < ub; i++, jj++ ) { 
        if ( tids[jj] != tid ) { continue; } // not mine, skip
        int lstatus = hmap_update(ptr_hmap, idxs[jj], vals[i]);  
        // do not exist if bad status, this is an omp loop
        if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
        // n1++; // Only for sequential testing 
      }
    }
    cBYE(status); // exit if any thread had a problem
    // this must be a sequential loop
    j = 0; // offset for M 
    for ( uint32_t i = lb; i < ub; i++, j++ ) { 
      if ( exists[j] ) { continue; }
      status = hmap_put(ptr_hmap, keys[i], lens[i], true, vals[i], NULL);
      cBYE(status);
      // n2++; // Only for sequential testing 
    }
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
BYE:
  return status;
}
