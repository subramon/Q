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
    uint32_t vctr_uqid,
    uint32_t chnk_idx,
    uint16_t l2_dir_num
    )
{
  int status = 0;
  if ( vctr_uqid == 0 ) { return NULL; }
  if ( l2_dir_num == 0 ) { return NULL; }
  int len = strlen(g_data_dir_root);
  len += 4 + 8 + 8 + 8; 
  // 4 is for l2_dir_num,  8 is for vctr_uqid, 8 is for chnk_idx
  // 8 = (3 is for underscore + 1 for forward slash + 1 for nullc. + ...)

  char *file_name = malloc(len);
  return_if_malloc_failed(file_name);
  memset(file_name, 0, len);

  sprintf(file_name, "%s/", g_data_dir_root);
  len = strlen(file_name);
  if ( l2_dir_num != 0 ) { 
    //------------------------------------------------
    for ( uint32_t i = 0; i < 8*sizeof(l2_dir_num)/4; i++ ) {
      uint64_t nibble = vctr_uqid & 0xF;
      char c = hex(nibble);
      file_name[len++] = c;
      l2_dir_num = l2_dir_num >> 4;
    }
  }
  //------------------------------------------------
  for ( uint32_t i = 0; i < 8*sizeof(vctr_uqid)/4; i++ ) {
    uint64_t nibble = vctr_uqid & 0xF;
    char c = hex(nibble);
    file_name[len++] = c;
    vctr_uqid = vctr_uqid >> 4;
  }
  //------------------------------------------------
  for ( uint32_t i = 0; i < 8*sizeof(chnk_idx)/4; i++ ) {
    uint64_t nibble = chnk_idx & 0xF;
    char c = hex(nibble);
    file_name[len++] = c;
    chnk_idx = chnk_idx >> 4;
  }
BYE:
  if ( status < 0 ) { return  NULL; } else { return file_name; }
}
