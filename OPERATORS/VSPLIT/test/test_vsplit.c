#include "q_incs.h"
#include "qtypes.h"
#include "vsplit.h"

int
main(
    void
    )
{
  int status = 0;
  // START Inputs 
#define nC 5  // number of columns
#define nF 4  // number of input files
  char *infiles[nF];
  char *outfiles[nC];
  char *nn_outfiles[nC];
  infiles[0] = strdup("./infile0.csv");
  infiles[1] = strdup("./infile1.csv");
  infiles[2] = strdup("./infile2.csv");
  infiles[3] = strdup("./infile3.csv");

  outfiles[0] = strdup("./outfile0.bin");
  outfiles[1] = strdup("./outfile1.bin");
  outfiles[2] = strdup("./outfile2.bin");
  outfiles[3] = NULL; // not being loaded
  outfiles[4] = strdup("./outfile4.bin");

  nn_outfiles[0] = NULL;
  nn_outfiles[1] = strdup("./nn_outfile1.bin");
  nn_outfiles[2] = NULL;
  nn_outfiles[3] = NULL;
  nn_outfiles[4] = strdup("./nn_outfile4.bin");

  // Create empty output files
  for ( int i = 0; i < nC; i++ ) { 
    if ( outfiles[i] != NULL ) {
      FILE *fp = fopen(outfiles[i], "wb");
      fclose_if_non_null(fp);
    }
    if ( nn_outfiles[i] != NULL ) {
      FILE *fp = fopen(nn_outfiles[i], "wb");
      fclose_if_non_null(fp);
    }
  }
  const char * const str_fld_sep = "comma";
  uint32_t max_width = 64;
  int c_qtypes[nC] = { SC, I2, I8, I4, F4 };
  bool is_load[nC] = { true, true, true, false, true};
  bool has_nulls[nC] = { false, true, false, false, true };
  uint32_t width[nC] = { 32, 2, 8, 4, 4 };
  // STOP  Inputs 

  for ( int i = 0; i < nF; i++ ) { 
    status = vsplit(
        infiles[i],
        nC,
        str_fld_sep,
        max_width,
        c_qtypes, 
        is_load, 
        has_nulls, 
        width, 
        outfiles,
        nn_outfiles);
    cBYE(status);
  }
  // START: some very rudimentary checking 
  // STOP : some very rudimentary checking 
  printf("vsplit tests completed succesfully\n");
BYE:
  for ( int i = 0; i < nF; i++ ) { 
    free_if_non_null(infiles[i]);
  }
  for ( int i = 0; i < nC; i++ ) { 
    free_if_non_null(outfiles[i]);
    free_if_non_null(nn_outfiles[i]);
  }
  return status;
}
