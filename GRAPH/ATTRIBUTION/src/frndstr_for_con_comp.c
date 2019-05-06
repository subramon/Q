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
  FILE *vfp = NULL; // nodes
  FILE *efp = NULL; // edges
  char line[MAXLINE+1];
  int lno = 0; 

  if ( argc != 4 ) { 
    fprintf(stderr, "Usage is %s <infile> <node-file> <edge-file>\n", 
        argv[0]);
    go_BYE(-1);
  }
  char *infile = argv[1];
  char *vfile  = argv[2];
  char *efile  = argv[3];
  if ( strcmp(infile, efile) == 0 ) { go_BYE(-1); }
  if ( strcmp(efile, vfile) == 0 ) { go_BYE(-1); }
  if ( strcmp(vfile, infile) == 0 ) { go_BYE(-1); }
  ifp = fopen(infile, "r"); 
  return_if_fopen_failed(ifp, infile, "r");
  vfp = fopen(vfile, "w"); 
  return_if_fopen_failed(vfp, vfile, "w");
  efp = fopen(efile, "w"); 
  return_if_fopen_failed(efp, efile, "w");
  int from, to, prev_from = -1;
  int num_nodes = 0, num_edges = 0;
  for ( ; !feof(ifp); ) { 
    memset(line, '\0', MAXLINE);
    char *cptr = fgets(line, MAXLINE, ifp);
    if ( cptr == NULL ) { break; }
    if ( *cptr == '\0' ) { break; }
    if ( *cptr == '#' ) { continue; }
    lno++;
    sscanf(line,"%d\t%d\n", &from, &to);
    if ( from != prev_from ) {
      fprintf(vfp,"%d\n", from);
      num_nodes++;
    }
    uint64_t lfrom = (uint64_t)from;
    uint64_t lto   = (uint64_t)to;
    uint64_t lfromto = (lfrom << 32 ) | lto;
    fprintf(efp,"%" PRIu64 "\n", lfromto);
    prev_from = from;
    num_edges++;
    if ( lno == 1000000 ) { break; }
  }
  fprintf(stderr, "lno,num_nodes,num_edges = %d, %d, %d \n",  
      lno, num_nodes, num_edges);
BYE:
  fclose_if_non_null(ifp);
  fclose_if_non_null(vfp);
  fclose_if_non_null(efp);
  return status;
}
