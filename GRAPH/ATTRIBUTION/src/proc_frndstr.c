#include "q_incs.h"
#define MAXLINE 63
int 
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  FILE *ifp = NULL;
  FILE *ofp = NULL;
  char line[MAXLINE+1];
  int lno = 0; int skip = 0; int comment = 0;

  if ( argc != 3 ) { 
    fprintf(stderr, "Usage is %s <infile> <outfile>\n", argv[0]);
    go_BYE(-1);
  }
  char *infile = argv[1];
  char *opfile = argv[2];
  if ( strcmp(infile, opfile) == 0 ) { go_BYE(-1); }
  ifp = fopen(infile, "r"); 
  return_if_fopen_failed(ifp, infile, "r");
  ofp = fopen(opfile, "w"); 
  return_if_fopen_failed(ofp, opfile, "w");
  int from, to, prev_from = -1;
  for ( ; !feof(ifp); ) { 
    memset(line, '\0', MAXLINE);
    char *cptr = fgets(line, MAXLINE, ifp);
    if ( cptr == NULL ) { break; }
    if ( *cptr == '\0' ) { break; }
    if ( *cptr == '#' ) { comment++; continue; }
    lno++;
    sscanf(line,"%d\t%d\n", &from, &to);
    if ( from == prev_from ) { skip++; continue; }
    fprintf(ofp,"%d,%d\n", from, to);
    prev_from = from;
  }
  fprintf(stderr, "lno,comment,skip = %d, %d, %d \n",  lno, comment, skip);
BYE:
  fclose_if_non_null(ifp);
  fclose_if_non_null(ofp);
  return status;
}
