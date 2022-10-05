#include "q_incs.h"
#include "isby_I8_I4.h"

int
main(
    void
    )
{
  int status = 0;
  uint32_t SN = 20; 
  uint32_t DN = 10;
  uint32_t src_idx = 0, dst_idx = 0;
  int64_t SL[SN]; int32_t SV[SN];
  int64_t DL[DN]; int32_t DV[DN]; bool nn_DV[DN];

  for ( uint32_t i = 0; i < SN; i++ ) { 
    SL[i] = i+1;
    SV[i] = (i+1)*10;
  }
  for ( uint32_t i = 0; i < DN; i++ ) { 
    DL[i] = 2*(i+1);
    if ( ( i % 2 ) == 0 ) { DL[i] *= -1; } 
    nn_DV[i] = false;
    DV[i] = 0;
  }
  status = isby_I8_I4(SL, SV, SN, DL, DV, nn_DV, DN, &src_idx, &dst_idx);
  cBYE(status);
  for ( uint32_t i = 0; i < DN; i++ ) { 
    printf("i = %d, L = %" PRIi64 ", V = %4d/%s\n", i, DL[i], DV[i],
        nn_DV[i] ? "true" : "false");
  }
BYE:
  return status;
}
