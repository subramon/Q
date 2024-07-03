#include "q_incs.h"
#include "q_macros.h"
#include "shard_file.h"

int
main(
    int argc,
    char **argv
    )
{
  int status = 0;
  if ( argc != 5 ) { go_BYE(-1); } 
  status = shard_file(argv[1], argv[2], atoi(argv[3]), atoi(argv[4])); 
  cBYE(status);
BYE:
  return status;
}

    
