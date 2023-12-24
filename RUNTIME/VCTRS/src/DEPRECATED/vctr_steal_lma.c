char *
vctr_steal_lma(
    uint32_t tbsp,
    uint32_t uqid
    )
{
  int status = 0;
  bool is_found; uint32_t where_found = ~0;
  char *lma_file = NULL;
  char *new_file = NULL;

  // Cannot steal lma from a different tablespace
  if ( tbsp != 0 ) { go_BYE(-1); } 

  status = vctr_is(tbsp, uqid, &is_found, &where_found); cBYE(status);
  if ( !is_found ) { go_BYE(-1); }
  vctr_rs_hmap_val_t val = g_vctr_hmap[tbsp].bkts[where_found].val;
  if ( !val.is_lma )          { go_BYE(-1); } 
  if ( val.num_writers != 0 ) { go_BYE(-1); }
  if ( val.num_readers != 0 ) { go_BYE(-1); }
  if ( val.X           != NULL ) { go_BYE(-1); }
  if ( val.nX          != 0 ) { go_BYE(-1); }

  lma_file = l2_file_name(tbsp, uqid, ((uint32_t)~0));
  if ( lma_file == NULL ) { go_BYE(-1); }
  if ( !file_exists(lma_file) ) { go_BYE(-1); }
  new_file = malloc(strlen(lma_file) + 64);
  return_if_malloc_failed(new_file);
  sprintf(new_file, "%s_%" PRIu64 "", lma_file, RDTSC());
  status = rename(lma_file, new_file); cBYE(status);
  g_vctr_hmap[tbsp].bkts[where_found].val.is_lma = false; 
BYE:
  free_if_non_null(lma_file);
  if ( status == 0 ) { return new_file; } else { return NULL; } 
}
