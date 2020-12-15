// hmap_mput: put multiple keys
#include <omp.h>
#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_get.h"
#include "hmap_put.h"
#include "fasthash.h"
#include "hmap_update.h"
#include "hmap_mput.h"


static inline void *
set_key(
    void **keys, 
    uint32_t i, 
    void *alt_keys, 
    uint32_t key_len
    )
{
  void *key_i;
  if ( keys != NULL ) { 
    key_i = keys[i];
  }
  else {
    key_i = (void *)((char *)alt_keys + (i*key_len));
  }
  return key_i;
}
//--------------------------------
static inline void *
set_val(
    void **vals, 
    uint32_t i, 
    void *alt_vals, 
    uint32_t val_len
    )
{
  void *val_i;
  if ( vals != NULL ) { 
    val_i = vals[i];
  }
  else {
    val_i = (void *)((char *)alt_vals + (i*val_len));
  }
  return val_i;
}
//--------------------------------
static inline uint16_t 
set_key_len(
    uint16_t *key_lens, 
    uint32_t i, 
    uint32_t key_len
    ) 
{
  uint16_t key_len_i;
  if ( key_lens != NULL ) { 
    key_len_i = key_lens[i];
  }
  else {
    key_len_i = key_len;
  }
  return key_len_i;
}

      //--------------------------------
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
#ifdef SEQUENTIAL
  int n1, n2 = 0;
#endif

  uint32_t *idxs   = M->idxs;
  uint32_t *hashes = M->hashes;
  uint32_t *locs   = M->locs;
  int8_t *tids     = M->tids;
  bool *exists     = M->exists;
  bool *set        = M->set;
  int nP = M->num_procs;
#ifdef SEQUENTIAL 
  nP = 1;
#else
  if ( nP <= 0 ) { 
    nP = omp_get_num_procs();
  }
#endif
  fprintf(stderr, "Using %d cores \n", nP);
  uint64_t proc_divinfo = fast_div32_init(nP);

  uint32_t lb = 0, ub;
  register uint64_t hashkey = ptr_hmap->hashkey;
  register uint64_t divinfo = ptr_hmap->divinfo;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
    uint32_t niters = ub - lb;
    int chnk_sz = 16; // so that no false sharing on write
    bool do_sequential_loop = false;
    for ( int k = 0; k < M->num_at_once; k++ ) { set[k] = false; }
#pragma omp parallel for num_threads(nP) schedule(dynamic, chnk_sz)
    for ( uint32_t j = 0; j < niters; j++ ) {
      uint32_t i = j + lb;
      //--------------------------------
      void *key_i = set_key(keys, i, alt_keys, key_len);
      uint16_t key_len_i = set_key_len(key_lens, i, key_len);
      dbg_t dbg;
      idxs[j]   = UINT_MAX; // bad value 
      // hashes[j] = murmurhash3(key_i, key_len_i, hashkey);
      hashes[j] = fasthash32(key_i, key_len_i, hashkey);
      locs[j]   = fast_rem32(hashes[j], ptr_hmap->size, divinfo);
      dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
      int lstatus = hmap_get(ptr_hmap, key_i, key_len_i, NULL, 
          exists+j, idxs+j, &dbg);
      // do not exist if bad status, this is an omp loop
      if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
      if ( !exists[j] ) { // new key=> insert in sequential loop
        tids[j] = -1; // assigned to nobody, done in sequential loop
        if ( do_sequential_loop == false ) { 
          do_sequential_loop = true;
        }
      }
      else {
        tids[j] = fast_rem32(hashes[j], nP, proc_divinfo);
#ifdef DEBUG
        uint8_t chk = hashes[j] % nP; 
        if ( chk != tids[j] ) {  
          WHEREAMI; if ( status == 0 ) { status = -1; } 
        }
#endif
      }
      set[j] = true;
    }
    cBYE(status); 
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

    // This loop does parallel updates 
#pragma omp parallel 
    {
      int tid;
#ifdef SEQUENTIAL
      tid = 1;
#else
      tid = omp_get_thread_num();
#endif
      for ( uint32_t j = 0; j < niters; j++ ) {
        if ( tids[j] != tid ) { continue; } // not mine, skip
        uint32_t i = j + lb;
        //--------------------------------
        void *val_i = set_val(vals, i, alt_vals, val_len);
        int lstatus = hmap_update(ptr_hmap, idxs[j], val_i);  
        // do not exist if bad status, this is an omp loop
        if ( lstatus != 0 ) { if ( status == 0 ) { status = lstatus; } }
#ifdef SEQUENTIAL 
        n1++; 
#endif
      }
    }
    cBYE(status); // exit if any thread had a problem
    // This loop does sequential inserts
    if ( do_sequential_loop ) {
      dbg_t dbg;
      for ( uint32_t j = 0; j < niters; j++ ) {
        if ( exists[j] ) { continue; }
        uint32_t i = j + lb;
        //--------------------------------
        void *key_i = set_key(keys, i, alt_keys, key_len);
        uint16_t key_len_i = set_key_len(key_lens, i, key_len);
        void *val_i = set_val(vals, i, alt_vals, val_len);
        //--------------------------------
        dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
        status = hmap_put(ptr_hmap, key_i, key_len_i, true, val_i, &dbg);
        cBYE(status);
#ifdef SEQUENTIAL 
        n2++; 
#endif
      }
    }
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
#ifdef SEQUENTIAL 
  if ( ( n1 + n2 ) != nkeys ) { go_BYE(-1); } 
#endif
BYE:
  return status;
}
