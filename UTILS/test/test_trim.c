#include "q_incs.h"
#include "_trim.h"

int
main()
{
  int status = 0;
  int n = 32;
  char inbuf[n];
  char outbuf[n];
  memset(inbuf, '\0', n);
  for ( int i = 0; i < 2; i++ ) { 
    inbuf[i] = ' ';
  }
  int j = 0;
  for ( int i = 2; i < 2+26; i++, j++ ) { 
    inbuf[i] = 'A' + j;
  }
  for ( int i = 2+26; i < n-1; i++ ) { 
    // Note the -1 above. That is because it needs to be null terminated
    inbuf[i] = ' ';
  }
  status = trim(inbuf, outbuf, n); cBYE(status);
  if ( strcmp(outbuf, "ABCDEFGHIJKLMNOPQRSTUVWXYZ") == 0 ) { 
    fprintf(stdout, "SUCCESS\n");
  }
  else {
    fprintf(stdout, "FAILURE\n");
  }

BYE:
  return status;
}
