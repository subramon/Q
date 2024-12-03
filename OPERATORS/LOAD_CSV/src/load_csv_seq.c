//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include "q_macros.h"
#include "qtypes.h"
#include "get_cell.h"
#include "rs_mmap.h"
#include "trim.h"
#include "set_bit_u64.h"
#include "get_fld_sep.h"
#include "chk_data.h"
#include "asc_to_bin.h"
//STOP_INCLUDES
#include "load_csv_seq.h"


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
load_csv_seq(
    const char * infile,
    uint32_t nC,
    const char *str_fld_sep,
    uint32_t chunk_size,
    uint32_t max_width,
    uint64_t *ptr_nR, // OUTPUT Number of rows read in this call
    uint64_t *ptr_file_offset, // INPUT and OUTPUT
    // at start of call, tells us how much of infile has been consumed
    const int *const c_qtypes, /* [nC] */
    int in_c_nn_qtype,
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
  char *X = NULL; // pointer to mmap'd file 
  uint64_t nX = 0; // size of file 
  char *lbuf = NULL;
  char *buf = NULL;


  qtype_t c_nn_qtype = (qtype_t)in_c_nn_qtype;

  //---------------------------------
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  if ( ptr_nR == NULL ) { go_BYE(-1); }
  if ( ptr_file_offset == NULL ) { go_BYE(-1); }

  // Check on input data structures
  status = chk_data(data, nn_data, nC, has_nulls, is_load, width, 
      max_width); 
  cBYE(status);
  // allocate buffers
  buf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(buf);
  lbuf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(lbuf);
  // decide on fld_sep
  char fld_sep;
  status = get_fld_sep(str_fld_sep, &fld_sep); 
  // mmap the file
  status = rs_mmap(infile, &X, &nX, false); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
  if ( *ptr_file_offset > nX ) { go_BYE(-1); }
  //----------------------------------------
  *ptr_nR = 0;
  uint64_t xidx = *ptr_file_offset; // "seek" to proper point in file
  if ( xidx >= nX ) {// nothing more to read 
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
    bool is_err = false;
    xidx = get_cell(X, nX, xidx, fld_sep, is_last_col, buf, 
        tmp_buf, max_width-1, &is_err);
    if ( is_err ) { go_BYE(-1); }
    // Deal with header line 
    //row_ctr == 0 means we are reading the first line which is the header
    if ( ( is_hdr )  && ( *ptr_file_offset == 0 ) ) {
      if ( row_ctr != 0 ) { go_BYE(-1); }
      // printf("col[%u] = %s \n", col_ctr, buf); 
      col_ctr++;
      if ( is_last_col ) {
        col_ctr = 0;
        is_hdr = false;
      }
      if ( xidx >= nX ) { break; } 
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
      if ( xidx == nX ) { break; } // check == or >= 
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
    status = asc_to_bin(buf, is_val_null, c_qtypes[col_ctr], 
        width[col_ctr], row_ctr, data[col_ctr]);
    fprintf(stderr, "row %lu, col %d, cell [%s]\n",
          row_ctr, col_ctr, buf);
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
    if ( xidx >= nX ) { // TODO P4 check == or >= 
      break; 
    } 
  }
  *ptr_nR = row_ctr;
  // Set file offset so that next call knows where to pick up from
  *ptr_file_offset  = xidx; 
BYE:
  free_if_non_null(buf); 
  free_if_non_null(lbuf); 
  mcr_rs_munmap(X, nX);
  return status;
}
