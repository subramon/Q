// EXTERNAL EXPOSURE
/*
 * Freezes the hmap into 2 files, one for meta data and one for buckets
 */
#include "mk_dir_file_name.h"
#include "rs_hmap_common.h"
#include "${tmpl}_rs_hmap_struct.h"
#include "_rs_hmap_freeze.h"

int
rs_hmap_freeze(
    ${tmpl}_rs_hmap_t *ptr_hmap, 
    const char * const dir,
    const char * const meta_file_name,
    const char * const bkts_file_name, // for bkts (${tmpl}_rs_hmap_bkt_t *)
    const char * const full_file_name // for bkt_full (bool *)
    )
{
  int status = 0;
  FILE *fp = NULL;
  char * fname = NULL; 

  if ( ptr_hmap == NULL ) { go_BYE(-1); }

  //------------------------------------------------
  if ( meta_file_name == NULL ) { go_BYE(-1); } 
  fname = mk_dir_file_name(dir, meta_file_name);
  if ( fname == NULL ) { go_BYE(-1); } 

  fp = fopen(fname, "w");
  return_if_fopen_failed(fp, fname, "w");
  fprintf(fp, "size,%" PRIu32 "\n", ptr_hmap->size);
  fprintf(fp, "nitems,%" PRIu32 "\n", ptr_hmap->nitems);
  fprintf(fp, "divinfo,%" PRIu64 "\n", ptr_hmap->divinfo);
  fprintf(fp, "hashkey,%" PRIu64 "\n", ptr_hmap->hashkey);
  // following are configs
  if ( ptr_hmap->start_check_val != 123456789) { go_BYE(-1); }
  fprintf(fp, "min_size,%" PRIu32 "\n", ptr_hmap->config.min_size);
  fprintf(fp, "max_size,%" PRIu32 "\n", ptr_hmap->config.max_size);
  fprintf(fp, "low_water_mark,%f\n", ptr_hmap->config.low_water_mark);
  fprintf(fp, "high_water_mark,%f\n", ptr_hmap->config.high_water_mark);
  fprintf(fp, "so_file,%s\n", ptr_hmap->config.so_file);
  if ( ptr_hmap->stop_check_val != 987654321) { go_BYE(-1); }
  fclose_if_non_null(fp);
  free_if_non_null(fname);

  //------------------------------------------------
  if ( bkts_file_name == NULL ) { go_BYE(-1); }
  fname = mk_dir_file_name(dir, bkts_file_name);
  if ( fname == NULL ) { go_BYE(-1); } 

  fp = fopen(fname, "wb");
  return_if_fopen_failed(fp, fname, "wb");

  fwrite(ptr_hmap->bkts, sizeof(${tmpl}_rs_hmap_bkt_t), ptr_hmap->size, fp);
  fclose_if_non_null(fp);
  free_if_non_null(fname);
  //------------------------------------------------
  if ( full_file_name == NULL ) { go_BYE(-1); }
  fname = mk_dir_file_name(dir, full_file_name);
  if ( fname == NULL ) { go_BYE(-1); } 
  fp = fopen(fname, "wb");
  return_if_fopen_failed(fp, fname, "wb");

  fwrite(ptr_hmap->bkt_full, sizeof(bool), ptr_hmap->size, fp);
  fclose_if_non_null(fp);
  free_if_non_null(fname);
BYE:
  free_if_non_null(fname);
  fclose_if_non_null(fp); 
  return status;
}
