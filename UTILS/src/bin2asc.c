#include "q_incs.h"
#include "_mmap.h"
#include "_SC_to_txt.h"
#include "_I1_to_txt.h"
#include "_I2_to_txt.h"
#include "_I4_to_txt.h"
#include "_I8_to_txt.h"
#include "_F4_to_txt.h"
#include "_F8_to_txt.h"
#include "_txt_to_I4.h"

/* Given a single column integer file, it converts it into binary.
   Inputs 
   (1) Input file
   (2) fldtype, can be any qtype
   Output
   (1) Output file
*/

#define MAXLINE 64


#define BUFLEN 1024

//START_FUNC_DECL
int
bin2asc(
    char *infile,
    char *fldtype,
    int in_width, // for SC
    char *outfile
     )
//STOP_FUNC_DECL
{
  int status = 0;
  qtype_type qtype;
  FILE *ofp = NULL;
  int width;
  char *X = NULL; size_t nX = 0;

  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  if ( *outfile != '\0' ) { 
    if ( strcmp(infile, outfile) == 0 ) { go_BYE(-1); }
    ofp = fopen(outfile, "w");
    return_if_fopen_failed(ofp, outfile, "w");
  }
  else {
    ofp = stdout;
  }

  if ( strcasecmp(fldtype, "I1") == 0 ) {
    qtype = I1;
    width = 1;
  }
  else if ( strcasecmp(fldtype, "I2") == 0 ) {
    qtype = I2;
    width = 2;
  }
  else if ( strcasecmp(fldtype, "I4") == 0 ) {
    qtype = I4;
    width = 4;
  }
  else if ( strcasecmp(fldtype, "I8") == 0 ) {
    qtype = I8;
    width = 8;
  }
  else if ( strcasecmp(fldtype, "F4") == 0 ) {
    qtype = F4;
    width = 4;
  }
  else if ( strcasecmp(fldtype, "F8") == 0 ) {
    qtype = F8;
    width = 8;
  }
  else if ( strcasecmp(fldtype, "SC") == 0 ) {
    width = in_width;
    qtype = SC;
    if ( width < 2 ) { go_BYE(-1); }
  }
  else if ( strcasecmp(fldtype, "TM") == 0 ) {
    /* not implemented */ go_BYE(-1); 
  }
  else { go_BYE(-1); }
  if ( width < 1 ) { go_BYE(-1); }

  int num_rows = nX / width;
  if ( ( num_rows * width ) != nX )  { go_BYE(-1); }
  for ( int row_idx = 0; row_idx < num_rows; row_idx++ ) { 
    char buf[BUFLEN];
    memset(buf, '\0', BUFLEN);
    switch ( qtype ) { 
      case I1 : 
        status = I1_to_txt(((int8_t *)X), NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case I2 : 
        status = I2_to_txt(((int16_t *)X),  NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case I4 : 
        status = I4_to_txt(((int32_t *)X), NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case I8 : 
        status = I8_to_txt(((int64_t *)X),  NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case F4 : 
        status = F4_to_txt(((float *)X),  NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case F8 : 
        status = F8_to_txt(((double *)X), NULL, buf, BUFLEN-1); cBYE(status);
        break;
      case SC : 
        status = SC_to_txt(X, width, buf, BUFLEN-1); cBYE(status);
        break;
      default : 
        go_BYE(-1);
        break;
    }
    X += width;
    fprintf(ofp, "%s\n", buf);
  }
BYE:
  mcr_rs_munmap(X, nX);
  if ( *outfile != '\0' ) { 
    fclose_if_non_null(ofp);
  }
  return status ;
}
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  int len = 0;
  if ( argc != 5 ) { go_BYE(-1); }
  char *infile    = argv[1];
  char *str_qtype = argv[2]; 
  char *str_len   = argv[3];
  status = txt_to_I4(str_len, &len); cBYE(status);
  char *opfile    = argv[4];
  status = bin2asc(infile, str_qtype, len, opfile); cBYE(status);
BYE:
  return status;
}
