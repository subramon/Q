#include "constants.h"
#include "ispc_types.h"

#define mcr_sqr(x) ( (x) * (x) )
export void 
eval_metrics(
    uniform uint32 in_nTL[BUFSZ],
    uniform uint32 in_nHL[BUFSZ],
    uniform uint32 nT,
    uniform uint32 nH,
    uniform double   metric[BUFSZ],
    uniform uint32 nbuf
    )
{
  int status = 0;
  uniform double n  = nT + nH;
  foreach ( i = 0 ... nbuf ) {
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
}
