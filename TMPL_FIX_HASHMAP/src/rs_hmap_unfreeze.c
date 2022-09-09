#include "rs_hmap_common.h"
#include "rs_hmap_struct.h"
#include "rs_hmap_set_fn_ptrs.h"
#include "rs_mmap.h"
#include "rs_hmap_unfreeze.h"
int 
rs_hmap_unfreeze(
    rs_hmap_t *H,
    const char * const meta_file,
    const char * const bkts_file,
    const char * const full_file
    )
{
  int status = 0;
  FILE *mfp = NULL;
#define MAX_LINE 127
  char buf[MAX_LINE+1]; int nr;
  char *X = NULL; size_t nX = 0;

  mfp = fopen(meta_file, "r");
  return_if_fopen_failed(mfp, meta_file, "r");

  nr = fscanf(mfp, "size,%" PRIu32 "\n", &(H->size));
  if ( nr != 1 ) { go_BYE(-1); }

  nr = fscanf(mfp, "nitems,%" PRIu32 "\n", &(H->nitems));
  if ( nr != 1 ) { go_BYE(-1); }

  nr = fscanf(mfp, "divinfo,%" PRIu64 "\n", &(H->divinfo));
  if ( nr != 1 ) { go_BYE(-1); }

  nr = fscanf(mfp, "hashkey,%" PRIu64 "\n", &(H->hashkey));
  if ( nr != 1 ) { go_BYE(-1); }

  //-- configs 
  nr = fscanf(mfp, "min_size,%" PRIu32 "\n", &(H->config.min_size));
  if ( nr != 1 ) { go_BYE(-1);  }

  nr = fscanf(mfp, "max_size,%" PRIu32 "\n", &(H->config.max_size));
  if ( nr != 1 ) { go_BYE(-1);  }

  nr = fscanf(mfp, "low_water_mark,%f\n", &(H->config.low_water_mark));
  if ( nr != 1 ) { go_BYE(-1);  }

  nr = fscanf(mfp, "high_water_mark,%f\n", &(H->config.high_water_mark));
  if ( nr != 1 ) { go_BYE(-1);  }

  nr = fscanf(mfp, "so_file,%127s\n", buf); 
  if ( nr != 1 ) { go_BYE(-1);  }
  H->config.so_file = strdup(buf);

  status = rs_mmap(bkts_file, &X, &nX, 0); cBYE(status);
  status = posix_memalign((void **)&(H->bkts), 16, nX); cBYE(status);
  memcpy(H->bkts, X, nX);
  munmap(X, nX); X = NULL; nX = 0;

  status = rs_mmap(full_file, &X, &nX, 0); cBYE(status);
  status = posix_memalign((void **)&(H->bkt_full), 16, nX); cBYE(status);
  memcpy(H->bkt_full, X, nX);
  munmap(X, nX); X = NULL; nX = 0;

  // Now for the function pointers 
  status = LCL_rs_hmap_set_fn_ptrs(H); cBYE(status);
BYE:
  return status;
}
