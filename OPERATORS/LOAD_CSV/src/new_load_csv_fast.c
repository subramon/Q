//START_INCLUDES
#include "q_incs.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"
#include "_get_cell.h"
#include "_rs_mmap.h"
#include "_trim.h"
#include "_set_bit_u64.h"
//STOP_INCLUDES
#include "_new_load_csv_fast.h"

// I really don't like this hard coding below especially since
// bridge_C.lua needs to kept in sync with this. But it helped
// work around  some strange memory corruption
#define B1 1 
#define I1 2 
#define I2 3 
#define I4 4 
#define I8 5 
#define F4 6 
#define F8 7 
#define SC 8 
/*Given a CSV file, this function reads a cell at a time. It then 
 * places this into buffers provided by the caller.
 */

/*Steps:
 *1) call get cell
 *2) convert cell from string to C type using _txt_to_* methods
 *3) write results to buffer of vector
 */

#define BUFSZ 2047 

//START_FUNC_DECL
int
new_load_csv_fast(
    const char * const infile,
    uint32_t nC,
    char *str_fld_sep,
    uint32_t chunk_size,
    uint64_t *ptr_nR,
    uint64_t *ptr_file_offset,
    const int *const fldtypes, /* [nC] */
    const bool * const is_trim, /* [nC] */
    bool is_hdr, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const int * const width, /* [nC] */
    char **data, /* [nC][chunk_size] */
    uint64_t **nn_data /* [nC][chunk_size] */
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *mmap_file = NULL; //X
  uint64_t file_size = 0; //nX
  char fld_sep;

  if ( strcasecmp(str_fld_sep, "comma") == 0 ) { 
    fld_sep = ',';
  }
  else if ( strcasecmp(str_fld_sep, "tab") == 0 ) { 
    fld_sep = '\t';
  }
  else {
    go_BYE(-1);
  }

  //---------------------------------
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  if ( ptr_nR == NULL ) { go_BYE(-1); }
  if ( ptr_file_offset == NULL ) { go_BYE(-1); }

  // Check on input data structures
  for ( uint32_t i = 0; i < nC; i++ ) {
    if ( data     == NULL ) { go_BYE(-1); }
    if ( nn_data  == NULL ) { go_BYE(-1); }
    if (  is_load[i] ) { 
      if ( data[i] == NULL ) { go_BYE(-1); } 
    }
    else {
      if (    data[i] != NULL ) { go_BYE(-1); } 
      if ( nn_data[i] != NULL ) { go_BYE(-1); } 
    }
    if (  has_nulls[i] ) { 
      if ( nn_data[i] == NULL ) { go_BYE(-1); } 
    }
    else {
      if ( nn_data[i] != NULL ) { 
        fprintf(stderr, "hello world\n"); 
        WHEREAMI; // go_BYE(-1); 
      }
    }
    if ( width[i] > BUFSZ ) { go_BYE(-1); }
  }
  *ptr_nR = 0;
  // mmap the file
  status = rs_mmap(infile, &mmap_file, &file_size, false); cBYE(status);
  if ( ( mmap_file == NULL ) || ( file_size == 0 ) )  { go_BYE(-1); }
  if ( *ptr_file_offset > file_size ) { go_BYE(-1); }
  //----------------------------------------

  uint64_t xidx = *ptr_file_offset; // "seek" to proper point in file
  if ( xidx >= file_size ) {// nothing more to read 
    // fprintf(stderr, "Nothing more to read\n");
    goto BYE; 
  } 
  uint64_t row_ctr = 0;
  uint32_t col_ctr = 0;
  bool is_last_col;
  // TODO P3 BUFSZ should come from max of qconsts.qtypes[*].max_txt_width
  char lbuf[BUFSZ+1];
  char buf[BUFSZ+1];
  bool is_val_null;

  memset(lbuf, '\0', BUFSZ+1); 
  while ( true ) {
    memset(buf, '\0', BUFSZ+1); // Clear buffer into which cell is read
    // Decide whether this is the last column on the row. Needed by get_cell
    if ( col_ctr == nC-1 ) { 
      is_last_col = true;
    }
    else {
      is_last_col = false;
    }
    // If trimming needed, we need to send a buffer for that purpose
    char *tmp_buf = NULL;
    if ( is_trim[col_ctr] ) { tmp_buf = lbuf; }
    xidx = get_cell(mmap_file, file_size, xidx, fld_sep, is_last_col, buf, 
        tmp_buf, BUFSZ);

    // xidx == 0 => means the file is empty. 
    // This should be checked for before we come here
    if ( xidx == 0 ) { go_BYE(-1); } 
    // Deal with header line 
    //row_ctr == 0 means we are reading the first line which is the header
    if ( ( is_hdr )  && ( *ptr_file_offset == 0 ) ) { 
      if ( row_ctr != 0 ) { go_BYE(-1); }
      col_ctr++;
      if ( is_last_col ) {
        col_ctr = 0;
        is_hdr = false;
      }
      if ( xidx >= file_size ) { break; } 
      continue; 
    }
    // If this column is not to be loaded then continue 
    if ( !is_load[col_ctr] ) {
      col_ctr++;
      if ( col_ctr == nC ) { 
        col_ctr = 0;
        row_ctr++;
        if ( row_ctr == chunk_size ) { 
          // fprintf(stderr, "111: Breaking early\n");
          break;
        }
      }
      if ( xidx == file_size ) { break; } // check == or >= 
      continue;
    }

    // Deal with null value case
    if ( buf[0] == '\0' ) { // got back null value
      is_val_null = true;
      if ( !has_nulls[col_ctr] ) { 
        fprintf(stderr, "got null value when user said no null values\t");
        fprintf(stderr, "row_ctr = %" PRIu64 ", col_ctr = %d \n", 
            row_ctr, col_ctr);
        go_BYE(-1);
      }
    }
    else {
      is_val_null = false;
    }
    // write nn_data if needed
    if ( has_nulls[col_ctr] ) {
      fprintf(stderr, "DELETT HIS TODO ");
      status = set_bit_u64(nn_data[col_ctr], row_ctr, is_val_null); 
      cBYE(status);
    }
    // write data 
    switch ( fldtypes[col_ctr] ) {
      case B1:
        {
          int8_t tempI1 = 0;
          uint64_t *data_ptr = (uint64_t *)data[col_ctr];
          status = txt_to_I1(buf, &tempI1);  cBYE(status);
          if ( ( tempI1 < 0 ) || ( tempI1 > 1 ) )  { go_BYE(-1); }
          status = set_bit_u64(data_ptr, row_ctr, tempI1); cBYE(status);
        }
        break;
      case I1:
        {
          int8_t *data_ptr = (int8_t *)data[col_ctr];
          int8_t tempI1 = 0;
          if ( !is_val_null ) { status = txt_to_I1(buf, &tempI1); }
          data_ptr[row_ctr] = tempI1;
        }
        break;
      case I2:
        {
          int16_t *data_ptr = (int16_t *)data[col_ctr];
          int16_t tempI2 = 0;
          if ( !is_val_null ) { status = txt_to_I2(buf, &tempI2); }
          data_ptr[row_ctr] = tempI2;
        }
        break;
      case I4:
        {
          int32_t *data_ptr = (int32_t *)data[col_ctr];
          int32_t tempI4 = 0;
          if ( !is_val_null ) { status = txt_to_I4(buf, &tempI4); }
          data_ptr[row_ctr] = tempI4;
        }
        break;
      case I8:
        {
          int64_t *data_ptr = (int64_t *)data[col_ctr];
          int64_t tempI8 = 0;
          if ( !is_val_null ) { status = txt_to_I8(buf, &tempI8); }
          data_ptr[row_ctr] = tempI8;
        }
        break;
      case F4:
        {
          float *data_ptr = (float *)data[col_ctr];
          float tempF4 = 0;
          if ( !is_val_null ) { status = txt_to_F4(buf, &tempF4); }
          data_ptr[row_ctr] = tempF4;
        }
        break;
      case F8:
        {
          double *data_ptr = (double *)data[col_ctr];
          double tempF8 = 0;
          if ( !is_val_null ) { status = txt_to_F8(buf, &tempF8); }
          data_ptr[row_ctr] = tempF8;
        }
        break;
      case SC : 
        {
          char *data_ptr = (char *)data[col_ctr];
          memset(data_ptr+(row_ctr*width[col_ctr]), '\0', width[col_ctr]);
          memcpy(data_ptr+(row_ctr*width[col_ctr]), buf,  width[col_ctr]);
          /*
          
          char *cptr = buf; int ii = row_ctr*width[col_ctr];;
          for ( int jj = 0 ; 
              ( ( *cptr != '\0' ) && ( jj < width[col_ctr] ) ) ; jj++ ) { 
            data[col_ctr][ii++] = *cptr++;
          }
          // printf("%s\n", buf);
          if ( (int)strlen(buf) >= width[col_ctr] ) { 
            printf("hello world\n");
            go_BYE(-1); }
          // strcpy(data_ptr+(row_ctr*width[col_ctr]), buf);
          */
        }
        break;
      default:
        fprintf(stderr, "Control should not come here\n");
        go_BYE(-1); 
        break;
    }
    //--------------------------
    if ( status < 0 ) { 
      fprintf(stderr, "Error for row %lu, col %d, cell [%s]\n",
          row_ctr, col_ctr, buf);
    }
    cBYE(status);
    col_ctr++;
    if ( col_ctr == nC ) { 
      col_ctr = 0;
      row_ctr++;
      if ( row_ctr == chunk_size ) { 
        // fprintf(stderr, "222: Breaking early\n");
        break;
      }
    }
    if ( xidx >= file_size ) { // TODO P4 check == or >= 
      break; 
    } 
  }
  *ptr_nR = row_ctr;
  // Set file offset so that next call knows where to pick up from
  *ptr_file_offset  = xidx; 
BYE:
  mcr_rs_munmap(mmap_file, file_size);
  return status;
}
