#include "q_incs.h"
#include "_mmap.h"

#define NODE_TYPE uint32_t
#define MAXLINE 65535
int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  char *infile;
  char *prefix;
  FILE *fp = NULL;
  FILE *lbfp = NULL;
  FILE *ubfp = NULL;
  FILE *connfp = NULL;
  char *buf = NULL;
  char line[MAXLINE+1];
  NODE_TYPE *lbl = NULL;
  NODE_TYPE *lb = NULL;
  NODE_TYPE *ub = NULL;
  NODE_TYPE *conn = NULL;
  char *lb_X = NULL; size_t lb_nX = 0;
  char *ub_X = NULL; size_t ub_nX = 0;
  char *conn_X = NULL; size_t conn_nX = 0;

  NODE_TYPE idx = 0;
  if ( argc != 4 ) { go_BYE(-1); }
  infile = argv[1];
  prefix = argv[2];
  buf = malloc(strlen(prefix) + 16);

  if ( strcasecmp(argv[3], "y") == 0 ) {
    sprintf(buf, "%s_lb.bin", prefix);
    lbfp = fopen(buf, "wb");
    return_if_fopen_failed(lbfp, buf, "wb");

    sprintf(buf, "%s_ub.bin", prefix);
    ubfp = fopen(buf, "wb");
    return_if_fopen_failed(ubfp, buf, "wb");

    sprintf(buf, "%s_conn.bin", prefix);
    connfp = fopen(buf, "wb");
    return_if_fopen_failed(connfp, buf, "wb");


    fp = fopen(infile, "r");
    return_if_fopen_failed(fp, infile, "r");
    int lno = 0;
    for ( ; !feof(fp); lno++ ) {
      memset(line, '\0', MAXLINE+1);
      char *cptr = fgets(line, MAXLINE, fp);
      if ( line[MAXLINE-1] != '\0' ) { go_BYE(-1); }
      if ( cptr == NULL ) { break; }
      if ( strlen(line) == 0 ) { break; }
      char *xptr = strtok(line, ",");
      NODE_TYPE node_id = atoll(xptr);
      fwrite(&idx, sizeof(NODE_TYPE), 1, lbfp); 
      for ( int i = 0; ; i++ ) { 
        xptr = strtok(NULL, ",");
        if ( xptr == NULL ) { break; }
        node_id = atoll(xptr);
        fwrite(&node_id, sizeof(NODE_TYPE), 1, connfp);
        idx++;
      }
      fwrite(&idx, sizeof(NODE_TYPE), 1, ubfp); 
    }
    fclose_if_non_null(fp);
    fclose_if_non_null(lbfp);
    fclose_if_non_null(ubfp);
    fprintf(stderr, "Read %d lines \n", lno);
  }

  sprintf(buf, "%s_lb.bin", prefix);
  status = rs_mmap(buf, &lb_X, &lb_nX, 0); cBYE(status);

  sprintf(buf, "%s_ub.bin", prefix);
  status = rs_mmap(buf, &ub_X, &ub_nX, 0); cBYE(status);

  sprintf(buf, "%s_conn.bin", prefix);
  status = rs_mmap(buf, &conn_X, &conn_nX, 0); cBYE(status);

  uint64_t n = lb_nX / sizeof(NODE_TYPE);  
  fprintf(stderr, "Working on  %ld nodes \n", n);

  lbl = malloc(n * sizeof(NODE_TYPE));
  return_if_malloc_failed(lbl);
  for ( unsigned int i = 0; i < n; i++ ) { 
    lbl[i] = i;
  }

  lb = (NODE_TYPE *)lb_X;
  ub = (NODE_TYPE *)ub_X;
  conn = (NODE_TYPE *)conn_X;

  int num_changed = -1; // just to get in the first tome
  for ( int iter = 0; num_changed != 0; iter++ ) { 
    num_changed = 0;
#pragma omp parallel for 
    for ( uint64_t i = 0; i < n; i++ ) {
      if ( ub[i] <= lb[i] ) { continue; }
      NODE_TYPE minval = lbl[i];
      for ( uint64_t j = lb[i]; j < ub[i]; j++ ) {
        minval = mcr_min(minval, lbl[conn[j]]);
      }
      if ( lbl[i] != minval ) { 
        num_changed++;
        lbl[i] = minval;
      }
    }
    fprintf(stderr, "Pass %d, num_changed = %d \n", iter, num_changed);
  }

BYE:
  if ( lb_X != NULL ) { munmap(lb_X, lb_nX); }
  if ( ub_X != NULL ) { munmap(ub_X, lb_nX); }
  if ( conn_X != NULL ) { munmap(conn_X, lb_nX); }
  free_if_non_null(buf);
  fclose_if_non_null(fp);
  fclose_if_non_null(lbfp);
  fclose_if_non_null(ubfp);
  fclose_if_non_null(connfp);
  return_if_malloc_failed(lbl);
  return status;
}
