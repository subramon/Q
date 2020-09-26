// TODO Convert to ispc 
#include "incs.h"
#include "eval_metrics.h"

#define mcr_sqr(x) ( (x) * (x) )
int
eval_metrics(
    uint32_t in_nTL[BUFSZ],
    uint32_t in_nHL[BUFSZ],
    uint32_t nT,
    uint32_t nH,
    double   metric[BUFSZ],
    uint32_t nbuf
    )
{
  int status = 0;
  if ( nbuf > BUFSZ ) { go_BYE(-1); }
  register double n  = nT + nH;
  for ( uint32_t i = 0; i < nbuf; i++ ) { 
    double nTL = in_nTL[i];
    double nHL = in_nHL[i];

    double nTR = nT - nTL;
    double nHR = nH - nHL;

    double nR  = nTR + nHR;
    double nL  = nTL + nHL;
    //--------------------
    double    xLT = mcr_sqr(nTL / nL);
    double    xLH = mcr_sqr(nHL / nL);
    double    giniL = 1.0 - xLT - xLH;
    //--------------------
    double    xRT = mcr_sqr(nTR / nR);
    double    xRH = mcr_sqr(nHR / nR);
    double    giniR = 1.0 - xRT - xRH;
    //--------------------
    double gini = (nL/n) * giniL + (nR/n) * giniR;
    //--------------------
    metric[i] = gini;
  }
BYE:
  return status;
}
