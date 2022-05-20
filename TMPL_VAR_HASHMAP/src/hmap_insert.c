#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_insert.h"

int
hmap_insert(
    hmap_t *ptr_hmap, 
    void * key,
    void * val,
    bool is_resize,
    dbg_t *ptr_dbg
    )
{
  int status = 0;
  uint16_t len_to_hash; char *str_to_hash = NULL; bool free_to_hash;
  status = key_hash(key, &str_to_hash, &len_to_hash, &free_to_hash); 
  register uint32_t hash = set_hash(str_to_hash, len_to_hash, 
      ptr_hmap, ptr_dbg);
  if ( free_to_hash ) { free(str_to_hash); str_to_hash = NULL; }

  register uint32_t probe_loc = set_probe_loc(hash, ptr_hmap, ptr_dbg);

  /*
   * From the paper: "when inserting, if a record probes a location
   * that is already occupied, the record that has traveled longer
   * in its probe sequence keeps the location, and the other one
   * continues on its probe sequence" (page 12).
   *
   * Basically: if the probe sequence length (PSL) of the element
   * being inserted is greater than PSL of the element in the bucket,
   * then swap them and continue.
   */
  // set up the bucket entry 
  bkt_t entry;
  memset(&entry, '\0', sizeof(bkt_t));
  entry.hash = hash;
  entry.key  = key;
  entry.val  = val;
  bool kv_copied = false; // means we have not copied the key/val
  if ( is_resize ) { 
    kv_copied = true;
  }
  register uint32_t num_probes = 0;
#ifdef DEBUG
  if ( !key_chk(key) ) { go_BYE(-1); }
  if ( is_resize ) {
    if ( !val_chk(val) ) { go_BYE(-1); }
  }
  else {
    if ( !inval_chk(val) ) { go_BYE(-1); }
  }
#endif
  //-----------
  register bkt_t *bkts  = ptr_hmap->bkts;
  if ( probe_loc >= ptr_hmap->size ) { go_BYE(-1); }
  for ( ; ; ) {
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    register bkt_t *this_bkt = bkts + probe_loc;
    void *this_key     = this_bkt->key;
    uint32_t this_hash = this_bkt->hash;
    if ( this_key != NULL ) { // If there is a key in the bucket.
      // If you are are the key in this bucket 
      if ( ( this_hash == hash ) && ( key_cmp(this_key, key) ) ) { 
        // When resizing, you can't see same key twice 
        if ( is_resize ) { go_BYE(-1); }
        //------------------------
        if ( kv_copied ) { 
          status = val_update(this_bkt->val, val);  
        }
        else {
          status = inval_update(this_bkt->val, val);  
        }
        cBYE(status);
        break;
      }
      //-----------------------
      // We found a "rich" bucket.  Capture its location.
      if ( entry.psl > bkts[probe_loc].psl ) {
        bkt_t tmp = entry;
        entry = bkts[probe_loc];
        bkts[probe_loc] = tmp;
        if ( kv_copied == false ) { 
          bkts[probe_loc].key = key_copy(key); 
          bkts[probe_loc].val = inval_copy(val); 
          kv_copied = true;
        }
        key  = entry.key;
        val  = entry.val;
        hash = entry.hash;
      }
      entry.psl++;
      /* Continue to the next bucket. */
      num_probes++;
      probe_loc++;
      if ( probe_loc == ptr_hmap->size ) { probe_loc = 0; }
    }
    else { // spot is empty, grab it 
      *this_bkt = entry;
      ptr_hmap->nitems++; // one more item in hash table 
      if ( kv_copied == false ) { 
        // When resizing, we just take over the pointers
        // Else, we need to allocate memory for key/val
        if ( !is_resize ) { 
          this_bkt->key = key_copy(key); 
          this_bkt->val = inval_copy(val); 
          kv_copied = true;
        }

      }
      break;
    }
  }
  if ( ptr_dbg != NULL ) { 
    ptr_dbg->num_probes += num_probes;
  }
BYE:
  return status;
}
