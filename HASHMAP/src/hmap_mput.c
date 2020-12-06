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
    uint16_t *key_lens, // [nkeys] 

    void *alt_keys, // either keys or alt_keys but not both
    uint32_t key_len, 

    uint32_t nkeys,

    void **vals, // [nkeys] 
    void *alt_vals, // either keys or alt_keys but not both
    uint32_t val_len
    )
{
  int status = 0;
  if ( nkeys == 0 ) { goto BYE; }

  //-------------------------------------------------
  if ( keys == NULL ) { 
    if ( key_lens != NULL ) { go_BYE(-1); } 
    if ( alt_keys == NULL ) { go_BYE(-1); } 
    if ( key_len == 0 ) { go_BYE(-1); } 
  }
  else {
    if ( key_lens == NULL ) { go_BYE(-1); } 
    if ( alt_keys != NULL ) { go_BYE(-1); } 
    if ( key_len != 0 ) { go_BYE(-1); } 
  }
  //-------------------------------------------------
  if ( vals == NULL ) { 
    if ( alt_vals == NULL ) { go_BYE(-1); } 
    if ( val_len == 0 ) { go_BYE(-1); } 
  }
  else {
    if ( alt_vals != NULL ) { go_BYE(-1); } 
    if ( val_len != 0 ) { go_BYE(-1); } 
  }
  //-------------------------------------------------

  uint32_t *idxs   = M->idxs;
  uint32_t *hashes = M->hashes;
  uint32_t *locs   = M->locs;
  int8_t *tids     = M->tids;
  bool *exists     = M->exists;
  bool *set        = M->set;
  int nP = M->num_procs;
  if ( nP <= 0 ) { 
    nP = omp_get_num_procs();
  }

  uint32_t lb = 0, ub;
  register uint64_t hashkey = ptr_hmap->hashkey;
  register uint64_t divinfo = ptr_hmap->divinfo;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
    uint32_t niters = ub - lb;
    int chnk_sz = 16; // so that no false sharing on write
    for ( int k = 0; k < M->num_at_once; k++ ) { set[k] = false; }
#pragma omp parallel for num_threads(nP) schedule(dynamic, chnk_sz)
    for ( uint32_t j = 0; j < niters; j++ ) {
      uint32_t i = j + lb;

      //--------------------------------
      void *key_i;
      if ( keys != NULL ) { 
        key_i = keys[i];
      }
      else {
        key_i = (void *)((char *)alt_keys + (i*key_len));
      }
      //--------------------------------
      uint16_t key_len_i;
      if ( key_lens != NULL ) { 
        key_len_i = key_lens[i];
      }
      else {
        key_len_i = key_len;
      }

      //--------------------------------
      dbg_t dbg;
      idxs[j]   = UINT_MAX; // bad value 
      hashes[j] = murmurhash3(key_i, key_len_i, hashkey);
      locs[j]   = fast_rem32(hashes[j], ptr_hmap->size, divinfo);
      dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
      int lstatus = hmap_get(ptr_hmap, key_i, key_len_i, NULL, 
          exists+j, idxs+j, &dbg);
      // do not exist if bad status, this is an omp loop
      if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
      if ( !exists[j] ) { // new key=> insert in sequential loop
        tids[j] = -1; // assigned to nobody, done in sequential loop
      }
      else {
        tids[j] = hashes[j] % nP; // TODO use fast_rem32()
      }
      set[j] = true;
    }
    cBYE(status); 
#define  DEBUG
#ifdef  DEBUG
    for ( uint32_t j = 0; j < niters; j++ ) { 
      if ( !set[j] ) { 
        go_BYE(-1);
      }
      if ( j > (uint32_t)M->num_at_once ) { go_BYE(-1); }
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
      int tid = omp_get_thread_num();
      for ( uint32_t j = 0; j < niters; j++ ) {
        if ( tids[j] != tid ) { continue; } // not mine, skip
        uint32_t i = j + lb;
        //--------------------------------
        void *val_i;
        if ( vals != NULL ) { 
          val_i = vals[i];
        }
        else {
          val_i = (void *)((char *)alt_vals + (i*val_len));
        }
        //--------------------------------
        int lstatus = hmap_update(ptr_hmap, idxs[j], val_i);  
        // do not exist if bad status, this is an omp loop
        if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
        // n1++; // Only for sequential testing 
      }
    }
    cBYE(status); // exit if any thread had a problem
    // this must be a sequential loop
    for ( uint32_t j = 0; j < niters; j++ ) { 
      if ( exists[j] ) { continue; }
      uint32_t i = j + lb;
      //--------------------------------
      void *key_i;
      if ( keys != NULL ) { 
        key_i = keys[i];
      }
      else {
        key_i = (void *)((char *)alt_keys + (i*key_len));
      }
      //--------------------------------
      void *val_i;
      if ( vals != NULL ) { 
        val_i = vals[i];
      }
      else {
        val_i = (void *)((char *)alt_vals + (i*val_len));
      }
      //--------------------------------
      uint16_t key_len_i;
      if ( key_lens != NULL ) { 
        key_len_i = key_lens[i];
      }
      else {
        key_len_i = key_len;
      }
      //--------------------------------
      status = hmap_put(ptr_hmap, key_i, key_len_i, true, val_i, NULL);
      cBYE(status);
      // n2++; // Only for sequential testing 
    }
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
BYE:
  return status;
}
