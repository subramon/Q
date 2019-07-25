//START_INCLUDES
#include "q_incs.h"
//STOP_INCLUDES
#include "_set_up_qtypes.h"
// set up qtypes  -- convert from strings to enum
//START_FUNC_DECL
int set_up_qtypes(
    char **fldtypes, // [nC] input 
    uint32_t nC,
    bool *is_load, // [nC] 
    bool **ptr_is_trim, // [nC] 
    qtype_type **ptr_qtypes // [nC] output
    )
//STOP_FUNC_DECL
{
  int status = 0;
  qtype_type *qtypes = NULL;
  bool *is_trim      = NULL;

  // TODO: Why do we need is_trim?
  is_trim = malloc(nC * sizeof(bool));
  return_if_malloc_failed(is_trim);
  for ( uint32_t i = 0; i < nC; i++ ) { is_trim[i] = false; }

  qtypes = malloc(nC * sizeof(qtype_type));
  return_if_malloc_failed(qtypes);
  bool  some_load = false;
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( !is_load[i] ) {
      qtypes[i] = undef_qtype;
      continue;
    }
    some_load = true;
    if ( strcasecmp(fldtypes[i], "I1") == 0 ) {
      qtypes[i] = I1; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "I2") == 0 ) {
      qtypes[i] = I2; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "I4") == 0 ) {
      qtypes[i] = I4; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "I8") == 0 ) {
      qtypes[i] = I8; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "F4") == 0 ) {
      qtypes[i] = F4; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "F8") == 0 ) {
      qtypes[i] = F8; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "B1") == 0 ) {
      qtypes[i] = B1; is_trim[i] = true;
    }
    else if ( strcasecmp(fldtypes[i], "SC") == 0 ) {
      qtypes[i] = SC; is_trim[i] = false;
    }
    else { 
      fprintf(stderr, "Unknown fldtype [%s] \n", fldtypes[i]);
      go_BYE(-1); 
    }
  }
  if ( !some_load ) { go_BYE(-1); }
  *ptr_qtypes  = qtypes;
  *ptr_is_trim = is_trim;
BYE:
  return status;
}
