#include "q_incs.h"
#include "qtypes.h"
#include "vctr_rs_hmap_struct.h"
#include "vctr_rs_hmap_get.h"
#include "vctr_is.h"
#include "vctr_get_set.h"

extern vctr_rs_hmap_t *g_vctr_hmap;

typedef enum { 
  get_set_undef,
  get,
  set,
} get_set_t;

// Centralized location for all kinds of meta-data 
int
vctr_get_set(
    uint32_t tbsp,
    uint32_t vctr_uqid,
    const char  * const meta,
    const char  * const get_or_set,
    bool *ptr_bl,
    int64_t *ptr_i8,
    const char * in_str,
    char **ptr_out_str
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  get_set_t mode;
  if ( meta == NULL ) { go_BYE(-1); }
  if ( get_or_set == NULL ) { go_BYE(-1); }

  if ( strcmp(get_or_set, "get") == 0 ) { 
    mode = get; 
  }
  else if ( strcmp(get_or_set, "set") == 0 ) { 
    if ( tbsp != 0 ) { go_BYE(-1); } 
    mode = set; 
  }
  else { go_BYE(-1); }

  vctr_rs_hmap_key_t key = vctr_uqid;
  vctr_rs_hmap_val_t val; memset(&val, 0, sizeof(vctr_rs_hmap_val_t));
  status = vctr_rs_hmap_get(&g_vctr_hmap[tbsp], &key, &val, &is_found, 
      &where_found);
  if ( !is_found ) { 
    go_BYE(-1); }
  vctr_rs_hmap_val_t *ptr_val = &(g_vctr_hmap[tbsp].bkts[where_found].val);
  // do not access/modify vector in error state 
  if ( val.is_error ) { go_BYE(-1); } 

  if ( strcmp(meta, "eov") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_bl = val.is_eov; break;
                 // Note that you never set is_eov := false
      case set : ptr_val->is_eov = true; break; 
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "error") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_bl = val.is_error; break;
                 // Note that you never set is_error := false
      case set : ptr_val->is_error = true; break; 
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "lma") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_bl = val.is_lma; break;
                 // NOT HERE case set : ptr_val->is_error = *ptr_bl; break; 
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "persist") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_bl = val.is_persist; break;
      case set : ptr_val->is_persist = *ptr_bl; break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "max_num_in_chunk") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_i8 = val.max_num_in_chnk; 
        break;
      case set : 
        {
          if ( *ptr_i8 < 64 ) { go_BYE(-1); }
          if ( ( ( *ptr_i8 / 64 ) * 64 )  != *ptr_i8 ) { go_BYE(-1); }
          ptr_val->max_num_in_chnk = *ptr_i8;  
        }
        break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "max_chnk_idx") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_i8 = val.max_chnk_idx; break;
      case set : /* not needed */ break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "min_chnk_idx") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_i8 = val.min_chnk_idx; break;
      case set : /* not needed */ break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "width") == 0 ) { 
    switch ( mode ) { 
      case get : *ptr_i8 = val.width; break;
      case set : /* not needed */ break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "qtype") == 0 ) { 
    switch ( mode ) {
      case get : 
        *ptr_i8 = val.qtype; 
        break;
      case set :
        if ( ( *ptr_i8 <= Q0 ) || ( *ptr_i8 >= QF ) ) { go_BYE(-1); }
        ptr_val->qtype = *ptr_i8;
        break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "name") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_out_str = strdup(val.name);
        break;
      case set : 
        if ( in_str == NULL ) { go_BYE(-1); }
        if ( strlen(in_str) > MAX_LEN_VCTR_NAME ) { 
          fprintf(stderr, "Name too long %s \n", in_str); 
          go_BYE(-1); }
        strcpy(ptr_val->name, in_str);

        // TODO 
        break;
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "has_parent") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_bl = val.has_parent;
        break;
        /* Set needs to be done elswehere
           case set : 
           break;
           */
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "nn_key") == 0 ) {
    switch ( mode ) {
      case get :
        *ptr_i8 = val.nn_key;
        break;
        /* Set needs to be done elswehere
           case set :
           break;
           */
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "has_nn") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_bl = val.has_nn;
        break;
        /* Set needs to be done elswehere
           case set : 
           break;
           */
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "is_nn") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_bl = val.has_parent;
        break;
        /* Set needs to be done elswehere
           case set : 
           break;
           */
      default : go_BYE(-1); break;
    }
  }
  else if ( strcmp(meta, "early_freeable") == 0 ) { 
    switch ( mode ) { 
      case get : 
        *ptr_bl = val.is_early_freeable;
        *ptr_i8 = val.num_free_ignore; 
        break;
      case set : 
        {
          // cannot set once set 
          if ( val.is_early_freeable ) { go_BYE(-1); } 
          ptr_val->is_early_freeable = true;
          if ( *ptr_i8 < 0 ) { go_BYE(-1); }
          ptr_val->num_free_ignore = *ptr_i8;
        }
        break;
      default : go_BYE(-1); break;
    }
  }
  else {
    fprintf(stderr, "Don't know hwo to get/set for %s \n", meta);
    go_BYE(-1);
  }
BYE:
  return status;
}
