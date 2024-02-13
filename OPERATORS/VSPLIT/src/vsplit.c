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
#include "get_fld_sep.h"
#include "asc_to_bin.h"
//STOP_INCLUDES
#include "vsplit.h"

/*Given a CSV file, this function breaks the file into separate 
 * binary files, one for each column
 */

//START_FUNC_DECL
int
vsplit(
    const char * infile,
    uint32_t nC,
    const char *str_fld_sep,
    uint32_t max_width,
    // at start of call, tells us how much of infile has been consumed
    const int *const c_qtypes, /* [nC] */
    const bool *  const is_load, /* [nC] */
    const bool * const has_nulls, /* [nC] */
    const uint32_t * const width, /* [nC] */
    const char ** const opfiles,
    const char ** const nn_opfiles
    )
//STOP_FUNC_DECL
{
  int status = 0;
  char *X = NULL; // pointer to mmap'd file 
  uint64_t nX = 0; // size of file 
  char *buf = NULL; // big enough to contain ascii representation of cell 
  char *opbuf = NULL; //big enough to contain binary representation of cell 
  FILE **ofps = NULL;
  FILE **nn_ofps = NULL;

  //-- START: Checks on inputs 
  if ( max_width < 16 ) {  max_width = 16; } // enforce minimum
  if ( ( infile == NULL ) || ( *infile == '\0' ) ) { go_BYE(-1); }
  if ( nC == 0 ) { go_BYE(-1); }
  for ( uint32_t i = 0; i < nC; i++ ) { 
    if ( width[i] == 0 ) { go_BYE(-1); } 
    if ( is_load[i] == false ) { 
      // if ( opfiles[i] != NULL ) { go_BYE(-1); } 
      // if ( nn_opfiles[i] != NULL ) { go_BYE(-1); } 
    }
    else {
      if ( opfiles[i] == NULL ) { go_BYE(-1); } 
    }
    if ( has_nulls[i] == true ) { 
      if ( is_load[i] == false ) { go_BYE(-1); }
    }
  }
  //-- STOP : Checks on inputs 
  // open files for writing 
  ofps = malloc(nC * sizeof(FILE *)); 
  memset(ofps, 0,  nC * sizeof(FILE *)); 
  nn_ofps = malloc(nC * sizeof(FILE *)); 
  memset(nn_ofps, 0,  nC * sizeof(FILE *)); 
  for ( uint32_t i = 0; i < nC; i++ ) { 
    if ( is_load[i] ) { 
      ofps[i] = fopen(opfiles[i], "ab");
      if ( has_nulls[i] ) { 
        nn_ofps[i] = fopen(nn_opfiles[i], "ab");
      }
    }
  }
  //---------------------------------------
  // allocate buffers
  buf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(buf);
  opbuf = malloc(max_width * sizeof(char));
  return_if_malloc_failed(opbuf);
  // decide on fld_sep
  char fld_sep;
  status = get_fld_sep(str_fld_sep, &fld_sep); 
  // mmap the file
  status = rs_mmap(infile, &X, &nX, false); cBYE(status);
  if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
  //----------------------------------------
  uint64_t xidx = 0; 
  uint64_t row_ctr = 0;
  uint32_t col_ctr = 0;
  bool is_last_col;
  bool is_val_null;

  while ( true ) {
    memset(buf, '\0', max_width); // Clear buffer into which cell is read
    // Decide whether this is the last column on the row. Needed by get_cell
    if ( col_ctr == nC-1 ) { 
      is_last_col = true;
    }
    else {
      is_last_col = false;
    }
    xidx = get_cell(X, nX, xidx, fld_sep, is_last_col, buf, 
        NULL, max_width-1);
    // If this column is not to be loaded then continue 
    if ( !is_load[col_ctr] ) {
      col_ctr++;
      if ( col_ctr == nC ) { 
        col_ctr = 0;
        row_ctr++;
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
      bool is_nn = !is_val_null;
      fwrite(&is_nn, sizeof(bool), 1, nn_ofps[col_ctr]);
    }
    // write data 
    status = asc_to_bin(buf, is_val_null, c_qtypes[col_ctr], 
        width[col_ctr], 0, opbuf); 
    // NOTE: Last 2 parameters in  asc_to_bin different from load_csv()
    if ( status < 0 ) { 
      fprintf(stderr, "Error for row %lu, col %d, cell [%s]\n",
          row_ctr, col_ctr, buf);
    }
    cBYE(status);
    fwrite(opbuf, width[col_ctr], 1, ofps[col_ctr]);
    col_ctr++;
    if ( col_ctr == nC ) { 
      col_ctr = 0;
      row_ctr++;
    }
    if ( xidx >= nX ) { // TODO P4 check == or >= 
      break; 
    } 
  }
  printf("Processed %" PRIu64 " rows of file %s\n", row_ctr, infile);
BYE:
  // close files 
  if ( ofps != NULL ) { 
    for ( uint32_t i = 0; i < nC; i++ ) { 
      if ( is_load[i] ) { 
        fclose_if_non_null(ofps[i]);
        if ( has_nulls[i] ) { 
          if ( nn_ofps != NULL ) { 
            fclose_if_non_null(nn_ofps[i]);
          }
        }
      }
    }
  }
  free_if_non_null(ofps);
  free_if_non_null(nn_ofps);
  //---------------------------------
  free_if_non_null(buf); 
  free_if_non_null(opbuf); 
  mcr_rs_munmap(X, nX);
  return status;
}
