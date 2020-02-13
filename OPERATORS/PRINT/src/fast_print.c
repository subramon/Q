
int
fast_print(
    const char ** const X, // input [nC][nR]
    uint64_t nC,
    uint64_t nR, // number of elements in vector 
    uint64_t lb,
    uint64_t ub,
    uint64_t chunk_size,
    const int *const fldtypes, // [nC]
    const uint64_t *const cfld, // [nR/8]
    const char *const filename
    )
{
  int status = 0;
  FILE *fp = NULL;
  if ( ( filename != NULL ) && ( *filename != '\0' ) ) {
    fp = fopen(filename, "w");
    return_if_fopen_failed(fp,  filename, "w");
  }
  int32_t chunk_num = 0;
  for ( ; ; ) {
    // determine if this chunk is of interest
    if ( ub < ( chunk_num * chunk_size ) ) {
      break;
    }
    if ( lb > ( (chunk_num+1) * chunk_size ) ) {
      continue;
    }
    if ( 
  }
BYE:
  if ( ( filename != NULL ) && ( *filename != '\0' ) ) {
    fclose_if_non_null(fp); 
  }
  return status;
}
























