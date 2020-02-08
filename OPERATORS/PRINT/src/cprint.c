#include "q_incs.h"
#include "cprint.h"

int
cprint(
    const char * const opfile,
    uint64_t *cfld,
    void **data, // [nC][nR] 
    uint64_t nC,
    uint64_t lb,
    uint64_t ub,
    const char ** const fldtypes
    )
{
  int status = 0;
  FILE *fp = NULL;
  if ( ( opfile != NULL ) && ( *opfile != '\0' ) ) {
    fp = fopen(opfile, "w");
    return_if_fopen_failed(fp, opfile, "w");
  }
  else {
    fp = stdout;
  }
  for ( int i = lb; i < ub; i++ ) { // for each row 
    for ( int j = 0; j < nC; j++ ) { // for each column
      if ( strcmp(fldtypes[j], "I1") == 0 ) { 
        int8_t *X = (uint8_t *)data[j];
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
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "F4") == 0 ) { 
        float *X = (float *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "F8") == 0 ) { 
        double *X = (double *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( strcmp(fldtypes[j], "B1") == 0 ) { 
        // TODO 
        go_BYE(-1); 
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
