#include "q_incs.h"
#include "q_macros.h"
#include "chk_data.h"
int 
chk_data(
    const char * const * const data, 
    const char * const * const nn_data, 
    uint32_t nC, 
    const bool * const has_nulls, // [nC]
    const bool * const is_load, // [nC]
    const uint32_t * const  width,  // [nC]
    uint32_t max_width
    )
{
  int status = 0;

  if ( max_width == 0 ) { go_BYE(-1); } 
  if ( max_width > 65536 ) { go_BYE(-1); } // some sanity check 
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( data     == NULL ) { go_BYE(-1); }
    if ( nn_data  == NULL ) { go_BYE(-1); }
    if (  is_load[i] ) { 
      if ( data[i] == NULL ) { go_BYE(-1); } 
    }
    else {
      if (    data[i] != NULL ) { go_BYE(-1); } 
      if ( nn_data[i] != NULL ) { go_BYE(-1); } 
    }
    if (  has_nulls[i] ) { 
      if ( nn_data[i] == NULL ) { go_BYE(-1); } 
    }
    else {
      if ( nn_data[i] != NULL ) { 
        go_BYE(-1); 
      }
    }
    if ( width[i] > max_width ) { go_BYE(-1); } 
  }
BYE:
  return status;
}
