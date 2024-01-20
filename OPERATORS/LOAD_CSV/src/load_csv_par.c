//START_INCLUDES
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <omp.h>
#include "q_macros.h"
#include "qtypes.h"
#include "txt_to_I1.h"
#include "txt_to_I2.h"
#include "txt_to_I4.h"
#include "txt_to_I8.h"
#include "txt_to_F4.h"
#include "txt_to_F8.h"
#include "set_bit_u64.h"
#include "rs_mmap.h"
#include "trim.h"
#include "get_fld_sep.h"
#include "get_cell.h"
#include "asc_to_bin.h"
//STOP_INCLUDES
#include "load_csv_par.h"

/* Inputs
 * 1. CSV file to be read
 * 2. Buffers into which output is written
 * 3. Line offsets
 */

// Notice that we do not have is_hdr. 
// If there is a  header, then offsets[0] != 0.
// If there is NO header, then offsets[0] == 0.
//START_FUNC_DECL
int
load_csv_par(
    const char * data_file,
    bool is_hdr,
    uint64_t *ptr_bytes_read,  // INPUT and OUTPUT 
    uint32_t nC, // number of columns
    const char *str_fld_sep,
    uint32_t chunk_size,
    uint32_t chunk_num,
    uint32_t max_width,
    uint32_t *ptr_num_rows_this_chunk, // OUTPUT 
    // when function returns, above contains number rows read in this chunk
    const int *const c_qtypes, /* [nC] */
    const bool * const is_trim, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    uint32_t c_nn_qtype, // ideally uint32_t should be qtype_t 
    char ** restrict data, /* [nC][chunk_size] */
    bool ** restrict nn_data, /* [nC][chunk_size] */
    const char * lengths_file // NEW FOR PAR 
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *X = NULL; uint64_t nX = 0; 
  char *bak_X = NULL; uint64_t bak_nX = 0; 
  char *Y = NULL; uint64_t nY = 0; 
  uint16_t *lens = NULL; uint64_t n_lens; // lens[i] == length of line i

  uint64_t bytes_read = *ptr_bytes_read; 
  // NOTE Assumption that line length <= 65535 
  // n_lens is total number of lines in data file 
  char fld_sep;
  char *lbuf = NULL; 
  char *buf = NULL; 
  uint32_t nT = 0; char **lines = NULL; // [nT][...]
  uint64_t *offsets = NULL;
  // Check on input data structures
  // TODO 
  buf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(buf);
  lbuf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(lbuf);
  // decide on fld_sep
  status = get_fld_sep(str_fld_sep, &fld_sep); cBYE(status);
  // mmap the file
  status = rs_mmap(data_file, &X, &nX, false); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
  bak_X = X; bak_nX = nX;
  X += bytes_read;
  nX -= bytes_read;
  // mmap the line lengths file
  status = rs_mmap(lengths_file, &Y, &nY, false); cBYE(status);
  if ( ( Y == NULL ) || ( nY == 0 ) ) { go_BYE(-1); }
  lens = (uint16_t *)Y;
  n_lens = nY / sizeof(uint16_t);
  if ( ( n_lens * sizeof(uint16_t) ) != nY ) { go_BYE(-1); } 
  uint64_t num_rows_total = n_lens;
  lens += (chunk_num * chunk_size);
  n_lens -= (chunk_num * chunk_size);
  // handle header if any 
  uint32_t hdr_len = 0;
  if ( is_hdr ) { 
    num_rows_total--; 
    hdr_len = lens[0];
    lens++;
    n_lens--;
    if ( chunk_num == 0 ) { 
      X += hdr_len;
      nX -= hdr_len;
    }
  }
  //-------------------------------------------
  uint64_t num_rows_read = chunk_size * chunk_num;
  uint64_t num_rows_to_read = mcr_min(chunk_size, 
      (num_rows_total - num_rows_read));
  if ( num_rows_to_read == 0 ) { goto BYE; } // Nothing more to do 
  // Find size of line to allocate (also create offsets)
  offsets = malloc(num_rows_to_read * sizeof(uint64_t));
  return_if_malloc_failed(offsets);
  uint32_t max_line_length = 0;
  offsets[0] = 0; 
  for ( uint32_t i = 0; i < num_rows_to_read; i++ ) {
    max_line_length = mcr_max(max_line_length, lens[i]);
    if ( i > 0 ) { 
      offsets[i] = offsets[i-1] + lens[i-1];
    }
  }
#ifdef DEBUG
  char *Z = X;
  for ( uint32_t i = 0; i < num_rows_to_read; i++ ) {
    char *cptr = Z + (lens[i]-1);
    if ( *cptr != '\n' ) { 
      go_BYE(-1);
    }
    Z += lens[i];
  }
#endif
  max_line_length++; // space for nullc
  // Get number of threads
  nT = omp_get_num_threads();
  // Allocate line per thread
  lines = malloc(nT * sizeof(char *));
  return_if_malloc_failed(lines);
  memset(lines, 0,  nT * sizeof(char *));
  for ( uint32_t i = 0.; i < nT; i++ ) {
    lines[i] = malloc(max_line_length);
    return_if_malloc_failed(lines[i]);
    memset(lines[i], 0,  max_line_length);
  }

// TODO  uint32_t omp_chunk_size = mcr_min(64, num_rows_to_read/nT);
// TODO #pragma omp parallel for schedule(static, omp_chunk_size)
  for ( uint32_t row_idx = 0; row_idx < num_rows_to_read; row_idx++ ) {
    int tid = omp_get_thread_num();
    // copy a line worth of data into your local buffer
    char *line = lines[tid];
    if ( offsets[row_idx] + lens[row_idx] > nX ) { go_BYE(-1); }
    bytes_read += lens[row_idx];
    memcpy(line, X+offsets[row_idx], lens[row_idx]);

    size_t lidx = 0; 
    // lidx used to track progress as we consume cells in a line 
    for ( uint32_t col_idx = 0; col_idx < nC; col_idx++ ) {
      if ( status < 0 ) { continue; }
      bool is_last_col;
      bool is_val_null;
      memset(buf, '\0', max_width); // Clear buffer into which cell is read
      // Decide if last column on the row. Needed by get_cell()
      if ( col_idx == nC-1 ) { 
        is_last_col = true;
      }
      else {
        is_last_col = false;
      }
      // If trimming needed, we need to send a buffer for that purpose
      char *tmp_buf = NULL;
      if ( is_trim[col_idx] ) { 
        memset(lbuf, '\0', max_width);
        tmp_buf = lbuf; 
      }
      // get the string value of the cell 
      lidx = get_cell(line, lens[row_idx], lidx, fld_sep, 
          is_last_col, buf, tmp_buf, max_width-1);
      // If this column is not to be loaded then continue 
      if ( !is_load[col_idx] ) {
        continue;
      }
      // Deal with null value case
      if ( buf[0] == '\0' ) { // got back null value
        is_val_null = true;
        if ( !has_nulls[col_idx] ) { 
          fprintf(stderr, "got null value when user said no null values\t");
          fprintf(stderr, "chunk # = %u, chunk sz = %u, row = %u \n",
              chunk_num, chunk_size, row_idx);
          status = -1; continue; // cannot quit out of omp loop 
        }
      }
      else {
        is_val_null = false;
      }
      // write nn_data if needed
      if ( has_nulls[col_idx] ) {
        if ( c_nn_qtype == B1 ) {
          // Note we are writing *NOT*-null. Hence, toggle is_val_null
          status = set_bit_u64(
              ((uint64_t **)nn_data)[col_idx], row_idx, !is_val_null); 
          status = -1; continue; // cannot quit out of omp loop 
        }
        else if ( c_nn_qtype == BL ) {
          ((bool **)nn_data)[col_idx][row_idx] = !is_val_null;
        }
        else {
          status = -1; continue; // cannot quit out of omp loop 
        }
      }
      // write data 
      status = asc_to_bin(buf, is_val_null, c_qtypes[col_idx], 
          width[col_idx], row_idx, data[col_idx]);
      if ( status < 0 ) { 
        fprintf(stderr, "Error for row %u, col %u, cell [%s]\n",
            row_idx, col_idx, buf);
        continue; 
      }
      printf("%u:%u:%u:%s\n", chunk_num, row_idx, col_idx, buf);
      //--------------------------
    }
  }
  cBYE(status); // in case of error
  if ( chunk_num == 0 )  {
    bytes_read += hdr_len;
  }
  *ptr_bytes_read = bytes_read; 
  *ptr_num_rows_this_chunk = num_rows_to_read;
BYE:
  if ( lines != NULL ) { 
    for ( uint32_t i = 0.; i < nT; i++ ) {
      free_if_non_null(lines[i]);
    }
    free_if_non_null(lines);
  }
  free_if_non_null(buf); 
  free_if_non_null(lbuf); 
  free_if_non_null(offsets);
  mcr_rs_munmap(bak_X, bak_nX);
  mcr_rs_munmap(Y, nY);
  return status;
}
