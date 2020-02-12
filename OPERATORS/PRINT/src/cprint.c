#include "q_incs.h"
#include "cprint.h"
#include "_get_bit_u64.h"

int
cprint(
    char * opfile,
    uint64_t * cfld, // TODO 
    void **data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    int * enum_fldtypes,  
    int * width // [nC]
    )
{
  int status = 0;
  FILE *fp = NULL;
  //----------
  if ( data == NULL ) { go_BYE(-1); }
  if ( nC <= 0 ) { go_BYE(-1); }
  for ( int j = 0; j < nC; j++ ) { if ( data[j] == NULL ) { go_BYE(-1); } }
  if ( ub <= lb ) { go_BYE(-1); }
  if ( enum_fldtypes == NULL ) { go_BYE(-1); }
  if ( width == NULL ) { go_BYE(-1); }

  //----------
  if ( ( opfile != NULL ) && ( *opfile != '\0' ) ) {
    fp = fopen(opfile, "a");
    return_if_fopen_failed(fp, opfile, "a");
  }
  else {
    fp = stdout;
  }
  for ( uint64_t i = lb; i < ub; i++ ) { // for each row 
    for ( int j = 0; j < nC; j++ ) { // for each column
    if ( j > 0 ) { fprintf(fp, ","); }
      if ( enum_fldtypes[j] == QI1 ) { 
        int8_t *X = (int8_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( enum_fldtypes[j] == QI2 ) { 
        int16_t *X = (int16_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( enum_fldtypes[j] == QI4 ) { 
        int32_t *X = (int32_t *)data[j];
        fprintf(fp, "%d", X[i]);
      }
      else if ( enum_fldtypes[j] == QI8 ) { 
        int64_t *X = (int64_t *)data[j];
        fprintf(fp, "%ld", X[i]);
      }
      else if ( enum_fldtypes[j] == QF4 ) { 
        float *X = (float *)data[j];
        fprintf(fp, "%f", X[i]);
      }
      else if ( enum_fldtypes[j] == QF8 ) { 
        double *X = (double *)data[j];
        fprintf(fp, "%e", X[i]);
      }
      else if ( enum_fldtypes[j] == QB1 ) { 
        uint64_t *X = (uint64_t *)data[j];
        int bval = get_bit_u64(X, i); 
        fprintf(fp, "%d", bval);
      }
      else if ( enum_fldtypes[j] == QSC ) { 
        if ( width[j] <= 1 ) { go_BYE(-1); }
        char *X = (char *)data[j];
        X += (i * width[j]);
        fprintf(fp, "\"");
        for ( int k = 0; k < width[j]; k++ ) { 
          if ( *X == '\0' ) { break; } 
          if ( ( *X == '\\' ) || ( *X == '"' ) ) {
            fprintf(fp, "\\");
          }
          fprintf(fp, "%c", *X);
          X++;
        }
        fprintf(fp, "\"");
      }
      else if ( enum_fldtypes[j] == QTM ) { 
        // TODO 
        go_BYE(-1); 
      }
    }
    fprintf(fp, "\n");
  }
BYE:
  if ( ( opfile != NULL ) && ( *opfile != '\0' ) ) {
    fclose_if_non_null(fp);
  }
  return status;
}
