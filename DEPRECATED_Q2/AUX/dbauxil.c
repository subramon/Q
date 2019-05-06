#include <stdio.h>
#include <string.h>
#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "mmap.h"
#include "dbauxil.h"

// START FUNC DECL
int get_fld_sz(
    const char *fldtype,
    FLD_TYPE *ptr_fldtype,
    int *ptr_len
    )
// STOP  FUNC DECL
{
  int status = 0;
  bye_if_null(fldtype);
  *ptr_fldtype = *ptr_len = -1;
  if ( strcmp(fldtype, "I1") == 0 ) { 
    *ptr_len = 1; *ptr_fldtype = I1; return status; 
  }
  if ( strcmp(fldtype, "I2") == 0 ) { 
    *ptr_len = 2; *ptr_fldtype = I2; return status; 
  }
  if ( strcmp(fldtype, "I4") == 0 ) { 
    *ptr_len = 4; *ptr_fldtype = I4; return status; 
  }
  if ( strcmp(fldtype, "I8") == 0 ) { 
    *ptr_len = 8; *ptr_fldtype = I8; return status; 
  }
  if ( strcmp(fldtype, "F4") == 0 ) { 
    *ptr_len = 4; *ptr_fldtype = F4; return status; 
  }
  if ( strcmp(fldtype, "F8") == 0 ) { 
    *ptr_len = 8; *ptr_fldtype = F8; return status; 
  }
  if ( strcmp(fldtype, "SC") == 0 ) { 
    *ptr_len = -1; *ptr_fldtype = SC; return status; 
  }
  if ( strcmp(fldtype, "SV") == 0 ) { 
    *ptr_len = -1; *ptr_fldtype = SV; return status; 
  }
  go_BYE(-1);
BYE:
  return status;

}
//<hdr>
int
get_nn_data(
    const char *fld, 
    int has_null_fld,
    char **ptr_nn_X, 
    size_t *ptr_nn_nX
    )
//</hdr>
{
  int status = 0;
  char *nn_X = NULL; size_t nn_nX = 0;
  char *nn_fld = NULL;

  if ( has_null_fld == 1 ) { 
    int len = strlen(fld);
    nn_fld = malloc(len + strlen(".nn.") + 1);
    strcpy(nn_fld, ".nn.");
    strcat(nn_fld, fld);
    status = rs_mmap(nn_fld, &nn_X, &nn_nX, 0); cBYE(status);

  }
BYE:
  *ptr_nn_X  = nn_X;
  *ptr_nn_nX = nn_nX;
  free_if_non_null(nn_fld);
  return status;
}

//<hdr>
int
get_aux_data(
    const char *fld, 
    const char *str_fldtype,
    const char *auxtype,
    char **ptr_aux_X, 
    size_t *ptr_aux_nX
    )
//</hdr>
{
  int status = 0;
  char *aux_X = NULL; size_t aux_nX = 0;
  char *aux_fld = NULL;

  *ptr_aux_X = NULL;
  if ( strcmp(str_fldtype, "SV") != 0 ) { return status; }
  if ( ( strcmp(auxtype, "len") != 0 ) && 
    ( strcmp(auxtype, "off") != 0 ) ) {
    go_BYE(-1);
  }

  int len = strlen(fld);
  aux_fld = malloc(len + 1 + strlen(auxtype) + 1 + 1);
  strcpy(aux_fld, ".");
  strcat(aux_fld, auxtype);
  strcat(aux_fld, ".");
  strcat(aux_fld, fld);
  status = rs_mmap(aux_fld, &aux_X, &aux_nX, 0); cBYE(status);

BYE:
  *ptr_aux_X  = aux_X;
  *ptr_aux_nX = aux_nX;
  free_if_non_null(aux_fld);
  return status;
}

