#include "q_incs.h"
#include "cprint.h"
#include "_get_bit_u64.h"

int
cprint(
    const char * const opfile,
    uint64_t *cfld,
    void **data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const char ** const fldtypes, // [nC] 
    int *widths // [nC]
    )
{
  int status = 0;
  //----------
  if ( data == NULL ) { go_BYE(-1); }
  if ( nC <= 0 ) { go_BYE(-1); }
  for ( int i = 0; i < nC; i++ ) { if ( data[i] == NULL ) { go_BYE(-1); } }
  if ( ub <= lb ) { go_BYE(-1); }
  if ( fldtypes == NULL ) { go_BYE(-1); }
  if ( widths == NULL ) { go_BYE(-1); }

  //----------
  FILE *fp = NULL;
  if ( ( opfile != NULL ) && ( *opfile != '\0' ) ) {
    fp = fopen(opfile, "a");
    return_if_fopen_failed(fp, opfile, "a");
  }
  else {
    fp = stdout;
  }
  for ( uint64_t i = lb; i < ub; i++ ) { // for each row 
    for ( int j = 0; j < nC; j++ ) { // for each column
      if ( strcmp(fldtypes[j], "I1") == 0 ) { 
        int8_t *X = (int8_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "I2") == 0 ) { 
        int16_t *X = (int16_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "I4") == 0 ) { 
        int32_t *X = (int32_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "I8") == 0 ) { 
        int64_t *X = (int64_t *)data[j];
        fprintf(fp, "%ld", X[i]);
      }
      else if ( strcmp(fldtypes[j], "F4") == 0 ) { 
        float *X = (float *)data[j];
        fprintf(fp, "%lf", X[i]);
      }
      else if ( strcmp(fldtypes[j], "F8") == 0 ) { 
        double *X = (double *)data[j];
        fprintf(fp, "%lf", X[i]);
      }
      else if ( strcmp(fldtypes[j], "B1") == 0 ) { 
        uint64_t *X = (uint64_t *)data[j];
        int bval = get_bit_u64(X, i); 
        fprintf(fp, "%d", bval);
      }
      else if ( strcmp(fldtypes[j], "SC") == 0 ) { 
        // TODO 
        go_BYE(-1); 
      }
      else if ( strcmp(fldtypes[j], "TM") == 0 ) { 
        // TODO 
        go_BYE(-1); 
      }
    }
  }
BYE:
  if ( ( opfile != NULL ) && ( *opfile != '\0' ) ) {
    fclose_if_non_null(fp);
  }
  return status;
}
