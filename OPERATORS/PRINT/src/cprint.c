#include "q_incs.h"
#include "qtypes.h"
#include "cprint.h"
#include "get_bit_u64.h"

int
cprint(
    const char * opfile,
    const void * const cfld, // TODO 
    const void ** data, // [nC][nR] 
    const bool ** nn_data, // [nC][nR] 
    int nC,
    uint64_t lb,
    uint64_t ub,
    const int32_t  * const qtypes,//[nC]
    const int32_t * const widths // [nC]
    )
{
  int status = 0;
  FILE *fp = NULL;
  if ( qtypes == NULL ) { go_BYE(-1); }
  if ( widths == NULL ) { go_BYE(-1); }
  //----------
  if ( data == NULL ) { go_BYE(-1); }
  if ( nn_data == NULL ) { go_BYE(-1); }
  if ( cfld != NULL ) { go_BYE(-1); } // TODO TODO TODO 
  if ( nC <= 0 ) { go_BYE(-1); }
  for ( int j = 0; j < nC; j++ ) { if ( data[j] == NULL ) { go_BYE(-1); } }
  if ( ub <= lb ) { go_BYE(-1); }

  for ( int i = 0; i < nC; i++ ) { 
    if ( ( qtypes[i] <= 0 ) || ( qtypes[i] >= NUM_QTYPES ) ) { go_BYE(-1); }
    // 32 is just a sanity check, could be tighter
    if ( qtypes[i] != SC ) {
    if ( ( widths[i] <= 0 ) || ( widths[i] >= 32 ) ) { go_BYE(-1); }
    }
  }
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
      const char * X = data[j];
      if ( j > 0 ) { fprintf(fp, ","); }
      if ( nn_data[j] != NULL ) {
        if ( nn_data[j] == false ) {
          fprintf(fp, "\"\"");
          continue;
        }
      }
      switch ( qtypes[j] ) {
        case B1 : 
          {
            go_BYE(-1); // TODO 
            int ival = get_bit_u64((const uint64_t *)X, i); 
            fprintf(fp, "%s\n", ival ? "true" : "false"); break;
          }
          break;
        case BL : fprintf(fp, "%s", ((const bool *)X)[i] ? "true" : "false");
                  break;
        case I1 : fprintf(fp, "%d", ((const int8_t *)X)[i]); break;
        case I2 : fprintf(fp, "%d", ((const int16_t *)X)[i]); break;
        case I4 : fprintf(fp, "%d", ((const int32_t *)X)[i]); break;
        case I8 : fprintf(fp, "%ld", ((const int64_t *)X)[i]); break;
        case F4 : fprintf(fp, "%f", ((const float *)X)[i]); break;
        case F8 : fprintf(fp, "%lf", ((const double *)X)[i]); break;
        case SC :  
                  {
                    if ( widths[j] <= 1 ) { go_BYE(-1); }
                    X += (i * widths[j]);
                    fprintf(fp, "\"");
                    for ( int k = 0; k < widths[j]; k++ ) { 
                      if ( *X == '\0' ) { break; } 
                      if ( ( *X == '\\' ) || ( *X == '"' ) ) {
                        fprintf(fp, "\\");
                      }
                      fprintf(fp, "%c", *X);
                      X++;
                    }
                    fprintf(fp, "\"");
                  }
                  break;
        case TM1 : 
                  { 
                     char buf[64]; 
                     int len = sizeof(buf); 
                     memset(buf, 0, len);
                     const tm_t * tptr = ((const tm_t *)X);
                     snprintf(buf, len-1, "\"%d:%02d:%02d:%d:%d:%d:%d\"", 
                         tptr[i].tm_year + 1900,
                         tptr[i].tm_mon + 1,
                         tptr[i].tm_mday,
                         tptr[i].tm_hour,
                         tptr[i].tm_min,
                         tptr[i].tm_sec,
                         tptr[i].tm_yday);

                     fprintf(fp, "%s", buf);
                  }
                  break;
        default : 
                  fprintf(stderr, "Unknown qtypes[%d] = %d \n", j, qtypes[j]);
                  go_BYE(-1); 
                  break;
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
