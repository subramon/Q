#include "q_incs.h"
#include "q_macros.h"

#include "chnk_rs_hmap_struct.h"

#define MAIN_PGM
#include "qjit_globals.h"
#include "get_chnk_ptr.h"

char *
get_chnk_ptr(
    uint32_t x 
    )
{
  int status = 0;
  char *l2_file = NULL;

  char *data  = get_chnk_data(chnk_where_found); 
  if ( data != NULL ) { return data; }
  // try and get it from l2 mem 
  l2_file = l2_file_name(XX); 
  if ( l2)
BYE:
  free_if_non_null(l2_file);
  return status;
}
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
