#include "q_incs.h"
#include "qtypes.h"
#include "chnk_rs_hmap_struct.h"
#include "chnk_rs_hmap_custom_chk.h"

typedef struct _kv_t {
  uint32_t vctr_uqid;
  uint32_t chnk_idx;
  uint32_t num_elements;
  qtype_t qtype; // backward reference for debugging 
  uint32_t size; // we do not expect a chunk to exceed 4G, a vector might
} kv_t;

static int
sortcompare_kv(
    const void *in1,
    const void *in2
    )
{
  const kv_t  *u1 = (const kv_t *)in1;
  const kv_t  *u2 = (const kv_t *)in2;
  if ( u1->vctr_uqid < u2->vctr_uqid ) {
    return -1;
  } 
  else if ( u1->vctr_uqid < u2->vctr_uqid ) {
    return 1;
  }
  else {
    if ( u1->chnk_idx < u2->chnk_idx ) {
      return -1;
    } 
    else {
      return 1;
    }
  }
}
/*
 * L1 refers to RAM
 * L2 refers to local machine file system
 * L3 refers to off machine storage. Currently, this is assumed to be a file but
 * it could be an S3 bucket or something else.
 * */
//START_FUNC_DECL
int
chnk_rs_hmap_custom_chk(
    const chnk_rs_hmap_t * const H
    )
//STOP_FUNC_DECL
{
  int status = 0;
  // We will accumulate key/values in kv
  kv_t *kv = NULL; uint32_t kv_idx = 0;

  if ( H == NULL ) { go_BYE(-1); }

  const chnk_rs_hmap_bkt_t * const bkts = H->bkts;
  if ( bkts == NULL ) { go_BYE(-1); }

  const bool * const bkt_full = H->bkt_full;
  if ( bkt_full == NULL ) { go_BYE(-1); }

  uint32_t sz = H->size;
  if ( sz == 0 ) { go_BYE(-1); }

  uint32_t n = H->nitems;
  if ( n == 0 ) { return status; } // early exit

  chnk_rs_hmap_val_t zero_val; 
  uint32_t valsz = sizeof(chnk_rs_hmap_val_t);
  memset(&zero_val, 0, valsz);

  chnk_rs_hmap_key_t zero_key; 
  uint32_t keysz = sizeof(chnk_rs_hmap_key_t);
  memset(&zero_key, 0, keysz);

  kv = malloc(n * sizeof(kv_t));
  memset(kv, 0, n * sizeof(kv_t));

  for ( uint32_t i = 0; i < sz; i++ ) { 
    if ( bkt_full[i] ) { 
      chnk_rs_hmap_val_t val; 
      memset(&zero_val, 0, sizeof(chnk_rs_hmap_val_t));
      val = bkts[i].val;

      chnk_rs_hmap_key_t key; 
      memset(&zero_key, 0, sizeof(chnk_rs_hmap_key_t));
      key = bkts[i].key;

      if ( val.num_elements > val.size ) { go_BYE(-1); }
      if ( val.num_elements == 0       ) { go_BYE(-1); }
      if ( val.size         == 0       ) { go_BYE(-1); }
      // If not in l2, must be in l1
      if ( val.l2_exists  == false ) { 
        if ( val.l1_mem == NULL ) { go_BYE(-1); }
      }

      if ( key.vctr_uqid == 0 ) { go_BYE(-1); }

      if ( val.num_readers > 0 ) { 
        if ( val.num_writers > 0 ) { 
          go_BYE(-1);
        }
      }

      if ( val.num_writers > 0 ) { 
        if ( val.num_readers > 0 ) { 
          go_BYE(-1);
        }
      }
      // qtype must be legit 
      if ( val.qtype == Q0 ) { go_BYE(-1); }
      if ( val.qtype >= QF ) { go_BYE(-1); }
      if ( val.qtype != SC ) { 
        uint32_t width = get_width_c_qtype(val.qtype);
        if ((( val.num_elements / width ) * width ) != val.num_elements ) {
          go_BYE(-1);
        }
      }

      // ---------------------------
      if ( kv_idx >= n ) { go_BYE(-1); }
      kv[kv_idx].vctr_uqid = key.vctr_uqid;
      kv[kv_idx].chnk_idx  =  key.chnk_idx;
      kv[kv_idx].qtype     = val.qtype;
      kv[kv_idx].num_elements = val.num_elements;
      kv[kv_idx].size      = val.size;
      kv_idx++; 
    }
    else {
      if ( memcmp(&zero_val, &(bkts[i].val), valsz) != 0 ) {
        go_BYE(-1);
      }
      if ( memcmp(&zero_key, &(bkts[i].key), keysz) != 0 ) {
        go_BYE(-1);
      }
    }
  }
  if ( kv_idx != n ) { go_BYE(-1); }
  //---------------------------------
  qsort(kv, n, sizeof(kv_t), sortcompare_kv);
  uint32_t lb = 0; 
  for ( ; ; ) { 
    if ( lb >= n ) { break; }
    // lb points to first chunk of some vector 
    qtype_t l_qtype         = kv[lb].qtype;
    uint32_t l_vctr_uqid    = kv[lb].vctr_uqid;
    uint32_t l_size         = kv[lb].size;
    uint32_t l_chnk_idx     = kv[lb].chnk_idx;
    uint32_t l_num_elements = kv[lb].num_elements;
    uint32_t exp_chnk_idx  = l_chnk_idx + 1; 

    lb++; // move on to second chunk in vector 
    for ( ; ; lb++, exp_chnk_idx++ ) { 
      // keep going until no more chunks or vector is over
      if ( lb >= n ) { break; } 
      if ( kv[lb].vctr_uqid != l_vctr_uqid ) { break; }
      // chnk_idx for a vector must be 0, 1, 2, ... 
      if ( kv[lb].chnk_idx != exp_chnk_idx ) { go_BYE(-1); } 
      // all chunks of a vector must have same type
      if ( kv[lb].qtype != l_qtype ) { go_BYE(-1); }
      // all chunks of a vector must have same size
      if ( kv[lb].size != l_size ) { go_BYE(-1); }
      bool is_last_chnk;
      if ( ( lb == (n-1) ) || ( kv[lb].vctr_uqid != l_vctr_uqid ) ) {
        is_last_chnk = true;
      }
      else {
        is_last_chnk = false;
      }
      // impose constraint on num_elements
      if ( is_last_chnk ) {
        if ( kv[lb].num_elements >  l_num_elements ) { go_BYE(-1); }
      }
      else {
        if ( kv[lb].num_elements != l_num_elements ) { go_BYE(-1); }
        // TODO: l_num_elements == l_size / l_width
      }
    }
  }

BYE:
  free_if_non_null(kv);
  return status;
}
