#include "q_incs.h"
#include "qtypes.h"
#include "cprint.h"
#include "get_bit_u64.h"

int
cprint(
    const char * const opfile,
    const uint64_t * const cfld, // TODO 
    void ** restrict data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const int  * const qtypes,  
    const int * const width // [nC]
    )
{
  int status = 0;
  FILE *fp = NULL;
  //----------
  if ( data == NULL ) { go_BYE(-1); }
  if ( nC <= 0 ) { go_BYE(-1); }
  for ( int j = 0; j < nC; j++ ) { if ( data[j] == NULL ) { go_BYE(-1); } }
  if ( ub <= lb ) { go_BYE(-1); }
  if ( qtypes == NULL ) { go_BYE(-1); }
  if ( width  == NULL ) { go_BYE(-1); }

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
      char *X = (char *)data[j];
      if ( j > 0 ) { fprintf(fp, ","); }
      switch ( qtypes[j] ) {
        case I1 : fprintf(fp, "%d", ((int8_t *)X)[i]); break;
        case I2 : fprintf(fp, "%d", ((int16_t *)X)[i]); break;
        case I4 : fprintf(fp, "%d", ((int32_t *)X)[i]); break;
        case I8 : fprintf(fp, "%ld", ((int64_t *)X)[i]); break;
        case F4 : fprintf(fp, "%f", ((float *)X)[i]); break;
        case F8 : fprintf(fp, "%lf", ((double *)X)[i]); break;
        case SC :  // TODO NEEDS TO BE TESTED 
                  {
                    if ( width[j] <= 1 ) { go_BYE(-1); }
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
        default : go_BYE(-1); break;
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
