#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include "q_constants.h"
#include "qtypes.h"
#include "macros.h"
#include "auxil.h"
#include "dbauxil.h"
#include "mmap.h"
#include "pr_fld.h"
#ifdef STAND_ALONE
int main()
{
  int status = 0;
  int32_t *X1 = NULL; int64_t nR1 = 20;
  char *infile1 = "_in1";
  char *infile2 = "_in2";
  uint64_t nR;
  char str_fldtype[32];
  char str_fldlen[32]; int fldlen;
  char outfile1[128];
  char outfile2[128];
  int has_null_vals;
  FILE *fp = NULL;
  char *nn_X1 = NULL; 
  char *nn_X2 = NULL; 
  char nnfile1[128];
  char nnfile2[128];
  char *X2 = NULL; int64_t nR2 = 40; char *bak_X2 = NULL;

  //----------------------------------------------------
  // START: Set up data for experiment 1 
  strcpy(outfile1, "_out11.csv");
  has_null_vals = 0;
  X1 = malloc(nR1 * sizeof(int32_t));
  return_if_malloc_failed(X1);
  for ( int i =0; i < nR1; i++ ) { 
    X1[i] = i+1;
  }
  fp = fopen(infile1, "wb");
  return_if_fopen_failed(fp, infile1, "wb");
  fwrite(X1, sizeof(int32_t), nR1, fp);
  fclose(fp); fp = NULL; 
  nR = nR1;
  strcpy(str_fldtype, "I4");
  // STOP: Set up data for experiment 1 
  status =  pr_fld( infile1, nR, str_fldtype, "",
      ".", outfile1, has_null_vals);
  cBYE(status);
  //---------------------------------------------------------
  strcpy(outfile1, "_out12.csv");
  has_null_vals = 1;
  strcpy(nnfile1, ".nn.");
  strcat(nnfile1, infile1);
  nn_X1 = malloc(nR1 * sizeof(char));
  for ( int i = 0; i < nR1; i++ ) { 
    if ( ( i % 2 ) == 0 ) { 
      nn_X1[i] = 1;
    }
    else {
      nn_X1[i] = 0;
    }
  }
  fp = fopen(nnfile1, "wb");
  return_if_fopen_failed(fp, nnfile1, "wb");
  fwrite(nn_X1, sizeof(char), nR1, fp);
  fclose(fp); fp = NULL; 

  status =  pr_fld( infile1, nR, str_fldtype, "",
      ".", outfile1, has_null_vals);
  cBYE(status);
  //---------------------------------------------------------
  fldlen = 7;
  X2 = malloc((nR2 * (fldlen+1)) * sizeof(char));
  return_if_malloc_failed(X2);
  bak_X2 = X2;
  int thislen = 1;
  for ( int i = 0; i < nR2; i++ ) {
    int j = 0;
    char c = 'a';
    for ( j = 0; j < thislen; j++ ) { 
      *X2++ = c;
      c++;
    }
    for ( ; j < fldlen+1; j++ ) { 
      *X2++ = '\0';
    }
    thislen++;
    if ( thislen > fldlen ) { thislen = 1; }
  }
  X2 = bak_X2;
  fp = fopen(infile2, "wb");
  return_if_fopen_failed(fp, infile2, "wb");
  fwrite(X2, sizeof(char), ((fldlen+1)*nR2), fp);
  fclose(fp); fp = NULL; 
  sprintf(str_fldlen, "%d", fldlen);
  nR = nR2;
  strcpy(str_fldtype, "SC");
  strcpy(outfile2, "_out21.csv");
  has_null_vals = 0;
  //------------------------------------------------------------
  status =  pr_fld( infile2, nR, str_fldtype, str_fldlen,
      ".", outfile2, has_null_vals);
  cBYE(status);
  //------------------------------------------------------------
  strcpy(outfile2, "_out22.csv");
  has_null_vals = 1;
  strcpy(nnfile2, ".nn.");
  strcat(nnfile2, infile2);
  nn_X2 = malloc(nR2 * sizeof(char));
  for ( int i = 0; i < nR2; i++ ) { 
    if ( ( i % 3 ) == 0 ) { 
      nn_X2[i] = 1;
    }
    else {
      nn_X2[i] = 0;
    }
  }
  fp = fopen(nnfile2, "wb");
  return_if_fopen_failed(fp, nnfile2, "wb");
  fwrite(nn_X2, sizeof(char), nR2, fp);
  fclose(fp); fp = NULL; 

  status =  pr_fld( infile2, nR, str_fldtype, str_fldlen,
      ".", outfile2, has_null_vals);
  cBYE(status);
  status =  pr_fld( "_out31", "9", "SV", "", ".", "_out31.csv", 1);
  cBYE(status);
BYE:
  unlink(infile1);
  fclose_if_non_null(fp);
  free_if_non_null(X1);
  free_if_non_null(X2);
  free_if_non_null(nn_X1);
  free_if_non_null(nn_X2);
  return(status);
}
#else
int g_ut_pr_fld; // NEED TO GET RID OF THIS. 
// Only reason it exists is because -pedantic does not like empty compilation unit 
#endif
