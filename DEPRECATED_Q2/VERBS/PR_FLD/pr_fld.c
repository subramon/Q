#include "q_constants.h"
#include "macros.h"
#include "qtypes.h"
#include "mmap.h"
#include "auxil.h"
#include "dbauxil.h"
#include "pr_fld.h"
#include "pr_fld_I1.h"
#include "pr_fld_I2.h"
#include "pr_fld_I4.h"
#include "pr_fld_I8.h"
#include "pr_fld_F4.h"
#include "pr_fld_F8.h"
#include "nn_pr_fld_I1.h"
#include "nn_pr_fld_I2.h"
#include "nn_pr_fld_I4.h"
#include "nn_pr_fld_I8.h"
#include "nn_pr_fld_F4.h"
#include "nn_pr_fld_F8.h"
#include "pr_fld_SC.h"
#include "pr_fld_SV.h"

static void zero_pr_info(
    PR_FLD_ARGS_TYPE *ptr_pr_info
    )
{
  ptr_pr_info->lb      = LLONG_MAX;
  ptr_pr_info->ub      = LLONG_MIN;
  ptr_pr_info->nn_X    = NULL;
  ptr_pr_info->cfld_X  = NULL;
  ptr_pr_info->fldlen = 0;
  ptr_pr_info->len_X    = NULL;
  ptr_pr_info->off_X   = NULL;
} 

typedef int (*fp)(
    const char *in_X,
    PR_FLD_ARGS_TYPE pr_info,
    FILE *ofp
    );

static int
select_func(
    FLD_TYPE fldtype,
    int has_null_fld,
    fp *ptr_func
    )
{
  int status = 0;
  fp func = NULL;
  if ( has_null_fld == 1 ) { 
    switch ( fldtype ) {
      case I1 : func = nn_pr_fld_I1; break; 
      case I2 : func = nn_pr_fld_I2; break; 
      case I4 : func = nn_pr_fld_I4; break; 
      case I8 : func = nn_pr_fld_I8; break; 
      case F4 : func = nn_pr_fld_F4; break; 
      case F8 : func = nn_pr_fld_F8; break; 
      case SC : func = pr_fld_SC; break; 
      case SV : func = pr_fld_SV; break; 
      default : go_BYE(-1); break;
    }
  }
  else {
    switch ( fldtype ) {
      case I1 : func = pr_fld_I1; break; 
      case I2 : func = pr_fld_I2; break; 
      case I4 : func = pr_fld_I4; break; 
      case I8 : func = pr_fld_I8; break; 
      case F4 : func = pr_fld_F4; break; 
      case F8 : func = pr_fld_F8; break; 
      case SC : func = pr_fld_SC; break; 
      case SV : func = pr_fld_SV; break; 
      default : go_BYE(-1); break;
    }
  }
BYE:
  *ptr_func = func;
  return status;
}
//<hdr>
int
pr_fld(
	    const char *fld,
            uint64_t    nR,
            const char *where_type,
            const char *where_fld,
            uint64_t    where_lb,
            uint64_t    where_ub,
            const char *str_fldtype,
            int         sc_fldlen,
            const char *opdir,
            const char *filename,
            int has_null_fld
	    )
//</hdr>
{
  int status = 0;
  char *X      = NULL; size_t nX      = 0;
  char *nn_X   = NULL; size_t nn_nX   = 0;
  char *len_X  = NULL; size_t len_nX  = 0;
  char *off_X  = NULL; size_t off_nX  = 0;
  char *cfld_X = NULL; size_t cfld_nX = 0;
  FILE *ofp = NULL;
  FLD_TYPE fldtype; int fldlen;
  char *nn_fld = NULL;
  fp func = NULL;
  PR_FLD_ARGS_TYPE pr_info;
  char cwd[MAX_LEN_DIR_NAME+1];

  // Remember where you started off from
  if ( getcwd(cwd, MAX_LEN_DIR_NAME) == NULL ) { go_BYE(-1); }

  status = rs_mmap(fld, &X, &nX, 0); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
  status = get_fld_sz(str_fldtype, &fldtype, &fldlen); cBYE(status);
  if ( fldtype == SC ) { fldlen = sc_fldlen; }
  status = get_nn_data(fld, has_null_fld, &nn_X, &nn_nX); cBYE(status);
  status = get_aux_data(fld, str_fldtype, "len", &len_X, &len_nX); cBYE(status);
  status = get_aux_data(fld, str_fldtype, "off", &off_X, &off_nX); cBYE(status);
  status = select_func(fldtype, has_null_fld, &func); cBYE(status);
  zero_pr_info(&pr_info);
  pr_info.lb = 0;
  pr_info.ub = nR;
  if ( ( where_type != NULL ) && ( *where_type != '\0' ) )  {
    if ( strcasecmp(where_type, "Range" ) == 0 ) { 
      if ( where_ub >= nR ) { go_BYE(-1); }
      if ( where_lb >= where_ub ) { go_BYE(-1); }
      pr_info.lb = where_lb; 
      pr_info.ub = where_ub; 
    }
    else if ( strcasecmp(where_type, "BooleanField" ) == 0 ) { 
    }
    else {
      go_BYE(-1);
    }
  }
  pr_info.nn_X = nn_X;
  pr_info.cfld_X = cfld_X;
  pr_info.fldlen = fldlen;
  pr_info.off_X = (uint64_t *)off_X;
  pr_info.len_X = (uint16_t *)len_X;
  if ( ( opdir != NULL ) && ( *opdir != '\0' ) ) {
    status = chdir(opdir); cBYE(status);
  }
  if ( ( filename == NULL ) || ( *filename == '\0' ) ) { 
    ofp = stdout;
  }
  else  {
    ofp = fopen(filename, "w"); return_if_fopen_failed(ofp, filename, "w");
  }
  status = (func)(X, pr_info, ofp); cBYE(status);
BYE:
  status = chdir(cwd); if ( status < 0 ) { WHEREAMI; }
  if ( ( filename != NULL ) && ( *filename != '\0' ) ) { 
    fclose_if_non_null(ofp);
  }
  free_if_non_null(nn_fld);
  rs_munmap(X,      nX);
  rs_munmap(nn_X,   nn_nX);
  rs_munmap(len_X,  len_nX);
  rs_munmap(off_X,  off_nX);
  rs_munmap(cfld_X, cfld_nX);
  return(status);
}
