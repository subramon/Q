#include "q_incs.h"
#include "qtypes.h"
#include "sclr_struct.h"
#include "aux_scalar.h"

int 
set_output_qtype(
    qtype_t qtype1,
    qtype_t qtype2,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;
  if ( qtype1 == I1 ) {
    if ( qtype2 == I1 ) {
      ptr_sclr->qtype = I1;
    }
    else if ( qtype2 == I2 ) {
      ptr_sclr->qtype = I2;
    }
    else if ( qtype2 == I4 ) {
      ptr_sclr->qtype = I4;
    }
    else if ( qtype2 == I8 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == F4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F8 ) {
      ptr_sclr->qtype = F8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( qtype1 == I2 ) {
    if ( qtype2 == I1 ) {
      ptr_sclr->qtype = I2;
    }
    else if ( qtype2 == I2 ) {
      ptr_sclr->qtype = I2;
    }
    else if ( qtype2 == I4 ) {
      ptr_sclr->qtype = I4;
    }
    else if ( qtype2 == I8 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == F4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F8 ) {
      ptr_sclr->qtype = F8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( qtype1 == I4 ) {
    if ( qtype2 == I1 ) {
      ptr_sclr->qtype = I4;
    }
    else if ( qtype2 == I2 ) {
      ptr_sclr->qtype = I4;
    }
    else if ( qtype2 == I4 ) {
      ptr_sclr->qtype = I4;
    }
    else if ( qtype2 == I8 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == F4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F8 ) {
      ptr_sclr->qtype = F8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( qtype1 == I8 ) {
    if ( qtype2 == I1 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == I2 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == I4 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == I8 ) {
      ptr_sclr->qtype = I8;
    }
    else if ( qtype2 == F4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F8 ) {
      ptr_sclr->qtype = F8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( qtype1 == F4 ) {
    if ( qtype2 == I1 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == I2 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == I4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == I8 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F4 ) {
      ptr_sclr->qtype = F4;
    }
    else if ( qtype2 == F8 ) {
      ptr_sclr->qtype = F8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( qtype1 == F8 ) {
    ptr_sclr->qtype = F8;
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
