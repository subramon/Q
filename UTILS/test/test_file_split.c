#include "q_incs.h"
#include "q_macros.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "isdir.h"
#include "file_split.h"

int 
main(
    void
    )
{
  int status = 0;
  const char * const infile = "/mnt/storage/ascdata/price_cds/000000_0";
  const char * const opdir  = "/tmp/XXX";
  uint32_t nB = 32;
  uint32_t split_col_idx  = 0;
  status = file_split(infile, opdir, nB, split_col_idx); cBYE(status);
BYE:
  return status;
}
