//START_INCLUDES
#include "q_incs.h"
#include "_txt_to_I1.h"
#include "_txt_to_I2.h"
#include "_txt_to_I4.h"
#include "_txt_to_I8.h"
#include "_txt_to_F4.h"
#include "_txt_to_F8.h"
#include "_get_cell.h"
#include "_mmap.h"
#include "_trim.h"
#include "_set_bit_u64.h"
#include "set_up_qtypes.h"
//STOP_INCLUDES
#include "new_load_csv_fast.h"

/*Given a CSV file, this function reads a cell at a time. It then 
 * places this into buffers provided by the caller.
 */

/*Steps:
 *1) call get cell
 *2) convert cell from string to C type using _txt_to_* methods
 *3) write results to buffer of vector
 */

//START_FUNC_DECL
int
new_load_csv_fast(
    const char * const infile,
    uint32_t nC,
    char *str_fld_sep,
    uint32_t chunk_size,
    uint64_t *ptr_nR,
    uint64_t *ptr_file_offset,
    char ** fldtypes, /* [nC] */
    bool is_hdr, /* [nC] */
    bool * is_load, /* [nC] */
    bool * has_nulls, /* [nC] */
    void **data, /* [nC][chunk_size] */
    uint64_t **nn_data /* [nC][chunk_size] */
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *mmap_file = NULL; //X
  size_t file_size = 0; //nX
  qtype_type *qtypes = NULL;
  bool *is_trim = NULL; // whether to trim or not */
  uint64_t *word_B1 = NULL; // used for 64 bit integer buffer if col is B1
  char fld_sep;

  if ( strcasecmp(fld_sep, "comma") == 0 ) { 
    fld_sep = ';';
  }
  else if ( strcasecmp(fld_sep, "tab") == 0 ) { 
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

  word_B1 = malloc(nC * sizeof(uint64_t));
  for ( uint32_t i = 0; i < nC; i++ ) {
    word_B1[i] = 0;
  }
  // Check on input data structures
  for ( uint32_t i = 0; i < nC; i++ ) { 
    if ( has_nulls[i] ) {
      if ( nn_data[i] == NULL ) { go_BYE(-1); }
    }
    else {
      if ( nn_data[i] != NULL ) { go_BYE(-1); }
    }
  }
  *ptr_nR = 0;
  // set up is_trim, qtypes  -- convert from strings to enum
  status = set_up_qtypes(fldtypes, nC, is_load, &is_trim, &qtypes); 
  cBYE(status);
  // mmap the file
  status = rs_mmap(infile, &mmap_file, &file_size, false); cBYE(status);
  if ( ( mmap_file == NULL ) || ( file_size == 0 ) )  { go_BYE(-1); }
  if ( *ptr_file_offset > file_size ) { go_BYE(-1); }
  //----------------------------------------

  size_t xidx = *ptr_file_offset; // "seek" to proper point in file
  uint64_t row_ctr = 0;
  uint32_t col_ctr = 0;
  bool is_last_col;
#define BUFSZ 2047 
  // TODO P3 BUFSZ should come from max of qconsts.qtypes[*].max_txt_width
  char lbuf[BUFSZ+1];
  char buf[BUFSZ+1];
  bool is_val_null;

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

    // TODO xidx == 0 should not be an error
    // xidx == 0 => means the file is empty 
    if ( xidx == 0 ) { go_BYE(-1); } 
    if ( xidx > file_size ) { break; } // check == or >= 
    // Deal with header line 
    //row_ctr == 0 means we are reading the first line which is the header
    if ( is_hdr ) { 
      if ( row_ctr != 0 ) { go_BYE(-1); }
      col_ctr++;
      if ( is_last_col ) {
        col_ctr = 0;
        is_hdr = false;
      }
      if ( xidx == file_size ) { break; } // check == or >= 
      continue; 
    }
    // If this column is not to be loaded then continue 
    if ( !is_load[col_ctr] ) {
      col_ctr++;
      if ( col_ctr == nC ) { 
        col_ctr = 0;
        row_ctr++;
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
      status = set_bit_u64(nn_data[col_ctr], row_ctr, is_val_null); 
      cBYE(status);
    }
    // write data 
    switch ( qtypes[col_ctr] ) {
      case B1:
        {
          int8_t tempI1 = 0;
          status = txt_to_I1(buf, &tempI1);  cBYE(status);
          if ( ( tempI1 < 0 ) || ( tempI1 > 1 ) )  { go_BYE(-1); }
          status = set_bit_u64(data[col_ctr], row_ctr, tempI1); cBYE(status);
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
        // TODO 
        break;
      default:
        go_BYE(-1); //should not come here
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
    }
    /*this check needs to be done after the file has been written to because it
     * is possible that on the last get_cell, xidx is incremented to file_size
     * or greater, but the value from that last get_cell still needs to be
     * written to file*/
    if ( xidx == file_size ) { break; } // check == or >= 
  }
  *ptr_nR = row_ctr;
  // Set file offset so that next call knows where to pick up from
  // TODO *ptr_file_offset  = XXXXX;
BYE:
  free_if_non_null(qtypes);
  mcr_rs_munmap(mmap_file, file_size);
  free_if_non_null(is_trim);
  free_if_non_null(word_B1);
  return status;
}
