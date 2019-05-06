#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include "load_csv_fast.h"
#include "_get_file_size.h"
#include "q_incs.h"
#include "_mmap.h"

#define MAX_NUM_COLS 2048
// _f1024 is 6 chars and then one space for null char
#define MAX_LEN_FILE_NAME 32
int
main(
  int argc,
  char **argv
    ) 
{
  int status = 0;
  char infile[256];
  char *fldtypes[MAX_NUM_COLS];
  char **out_files = NULL;
  char **nil_files = NULL;
  int sz_str_for_lua = 0;
  char *str_for_lua = NULL;
  uint32_t nC;
  uint64_t nR = 0;
  bool is_hdr = false;
  bool has_nulls[MAX_NUM_COLS];
  int field_width[MAX_NUM_COLS];
  bool is_load[MAX_NUM_COLS];
  uint64_t num_nulls[MAX_NUM_COLS];
 
  if ( argc == 2 ) {
    sz_str_for_lua = atoi(argv[1]);
  }
  if ( sz_str_for_lua > 0 ) { 
    str_for_lua = malloc(sz_str_for_lua);
    return_if_malloc_failed(str_for_lua);
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = NULL;
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    fldtypes[i]  = malloc(4 * sizeof(char));
  }

  // We iterate over 5 data sets 
  for ( int data_set_id = 0; data_set_id < 7; data_set_id++ ) {
    for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
      memset(fldtypes[i],'\0', 4);
    }
    int j;
    memset(infile, '\0', MAX_LEN_FILE_NAME);
    switch ( data_set_id ) {
      case 0 : 
        is_hdr = false;
        nC = 1024;
        strcpy(infile, "./mnist/train_data.csv");

        j = 0;
        for ( uint32_t i = 0; i < nC; i++ ) {
          switch ( j ) { 
            case 0 : strcpy(fldtypes[i], "I2"); break;
            case 1 : strcpy(fldtypes[i], "I2"); break;
            case 2 : strcpy(fldtypes[i], "I2"); break;
            case 3 : strcpy(fldtypes[i], "I2"); break;
            case 4 : strcpy(fldtypes[i], "I2"); break;
            default : go_BYE(-1); break;
          }
          j++; if ( j == 5 ) { j = 0; }
        }

        j = 0;
        for ( uint32_t i = 0; i < nC; i++ ) {
          switch ( j ) { 
            case 0 : is_load[i] = true; has_nulls[i] = true; break;
            case 1 : is_load[i] = true; has_nulls[i] = false; break;
            case 2 : is_load[i] = false; has_nulls[i] = true; break;
            case 3 : is_load[i] = false; has_nulls[i] = false; break;
            default : go_BYE(-1); break;
          }
          j++; if ( j == 4 ) { j = 0; } 
        }
        break;
      case 1 : 
        is_hdr = true;
        nC = 4;
        strcpy(infile, "small_with_header.csv");
        strcpy(fldtypes[0], "I8");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "I1");
        strcpy(fldtypes[3], "B1");

        field_width[0] = 8;
        field_width[1] = 4;
        field_width[2] = 1;
        field_width[3] = 0; // this  is special case of B1

        is_load[0] = true;
        is_load[1] = true;
        is_load[2] = true;
        is_load[3] = true;

        has_nulls[0] = false;
        has_nulls[1] = false;
        has_nulls[2] = false;
        has_nulls[3] = false;
        break;
      case 2 : 
        is_hdr = true;
        nC = 3;
        strcpy(infile, "small_with_header_and_nils.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "I4");

        is_load[0] = true;
        is_load[1] = true;
        is_load[2] = false;

        has_nulls[0] = true;
        has_nulls[1] = true;
        has_nulls[2] = false;
        break;
      case 3 : 
        is_hdr = true;
        nC = 5;
        strcpy(infile, "iris_with_nils.csv");
        strcpy(fldtypes[0], "I4");
        strcpy(fldtypes[1], "F4");
        strcpy(fldtypes[2], "F4");
        strcpy(fldtypes[3], "F4");
        strcpy(fldtypes[4], "F4");

        is_load[0] = false;
        is_load[1] = true;
        is_load[2] = true;
        is_load[3] = true;
        is_load[4] = true;

        has_nulls[0] = false;
        has_nulls[1] = false;
        has_nulls[2] = true; 
        has_nulls[3] = false;
        has_nulls[4] = true;

        break;
      case 4 : 
        is_hdr = false;
        nC = 2;
        strcpy(infile, "I1_I2_input.csv");
        strcpy(fldtypes[0], "I1");
        strcpy(fldtypes[1], "I2");

        is_load[0] = true;
        is_load[1] = true;

        has_nulls[0] = true;
        has_nulls[1] = true;
                
        break;
         
      case 5 : 
        is_hdr = false;
        nC = 1;
        strcpy(infile, "I1_input.csv");
        strcpy(fldtypes[0], "I1");

        is_load[0] = true;

        has_nulls[0] = false;
        
        break;
        
      case 6 : 
        is_hdr = false;
        nC = 1;
        strcpy(infile, "I2_input_with_nils.csv");
        strcpy(fldtypes[0], "I2");

        is_load[0] = true;

        has_nulls[0] = true;
        
        break;
        
      default : 
        nC = 0;
        go_BYE(-1);
        break;
    }
    status = load_csv_fast("/tmp/", infile, nC, &nR, fldtypes, 
        is_hdr, is_load, has_nulls, num_nulls, &out_files, &nil_files,
        str_for_lua, sz_str_for_lua);
    cBYE(status);
    // POST CHECKS : TODO Do more testing in all cases below
    // I have done a few checks
    switch ( data_set_id ) {
      case 0 : 
        if ( sz_str_for_lua > 0 ) { 
        }
        else {
          /* Verify that there are no nil files */
          for ( uint32_t i = 0; i < nC; i++ ) {
            if ( nil_files[i] != NULL ) { go_BYE(-1); }
          }
        }
        break;
      case 1 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          if ( nR != 6 ) { go_BYE(-1); }
          /* Verify that there are no nil files */
          for ( uint32_t i = 0; i < nC; i++ ) {
            int64_t fsz = get_file_size(out_files[i]);
            if ( fsz < 0 ) { go_BYE(-1); }
            if ( strcmp(fldtypes[i], "B1") == 0 ) { 
              if ( fsz != 8 ) { go_BYE(-1); }
            }
            else {
              if ( (uint64_t)fsz != field_width[i] * nR ) { 
                go_BYE(-1); }
            }
          }
          for ( uint32_t i = 0; i < nC; i++ ) {
            if ( nil_files[i] != NULL ) { go_BYE(-1); }
          }
        }
        break;
      case 2 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
        // TODO do some testing
        }
        break;
      case 3 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          for ( uint32_t i = 0; i < nC; i++ ) {
            // nil file should exist for col 2, 4
            if ( (i == 2 ) || (i == 4) ) { 
              char *X = NULL; size_t nX = 0;
              if ( nil_files[i] == NULL ) { go_BYE(-1); }
              status = rs_mmap(nil_files[i], &X, &nX, 0); cBYE(status);
              if ( ( X == NULL ) || ( nX == 0 ) ) { go_BYE(-1); }
              mcr_rs_munmap(X, nX);
            }
            else {
              if ( nil_files[i] != NULL ) { go_BYE(-1); }
            }
          }
        }
        break;
      case 4 : 
        if ( sz_str_for_lua > 0 ) { 
          fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          for ( uint32_t i = 0; i < nC; i++ ) {
            FILE *fp = NULL;
            if ( ( nil_files != NULL ) && ( nil_files[i] != NULL ) ) {
              fp = fopen(nil_files[i], "r");
              if ( fp != NULL ) { go_BYE(-1); }
              fclose_if_non_null(fp);
            }
          }
        }
        break;
      case 5:
        if ( sz_str_for_lua > 0 ) { 
            fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          for ( uint32_t i = 0; i < nC; i++ ) {
            FILE *fp = NULL;
            if ( ( nil_files != NULL ) && ( nil_files[i] != NULL ) ) {
              fp = fopen(nil_files[i], "r");
              if ( fp != NULL ) { go_BYE(-1); }
              fclose_if_non_null(fp);
            }
          }
          
          char *X = NULL; size_t nX = 0; 
          // checking for valid nR count
          if (nR != 1024) { go_BYE(-1); }
            
          int outfiles_size[1];
            
          //checking bin out_files are present
          for ( uint32_t i = 0; i < nC; i++ ) {
            FILE *fp = NULL;
            fp = fopen(out_files[i], "r");
            if ( fp == NULL ) { go_BYE(-1); }
            fclose_if_non_null(fp);
            // to get out_file size
            status = rs_mmap(out_files[i], &X, &nX, false);
            if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
            outfiles_size[i] = nX;
                
            //checking the out_file bin values
            if ( strcmp(fldtypes[i], "I1") == 0 ) {
              int8_t *new_buf = (int8_t *) X;
              for ( uint32_t jj = 0; jj < nR; jj++ ) {
                int expected_value = (jj+1) *15 % 127;
                if (new_buf[jj] != expected_value)
                {
                  go_BYE(-1);
                }
              }
            }
            else {
              printf("Not Matched\n");
            }
          }
              
          //checking out_file bin size is valid
          int col_field_size[] = { 1 };
          for( uint32_t itr = 0; itr < nC; itr++)
          {
            int expected_filesize = nR * col_field_size[itr];
            //printf("\nfile size%d %d\n",outfiles_size[itr],expected_filesize);
            if (outfiles_size[itr] != expected_filesize ) { go_BYE(-1); }
          }
        }
        break;
        
      case 6:
        if ( sz_str_for_lua > 0 ) { 
            fprintf(stdout, "%s\n", str_for_lua);
        }
        else {
          // nil file values are checked as byte by byte
          int expected_nil_values[] = { 254, 253, 251, 247, 255, 255, 255, 255, 255 };
          char *X = NULL; //X
          size_t nX = 0; //nX
          for ( uint32_t i = 0; i < nC; i++ ) {
            FILE *fp = NULL;
            fp = fopen(nil_files[i], "r");
            if ( fp == NULL ) { go_BYE(-1); }
            fclose_if_non_null(fp);
            status = rs_mmap(nil_files[i], &X, &nX, false);
            if ( ( X == NULL ) || ( nX == 0 ) )  { go_BYE(-1); }
            if ( strcmp(fldtypes[i], "I2") == 0 ) {
              uint8_t *new_buf = (uint8_t *) X;
              for( uint32_t jj = 0; jj < (nR/8); jj++ ) {
                if (new_buf[jj] != expected_nil_values[jj] ) { go_BYE(-1); }
              }
            }
          }
        }
        break;
        
      default : 
        go_BYE(-1); 
        break;

    }
    if ( out_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        if ( !is_load[i] ) { continue; }
        if ( ( out_files[i] ) && ( out_files[i][0] != '\0' ) ) { 
          status = remove(out_files[i]); cBYE(status);
        }
        free_if_non_null(out_files[i]);
      }
    }
    if ( nil_files != NULL ) { 
      for ( uint32_t i = 0; i < nC; i++ ) {
        if ( !is_load[i] ) { continue; }
        if ( ( nil_files[i] ) && ( nil_files[i][0] != '\0' ) ) { 
          status = remove(nil_files[i]);  cBYE(status);
        }
        free_if_non_null(nil_files[i]);
      }
    }
    free_if_non_null(nil_files);
    free_if_non_null(out_files);

    fprintf(stderr, "Loaded data set %d \n", data_set_id);
  }

BYE:
  free_if_non_null(str_for_lua);
  if ( fldtypes != NULL ) { 
    for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
      free_if_non_null(fldtypes[i]);
    }
  }
  for ( uint32_t i = 0; i < MAX_NUM_COLS; i++ ) {
    free_if_non_null(fldtypes[i]);
  }
  if ( status == 0 ) { 
    fprintf(stdout, "SUCCESS\n");
  }
  else {
    fprintf(stdout, "FAILURE\n");
  }
  return status;
}
