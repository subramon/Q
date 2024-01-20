#include "q_incs.h"
#include "q_macros.h"
#include "chk_data.h"
int 
chk_data(
    char **data, 
    bool **nn_data, 
    uint32_t nC, 
    bool *has_nulls, // [nC]
    bool *is_load, // [nC]
    uint32_t *width,  // [nC]
    uint32_t max_width
    )
{
  int status = 0;

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
        WHEREAMI; // go_BYE(-1); 
      }
    }
    if ( width[i] > max_width ) { go_BYE(-1); } 
  }
BYE:
  return status;
}
