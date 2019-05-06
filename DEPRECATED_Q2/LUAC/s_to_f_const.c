#include <limits.h>
//---------------------------------------------------------------
// START FUNC DECL
int 
s_to_f_const(
       const char *tbl,
       const char *fld,
       const char *str_nR,
       const char *str_fldtype,
       const char *val,
       const char *width
       )
// STOP FUNC DECL
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  long long nR; 
  //----------------------------------------------------------------
  status = chdir(Q_DOCROOT); cBYE(status);
  status = chdir(tbl); cBYE(status);
  //--------------------------------------------------------
  // Create storage 
  status = stoI8(str_nR, &nR); cBYE(status);
  status = get_fldtype(str_fldtype, &fldtype);
  status = get_fld_sz(fldtype, &fldsz); cBYE(status); 
  size_t filesz = nR * fldsz;
  status = mk_file(fld, filesz); cBYE(status);
  status = rs_mmap(fld, &X, &nX, 1); cBYE(status);
  //--------------------------------------------------------
  status = int_s_to_f_const(X, nR, str_scalar); cBYE(status);
 BYE:
  rs_munmap(X, nX);
  return status;
}

int
int_s_to_f_const(
    char *X, 
    long long nR,
    int fldtype,
    char *str_val
    char *str_width
    )
{
  int status = 0;
  char *val = NULL;
  I1 valI1;
  I2 valI2;

  switch ( fldtype ) { 
    case I1 : 
      status = stoI1(str_val, &valI1); cBYE(status);
      status = s_to_f_const_I1(X, nR, valI1);
      break;
    case I1 : 
      status = stoI1(str_val, &valI1); cBYE(status);
      break;
    case SC : 
      status = stoI1(str_width, &maxlen); cBYE(status);
      val = malloc(maxlen+1);
      return_if_malloc_failed(val);
      for ( int i = 0; i < maxlen+1; i++ ) { val[i] = '\0'; }
      strncpy(val, str_val, len);
      break;
  }

BYE:
  return status;
}
