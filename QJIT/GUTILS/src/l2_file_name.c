// START: RAMESH
#include "q_incs.h"
#include "q_macros.h"
#include "qjit_consts.h"
extern char g_data_dir_root[Q_MAX_LEN_DIR_NAME];
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
    uint32_t vctr_uqid,
    uint32_t chnk_idx
    )
{
  int status = 0;
  if ( vctr_uqid == 0 ) { return NULL; }
  if ( g_data_dir_root == NULL ) { go_BYE(-1); }
  int len = strlen(g_data_dir_root);
  // top 8 bits of vctr_uqid and top 8 bits of chnk_idx used for directory 
  uint32_t part1 = vctr_uqid >> 24;
  uint32_t part2 = chnk_idx >> 24; 
  uint32_t dir_num;
  if ( chnk_idx == ((uint32_t)~0) ) {  // special case
    dir_num = 0;
  }
  else { 
    dir_num = (part1 << 8 ) | part2;
  }
  // bottom 20 bits of vctr_uqid and 32 bits of chnk_idx used for file
  int len1 = 8/4 + 8/4 + 8 ; // for directory  (+8 for kosuru)
  int len2 = 24/4 + 24/4 + 8 ; // for file name  (+8 for kosuru)
  len += (len1 + len2);

  char *file_name = malloc(len);
  return_if_malloc_failed(file_name);
  memset(file_name, 0, len);

  sprintf(file_name, "%s/_", g_data_dir_root);
  len = strlen(file_name);
  if ( dir_num != 0 ) { go_BYE(-1); } // TODO TO BE IMPLEMENTED 
  uint32_t mask = 0xFF000000; mask = ~mask; // to mask out top 8 bits
  vctr_uqid = vctr_uqid & mask;
  chnk_idx  = chnk_idx  & mask;
  //------------------------------------------------
  for ( uint32_t i = 0; i < 6; i++ ) {
    uint64_t nibble = vctr_uqid & 0xF;
    char c = hex(nibble);
    file_name[len++] = c;
    vctr_uqid = vctr_uqid >> 4;
  }
  file_name[len++] = '_';
  //------------------------------------------------
  for ( uint32_t i = 0; i < 6; i++ ) {
    uint64_t nibble = chnk_idx & 0xF;
    char c = hex(nibble);
    file_name[len++] = c;
    chnk_idx = chnk_idx >> 4;
  }
BYE:
  if ( status < 0 ) { return  NULL; } else { return file_name; }
}
