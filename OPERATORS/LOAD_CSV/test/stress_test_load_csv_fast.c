#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "load_csv_fast.h"
#include "_get_file_size.h"
#include "q_incs.h"
#include "_mmap.h"

#define MAX_NUM_COLS 2048
// _f1024 is 6 chars and then one space for null char
#define MAX_LEN_FILE_NAME 256
int
main(
    int argc,
    char **argv
    ) 
{
  int status = 0;
  char *fldtypes[MAX_NUM_COLS];
  bool has_nulls[MAX_NUM_COLS];
  bool is_load[MAX_NUM_COLS];
  uint64_t num_nulls[MAX_NUM_COLS];

  int niters;
  if ( argc == 2 ) {
    niters = atoi(argv[1]); 
  }
  else {
    niters = 1;
  }
  const char *data_dir = "/tmp/";
  const char *infile = "/home/subramon/WORK/Q/TESTS/AB1/data/eee_1.csv";
  uint32_t nC = 5;
  uint64_t nR = 0;
  //----------------------
  for ( int i = 0; i < MAX_NUM_COLS; i++ ) { fldtypes[i] = NULL; }
  fldtypes[0] = strdup("I8");
  fldtypes[1] = strdup("SC");
  fldtypes[2] = strdup("I4");
  fldtypes[3] = strdup("SC");
  fldtypes[4] = strdup("F8");
  //----------------------
  bool is_hdr = true;
  is_load[0] = true;
  is_load[1] = false;
  is_load[2] = true;
  is_load[3] = false;
  is_load[4] = true;
  //----------------------
  has_nulls[0] = false;
  has_nulls[1] = true;
  has_nulls[2] = true;
  has_nulls[3] = false;
  has_nulls[4] = true;
  //----------------------
  for ( int i = 0; i <  MAX_NUM_COLS; i++ ) { num_nulls[i] = 0; }
  char **out_files = NULL;
  char **nil_files = NULL;
  char *str_for_lua = NULL;
  int sz_str_for_lua = 8192;
  str_for_lua = malloc(sz_str_for_lua);
  return_if_malloc_failed(str_for_lua);
  int n_str_for_lua = 0;

  for ( int i = 0; i < niters; i++ ) { 
  status = load_csv_fast(
      data_dir, 
      infile, 
      nC, 
      &nR, 
      fldtypes, 
      is_hdr, 
      is_load, 
      has_nulls, 
      num_nulls, 
      &out_files, 
      &nil_files,
      str_for_lua, sz_str_for_lua, &n_str_for_lua);
  cBYE(status);
  if ( ( i % 10000 ) == 0 )  {
    fprintf(stderr, "Iter = %d \n", i);
    system("rm -f /tmp/_*.bin");
  }
  }
  system("rm -f /tmp/_*.bin");
  fprintf(stdout, "SUCCESS\n");
BYE:
  for ( int i = 0; i < MAX_NUM_COLS; i++ ) { 
    free_if_non_null(fldtypes[i]);
  }
  free_if_non_null(str_for_lua);
  return status;
}
