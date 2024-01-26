// Given the string representation of a cell, write it to the binary buffer
#include "q_incs.h"
#include "qtypes.h"
#include "txt_to_I1.h"
#include "txt_to_I2.h"
#include "txt_to_I4.h"
#include "txt_to_I8.h"
#include "txt_to_UI1.h"
#include "txt_to_UI2.h"
#include "txt_to_UI4.h"
#include "txt_to_UI8.h"
#include "txt_to_F4.h"
#include "txt_to_F8.h"
#include "set_bit_u64.h"
#include "asc_to_bin.h"
int
asc_to_bin(
    const char * const buf, 
    bool is_val_null,
    qtype_t qtype, 
    uint32_t width,
    uint32_t row_idx,
    char *data // pointer to data for specific column
    )
{
  int status = 0; 
  switch ( qtype ) {
    case B1:
      {
        int8_t tempI1 = 0;
        uint64_t *data_ptr = (uint64_t *)data;
        status = txt_to_I1(buf, &tempI1);  cBYE(status);
        if ( ( tempI1 < 0 ) || ( tempI1 > 1 ) )  { go_BYE(-1); }
        status = set_bit_u64(data_ptr, row_idx, tempI1); cBYE(status);
      }
      break;
    case BL:
      {
        bool *data_ptr = (bool *)data;
        bool tempBL = false;
        if ( !is_val_null ) { 
          if ( ( strcasecmp(buf, "true") == 0 ) || 
              ( strcmp(buf, "1") == 0 ) ) { 
            tempBL = true;
          }
          else {
            if ( ( strcasecmp(buf, "false") == 0 ) || 
                ( strcmp(buf, "0") == 0 ) ) { 
              tempBL = false;
            }
            else {
              fprintf(stderr, "Bad value for boolean = [%s] \n", buf);
              go_BYE(-1);
            }
          }
        }
        data_ptr[row_idx] = tempBL;
      }
      break;
    case I1:
      {
        int8_t *data_ptr = (int8_t *)data;
        int8_t tempI1 = 0;
        if ( !is_val_null ) { status = txt_to_I1(buf, &tempI1); }
        data_ptr[row_idx] = tempI1;
      }
      break;
    case I2:
      {
        int16_t *data_ptr = (int16_t *)data;
        int16_t tempI2 = 0;
        if ( !is_val_null ) { status = txt_to_I2(buf, &tempI2); }
        data_ptr[row_idx] = tempI2;
      }
      break;
    case I4:
      {
        int32_t *data_ptr = (int32_t *)data;
        int32_t tempI4 = 0;
        if ( !is_val_null ) { status = txt_to_I4(buf, &tempI4); }
        data_ptr[row_idx] = tempI4;
      }
      break;
    case I8:
      {
        int64_t *data_ptr = (int64_t *)data;
        int64_t tempI8 = 0;
        if ( !is_val_null ) { status = txt_to_I8(buf, &tempI8); }
        data_ptr[row_idx] = tempI8;
      }
      break;
    case UI1:
      {
        uint8_t *data_ptr = (uint8_t *)data;
        uint8_t tempUI1 = 0;
        if ( !is_val_null ) { status = txt_to_UI1(buf, &tempUI1); }
        data_ptr[row_idx] = tempUI1;
      }
      break;
    case UI2:
      {
        uint16_t *data_ptr = (uint16_t *)data;
        uint16_t tempUI2 = 0;
        if ( !is_val_null ) { status = txt_to_UI2(buf, &tempUI2); }
        data_ptr[row_idx] = tempUI2;
      }
      break;
    case UI4:
      {
        uint32_t *data_ptr = (uint32_t *)data;
        uint32_t tempUI4 = 0;
        if ( !is_val_null ) { status = txt_to_UI4(buf, &tempUI4); }
        data_ptr[row_idx] = tempUI4;
      }
      break;
    case UI8:
      {
        uint64_t *data_ptr = (uint64_t *)data;
        uint64_t tempUI8 = 0;
        if ( !is_val_null ) { status = txt_to_UI8(buf, &tempUI8); }
        data_ptr[row_idx] = tempUI8;
      }
      break;
    case F4:
      {
        float *data_ptr = (float *)data;
        float tempF4 = 0;
        if ( !is_val_null ) { status = txt_to_F4(buf, &tempF4); }
        data_ptr[row_idx] = tempF4;
      }
      break;
    case F8:
      {
        double *data_ptr = (double *)data;
        double tempF8 = 0;
        if ( !is_val_null ) { status = txt_to_F8(buf, &tempF8); }
        data_ptr[row_idx] = tempF8;
      }
      break;
    case SC : 
      {
        char *data_ptr = (char *)data;
        memset(data_ptr+(row_idx*width), '\0', width);
        memcpy(data_ptr+(row_idx*width), buf,  width);
      }
      break;
    default:
      fprintf(stderr, "Control should not come here\n");
      go_BYE(-1); 
      break;
  }
BYE:
  return status;
}
