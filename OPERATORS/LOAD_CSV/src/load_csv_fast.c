//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include "q_macros.h"
#include "qtypes.h"
#include "txt_to_I1.h"
#include "txt_to_I2.h"
#include "txt_to_I4.h"
#include "txt_to_I8.h"
#include "txt_to_F4.h"
#include "txt_to_F8.h"
#include "rs_mmap.h"
#include "trim.h"
#include "set_bit_u64.h"
//STOP_INCLUDES
#include "load_csv_fast.h"

/*- Note: I would have liked get_cell in a separate file but
    causes havoc with our simplistic dynamic compilation strategy
    where when we compile load_csv_fast.c, we get an undefined symbol
    error for get_cell
    */
static size_t
get_cell(
    char *X,
    size_t nX,
    size_t xidx,
    char fld_sep,
    bool is_last_col,
    char *buf,
    char *lbuf,
    size_t bufsz
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char dquote = '"'; 
  char bslash = '\\'; char eoln = '\n';
  uint32_t bufidx = 0;
  bool is_trim = true;
  //--------------------------------
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX == 0 ) { go_BYE(-1); }
  if ( xidx == nX ) { go_BYE(-1); }
  if ( buf == NULL ) { go_BYE(-1); }
  if ( lbuf == NULL ) {
    is_trim = false;
    lbuf = buf;
  }
  if ( bufsz == 0 ) { go_BYE(-1); }
  memset(lbuf, '\0', bufsz);
  memset(buf, '\0', bufsz);
  char last_char;
  bool start_dquote = false;
  if ( X[xidx] == dquote ) { // must end with dquote
    start_dquote = true;
    last_char = '"';
    xidx++;
  }
  else {
    if ( is_last_col ) { 
      last_char = eoln;
    }
    else {
      last_char = fld_sep;
    }
  }
  //----------------------------
  for ( ; ; ) { 
    if ( xidx > nX ) { go_BYE(-1); }
    if ( xidx == nX ) {
      if ( is_trim ) {
        status = trim(lbuf, buf, bufsz); cBYE(status);
      }
      return xidx;
    }
    if ( X[xidx] == last_char ) {
      xidx++; // jumo over last char;
      if ( start_dquote ) { 
        if ( xidx >= nX ) { go_BYE(-1); }
        if ( is_last_col ) { 
          if ( X[xidx] != eoln ) { go_BYE(-1); }
        }
        else {
          if ( X[xidx] != fld_sep ) { go_BYE(-1); }
        }
        xidx++;
      }
      if ( is_trim ) {
        status = trim(lbuf, buf, bufsz); cBYE(status);
      }
      return xidx;
    }
    //---------------------------------
    if ( X[xidx] == bslash ) {
      xidx++;
      if ( xidx >= nX ) { go_BYE(-1); }
      if ( bufidx >= bufsz ) { go_BYE(-1); }
      lbuf[bufidx++] = X[xidx++];
      continue;
    }
    if ( bufidx >= bufsz ) { go_BYE(-1); }
    lbuf[bufidx++] = X[xidx++];
  }
BYE:
  if ( status < 0 ) { xidx = 0; }
  return xidx;
}

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
load_csv_fast(
    const char * infile,
    uint64_t nC,
    const char *str_fld_sep,
    uint64_t chunk_size,
    uint64_t max_width,
    uint64_t *ptr_nR,
    uint64_t *ptr_file_offset,
    const int *const c_qtypes, /* [nC] */
    uint64_t in_c_nn_qtype,
    const bool * const is_trim, /* [nC] */
    bool is_hdr, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    char **data, /* [nC][chunk_size] */
    char **nn_data /* [nC][chunk_size] */
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *mmap_file = NULL; //X
  uint64_t file_size = 0; //nX
  char fld_sep;
  char *lbuf = NULL;
  char *buf = NULL;


  qtype_t c_nn_qtype = (qtype_t)in_c_nn_qtype;
  if (( c_nn_qtype <= Q0 ) || ( c_nn_qtype >= NUM_QTYPES )) { go_BYE(-1); }

  buf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(buf);
  lbuf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(lbuf);
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
        WHEREAMI; // go_BYE(-1); 
      }
    }
    if ( width[i] > max_width ) { go_BYE(-1); } 
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
  bool is_val_null;

  memset(lbuf, '\0', max_width);
  while ( true ) {
    memset(buf, '\0', max_width); // Clear buffer into which cell is read
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
        tmp_buf, max_width-1);

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
      if ( c_nn_qtype == B1 ) {
        // Note we are writing *NOT*-null. Hence, toggle is_val_null
        status = set_bit_u64(
            ((uint64_t **)nn_data)[col_ctr], row_ctr, !is_val_null); 
        cBYE(status);
      }
      else if ( c_nn_qtype == BL ) {
        ((bool **)nn_data)[col_ctr][row_ctr] = !is_val_null;
      }
      else {
        go_BYE(-1);
      }
    }
    // write data 
    switch ( c_qtypes[col_ctr] ) {
      case B1:
        {
          int8_t tempI1 = 0;
          uint64_t *data_ptr = (uint64_t *)data[col_ctr];
          status = txt_to_I1(buf, &tempI1);  cBYE(status);
          if ( ( tempI1 < 0 ) || ( tempI1 > 1 ) )  { go_BYE(-1); }
          status = set_bit_u64(data_ptr, row_ctr, tempI1); cBYE(status);
        }
        break;
      case BL:
        {
          bool *data_ptr = (bool *)data[col_ctr];
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
          data_ptr[row_ctr] = tempBL;
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
  free_if_non_null(buf); 
  free_if_non_null(lbuf); 
  mcr_rs_munmap(mmap_file, file_size);
  return status;
}
