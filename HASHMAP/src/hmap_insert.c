#include "hmap_common.h"
#include "hmap_insert.h"
int
hmap_insert(
    hmap_t *ptr_hmap, 
    void *key,
    uint16_t len,
    bool malloc_key, // true => make a copy of the key 
    val_t val,
    dbg_t *ptr_dbg
    )
{
  int status = 0;
  if ( key == NULL ) { go_BYE(-1); } // not a valid key 
  if ( len == 0    ) { go_BYE(-1); } // not a valid key 
  //----------------------------------------------
  register uint32_t hash;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->hash == 0 ) ) { 
    hash = murmurhash3(key, len, ptr_hmap->hashkey);
  }
  else { 
    hash = ptr_dbg->hash;
  }
  //---------------------------------
  register uint32_t probe_loc; // location where we probe
  register uint32_t size = ptr_hmap->size;
  uint64_t divinfo = ptr_hmap->divinfo;
  if ( ( ptr_dbg == NULL ) || ( ptr_dbg->probe_loc == 0 ) ) { 
    probe_loc = fast_rem32(hash, size, divinfo);
  }
  else {
    probe_loc = ptr_dbg->probe_loc;
  }
  //---------------------------------------------

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
  bool key_copied = false; // means we have not copied the key 
  register uint32_t num_probes = 0;
  //-----------
  register bkt_t *bkts  = ptr_hmap->bkts;
  if ( probe_loc >= size ) { go_BYE(-1); }
  for ( ; ; ) {
    if ( num_probes >= size ) { go_BYE(-1); }
    register bkt_t *this_bkt = bkts + probe_loc;
    void *this_key     = this_bkt->key;
    uint16_t this_len  = this_bkt->len;
    uint32_t this_hash = this_bkt->hash;
    if ( this_key != NULL ) { // If there is a key in the bucket.
      if ( ( this_len == len ) && ( this_hash == hash ) && 
          ( memcmp(key, this_key, len) == 0 ) ) { 
        this_bkt->val = val; // simple assignment 
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
          key_copied = true;
        }
        len  = entry.len;
        key  = entry.key;
        hash = entry.hash;
      }
      entry.psl++;
      /* Continue to the next bucket. */
      num_probes++;
      probe_loc++;
      if ( probe_loc == size ) { probe_loc = 0; }
    }
    else { // spot is empty, grab it 
      *this_bkt = entry;
      ptr_hmap->nitems++; // one more item in hash table 
      // make a copy of key for the hash table  if necessary
      if ( ( key_copied == false ) && ( malloc_key == true ) ) { 
        this_bkt->key = malloc(len);
        return_if_malloc_failed(this_bkt->key);
        memcpy(this_bkt->key, key, len);
        key_copied = true;
      }
      else {
        this_bkt->key = key;
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
