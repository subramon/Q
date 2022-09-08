// EXTERNAL EXPOSURE
/*
 * Freezes the hmap into 2 files, one for meta data and one for buckets
 */
 #include "rs_hmap_common.h"
 #include "rs_hmap_struct.h"
 #include "rs_hmap_freeze.h"

int
rs_hmap_freeze(
    rs_hmap_t *ptr_hmap, 
    const char * const meta_file_name,
    const char * const bkts_file_name, // for bkts (rs_hmap_bkt_t *)
    const char * const full_file_name // for bkt_full (bool *)
    )
{
  int status = 0;
  FILE *mfp = NULL, *dfp = NULL;

  if ( ptr_hmap == NULL ) { go_BYE(-1); }

  //------------------------------------------------
  if ( meta_file_name == NULL ) { go_BYE(-1); }
  mfp = fopen(meta_file_name, "w");
  return_if_fopen_failed(mfp, meta_file_name, "w");
  fprintf(mfp, "size,%" PRIu32 "\n", ptr_hmap->size);
  fprintf(mfp, "nitems,%" PRIu32 "\n", ptr_hmap->nitems);
  fprintf(mfp, "divinfo,%" PRIu64 "\n", ptr_hmap->divinfo);
  fprintf(mfp, "hashkey,%" PRIu64 "\n", ptr_hmap->hashkey);
  // following are configs
  if ( ptr_hmap->start_check_val != 123456789) { go_BYE(-1); }
  fprintf(mfp, "min_size,%" PRIu32 "\n", ptr_hmap->config.min_size);
  fprintf(mfp, "max_size,%" PRIu32 "\n", ptr_hmap->config.max_size);
  fprintf(mfp, "low_water_mark,%f\n", ptr_hmap->config.low_water_mark);
  fprintf(mfp, "high_water_mark,%f\n", ptr_hmap->config.high_water_mark);
  fprintf(mfp, "so_file,%s\n", ptr_hmap->config.so_file);
  if ( ptr_hmap->stop_check_val != 987654321) { go_BYE(-1); }
  fclose_if_non_null(mfp);

  //------------------------------------------------
  if ( bkts_file_name == NULL ) { go_BYE(-1); }
  dfp = fopen(bkts_file_name, "wb");
  return_if_fopen_failed(dfp, bkts_file_name, "wb");

  fwrite(ptr_hmap->bkts, sizeof(rs_hmap_bkt_t), ptr_hmap->size, dfp);
  fclose_if_non_null(dfp);
  //------------------------------------------------
  if ( full_file_name == NULL ) { go_BYE(-1); }
  dfp = fopen(full_file_name, "wb");
  return_if_fopen_failed(dfp, full_file_name, "wb");

  fwrite(ptr_hmap->bkt_full, sizeof(bool), ptr_hmap->size, dfp);
  fclose_if_non_null(dfp);
BYE:
  fclose_if_non_null(mfp); 
  fclose_if_non_null(dfp); 
  return status;
}
