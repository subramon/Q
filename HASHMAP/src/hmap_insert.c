#include "hmap_common.h"
#include "hmap_aux.h"
#include "hmap_insert.h"
#include "val_update.h"


int
hmap_insert(
    hmap_t *ptr_hmap, 
    void *key,
    uint16_t len,
    bool malloc_key, // true => make a copy of the key 
    void *val,
    dbg_t *ptr_dbg
    )
{
  int status = 0;
  if ( key == NULL ) { go_BYE(-1); } // not a valid key 
  if ( len == 0    ) { go_BYE(-1); } // not a valid key 
  register uint32_t hash = set_hash(key, len, ptr_hmap, ptr_dbg);
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
  entry.key  = key;
  entry.len  = len;
  entry.hash = hash;
  entry.val  = val;
  bool key_copied = false; // means we have not copied the key or val
  register uint32_t num_probes = 0;
  //-----------
  register bkt_t *bkts  = ptr_hmap->bkts;
  if ( probe_loc >= ptr_hmap->size ) { go_BYE(-1); }
  for ( ; ; ) {
    if ( num_probes >= ptr_hmap->size ) { go_BYE(-1); }
    register bkt_t *this_bkt = bkts + probe_loc;
    void *this_key     = this_bkt->key;
    uint16_t this_len  = this_bkt->len;
    uint32_t this_hash = this_bkt->hash;
    if ( this_key != NULL ) { // If there is a key in the bucket.
      if ( ( this_len == len ) && ( this_hash == hash ) && 
          ( memcmp(key, this_key, len) == 0 ) ) { 
        status = val_update(&(this_bkt->val), val);  cBYE(status);
        break;
      }
      //-----------------------
      // We found a "rich" bucket.  Capture its location.
      if ( entry.psl > bkts[probe_loc].psl ) {
        bkt_t tmp;
        tmp = entry;
        entry = bkts[probe_loc];
        bkts[probe_loc] = tmp;
        if ( ( key_copied == false ) && ( malloc_key == true ) ) { 
          bkts[probe_loc].key = malloc(len); 
          return_if_malloc_failed(bkts[probe_loc].key);
          memcpy(bkts[probe_loc].key, key, len); 
          bkts[probe_loc].val = NULL;
          status = val_update(&(this_bkt->val), val);  cBYE(status);
          key_copied = true;
        }
        len  = entry.len;
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
      // make a copy of key for the hash table  if necessary
      if ( ( key_copied == false ) && ( malloc_key == true ) ) { 
        this_bkt->key = malloc(len);
        return_if_malloc_failed(this_bkt->key);
        memcpy(this_bkt->key, key, len);
        this_bkt->val = NULL;
        status = val_update(&(this_bkt->val), val);  cBYE(status);
        key_copied = true;
      }
      //--------------
      break;
    }
  }
  if ( ptr_dbg != NULL ) { 
    ptr_dbg->num_probes += num_probes;
  }
BYE:
  return status;
}
