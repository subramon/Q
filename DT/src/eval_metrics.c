// TODO Convert to ispc 
#include "incs.h"
#include "eval_metrics.h"
extern config_t g_C;

#define mcr_sqr(x) ( (x) * (x) )
int
eval_metrics(
    uint32_t *in_nTL, // [g_C.metrics_buffer_size]
    uint32_t *in_nHL, // [g_C.metrics_buffer_size]
    uint32_t nT,
    uint32_t nH,
    double   *metric, // [g_C.metrics_buffer_size]
    uint32_t nbuf
    )
{
  int status = 0;
  if ( nbuf > g_C.metrics_buffer_size ) { go_BYE(-1); }
  register double n  = nT + nH;
  for ( uint32_t i = 0; i < nbuf; i++ ) { 
    __builtin_prefetch(in_nTL+i+32); // 32 is a guess
    __builtin_prefetch(in_nHL+i+32); // 32 is a guess
    double nTL = in_nTL[i];
    double nHL = in_nHL[i];

    double nTR = nT - nTL;
    double nHR = nH - nHL;

    double nR  = nTR + nHR;
    double nL  = nTL + nHL;
    if ( ( nR == 0 ) || ( nT == 0 ) ) { 
      metric[i] = -1;
    }
    else {
      //--------------------
      double    xLT = (nTL / nL);
      xLT *= xLT;
      double    xLH = (nHL / nL);
      xLH *= xLH;
      double    giniL = 1.0 - xLT - xLH;
      //--------------------
      double    xRT = (nTR / nR);
      xRT *= xRT;
      double    xRH = (nHR / nR);
      xRH *= xRH;
      double    giniR = 1.0 - xRT - xRH;
      //--------------------
      double gini = ((nL/n) * giniL) + ((nR/n) * giniR);
      //--------------------
      metric[i] = gini;
    }
  }
BYE:
  return status;
}
