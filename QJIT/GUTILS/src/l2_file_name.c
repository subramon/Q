// START: RAMESH
#include "q_incs.h"
#include "q_macros.h"
extern char *g_data_dir_root;
#include "l2_file_name.h"

static char
hex(
    uint64_t x
   )
{
  switch ( x ) { 
    case 0 : return '0';
    case 1 : return '1';
    case 2 : return '2';
    case 3 : return '3';
    case 4 : return '4';
    case 5 : return '5';
    case 6 : return '6';
    case 7 : return '7';
    case 8 : return '8';
    case 9 : return '9';
    case 10 : return 'A';
    case 11 : return 'B';
    case 12 : return 'C';
    case 13 : return 'D';
    case 14 : return 'E';
    case 15 : return 'F';
    default : return '_';
  }
}
char *
l2_file_name(
    uint64_t uqid
    )
{
  int status = 0;
  if ( uqid == 0 ) { return NULL; }
  int len = strlen(g_data_dir_root);
  len += 16 + 4; // 4 is "kosuru", 16 is for sizeof(uint64_t)/4

  char *file_name = malloc(len);
  return_if_malloc_failed(file_name);
  memset(file_name, 0, len);
  uint64_t dir = uqid >> 16; // top 16 bits identifies directory
  uint64_t mask = (uint64_t)0xFF<< 48; // top 16 bits set to 1, bottom 48 to 0
  mask = ~mask;  // top 16 bits set to 0, bottom 48 to 1
  uint64_t file = ( uqid & mask) >> 16; // bot 48 bits identifies file

  if ( dir == 0 ) { 
    sprintf(file_name, "%s/", g_data_dir_root);
    len = strlen(file_name);
    for ( int i = 0; i < 12; i++ ) {  // 48/4 == 12
      uint64_t nibble = file & 0xF;
      char c = hex(nibble);
      file_name[len++] = c;
      file = file >> 4;
    }
  }
  else {
    // TODO 
    go_BYE(-1);
  }
BYE:
  if ( status < 0 ) { return  NULL; } else { return file_name; }
}
