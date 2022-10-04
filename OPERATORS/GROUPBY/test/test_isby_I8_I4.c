#include "q_incs.h"
#include "isby_I8_I4.h"

int
main(
    void
    )
{
  int status = 0;
  uint32_t SN = 10; 
  uint32_t DN = 5;
  uint32_t src_idx = 0, dst_idx = 0;
  int64_t SL[SN]; int32_t SV[SN];
  int64_t DL[DN]; int32_t DV[DN];

  for ( int i = 0; i < SN; i++ ) { 
    SL[i] = i+1;
    SV[i] = (i+1)*10;
  }
  for ( int i = 0; i < DN; i++ ) { 
    DL[i] = 2*(i+1);
  }
  status = isby_I8_I4(SL, SV, SN, DL, DV, DN, &src_idx, &dst_idx);
  cBYE(status);
  for ( int i = 0; i < DN; i++ ) { 
    printf("i = %d, L = %" PRIi64 ", V = %d\n", i, DL[i], DV[i]);
  }
BYE:
  return status;
}
