
// Note that 0 is left unused, hence <= 0 and not < 0
#define chk_chunk_dir_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= ptr_S->chunk_dir->sz) ) { go_BYE(-1); } \
}
#define chk_whole_vec_dir_idx(x) { \
  if ( ( x <= 0 ) || ( (uint32_t)x >= ptr_S->whole_vec_dir->sz) ) { go_BYE(-1); } \
}


#define INITIAL_NUM_CHUNKS_PER_VECTOR 32
#define NUM_HEX_DIGITS_IN_UINT64      31 
