#include "hmap_struct_isp.h"
// #include "hmap_aux.h"
// #include "hmap_get.h"
// #include "fasthash.h"


static inline void *
set_key(
    void **keys, 
    uint32 i, 
    void *alt_keys, 
    uint32 key_len
    )
{
  void *key_i;
  if ( keys != NULL ) { 
    key_i = keys[i];
  }
  else {
    key_i = (void *)((int8 *)alt_keys + (i*key_len));
  }
  return key_i;
}
//--------------------------------
static inline void *
set_val(
    void **vals, 
    uint32 i, 
    void *alt_vals, 
    uint32 val_len
    )
{
  void *val_i;
  if ( vals != NULL ) { 
    val_i = vals[i];
  }
  else {
    val_i = (void *)((int8 *)alt_vals + (i*val_len));
  }
  return val_i;
}
//--------------------------------
static inline uint16 
set_key_len(
    uint16 *key_lens, 
    uint32 i, 
    uint32 key_len
    ) 
{
  uint16 key_len_i;
  if ( key_lens != NULL ) { 
    key_len_i = key_lens[i];
  }
  else {
    key_len_i = key_len;
  }
  return key_len_i;
}

      //--------------------------------
export void
hmap_mput(
    uniform hmap_t * uniform ptr_hmap, 
     uniform hmap_multi_t * uniform M,

     uniform void ** uniform keys,  // [nkeys] 
    uint16 key_lens[], // [nkeys] 

    void *alt_keys, // either keys or alt_keys but not both
    uint32 key_len, 

    uint32 nkeys,

    void **vals, // [nkeys] 
    void *alt_vals, // either keys or alt_keys but not both
    uint32 val_len
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

  uint32 *idxs    = M->idxs;
  uint32 *hashes  = M->hashes;
  uint32 *locs    = M->locs;
  int8_t *tids      = M->tids;
  bool *exists      = M->exists;
  uint16 *m_key_len = M->m_key_len;
  void **m_key      = M->m_key;
  int nP = M->num_procs;
#ifdef SEQUENTIAL 
  nP = 1;
#else
  if ( nP <= 0 ) { 
    nP = omp_get_num_procs();
  }
#endif
  // fprintf(stderr, "Using %d cores \n", nP);
  uint64 proc_divinfo = fast_div32_init(nP);

  uint32 lb = 0, ub;
  register uint64 hashkey = ptr_hmap->hashkey;
  register uint64 divinfo = ptr_hmap->divinfo;
  for ( int iter = 0; ; iter++ ) { 
    ub = lb + M->num_at_once;
    if ( ub > nkeys ) { ub = nkeys; }
    uint32 niters = ub - lb;
    int num_per_core = 16; // so that no false sharing on write
    bool do_sequential_loop = false;
#pragma omp parallel for num_threads(nP) schedule(static, 1)
    for ( uint32 j = 0; j < niters; j += num_per_core ) {
      uint32 i = j + lb;
      //--------------------------------
      m_key[j] = set_key(keys, i, alt_keys, key_len);
      m_key_len[j] = set_key_len(key_lens, i, key_len);
      dbg_t dbg;
      idxs[j]   = UINT_MAX; // bad value 
      // hashes[j] = murmurhash3(m_key[j], m_key_len[j], hashkey);
      // hashes[j] = fasthash32(m_key[j], m_key_len[j], hashkey);
      locs[j]   = fast_rem32(hashes[j], ptr_hmap->size, divinfo);
      dbg.hash  = hashes[j]; dbg.probe_loc = locs[j];
      int lstatus = hmap_get(ptr_hmap, m_key[j], m_key_len[j], NULL, 
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
      }
    }
    cBYE(status); 
    if ( ub >= nkeys ) { break; }
    lb += M->num_at_once;
  }
BYE:
  return status;
}
