#include "q_incs.h"
#include "qtypes.h"
#include "rs_mmap.h"
#include "load_csv_par.h"
#include "load_csv_seq.h"

int
main(
void
)
{
  int status = 0;
  char *X = NULL; size_t nX = 0;
  char *Z = NULL; size_t nZ = 0;
  // START Inputs 
  const char * const data_file = "./in3.csv";
  uint32_t num_rows = 500000; // number of rows in data file excluding hdr
#define nC 5 
  const char * const str_fld_sep = "comma";
  uint32_t chunk_size = 64;
  uint32_t max_width = 64;
  int c_qtypes[nC] = { SC, I2, I8, I4, F4 };
  bool is_trim[nC] = { false, false, false, false, false };
  bool is_load[nC] = { true, true, true, true, true };
  bool has_nulls[nC] = { true, false, true, false, true };
  uint32_t width[nC] = { 32, 0, 0, 0, 0 };
  qtype_t c_nn_qtype = BL;  // TODO experiment with B1 
  const char * const lens_file = "./_in3_line_breaks.csv";
  bool is_hdr = true; // TODO experiment with is_hdr == false
  // STOP  Inputs 

  char **data = NULL; char **bak_data = NULL; 
  bool **nn_data = NULL; bool **bak_nn_data = NULL; 
  uint64_t bytes_read = 0;
  uint32_t chunk_num = 0; 
  uint32_t num_rows_this_chunk;

  data = malloc(nC * sizeof(char *));
  nn_data = malloc(nC * sizeof(bool *));

  bak_data = malloc(nC * sizeof(char *));
  memset(bak_data, 0,  nC * sizeof(char *));
  bak_nn_data = malloc(nC * sizeof(bool *));
  memset(bak_nn_data, 0,  nC * sizeof(bool *));

  data[0] = malloc(width[0] * num_rows); 
  data[1] = malloc(sizeof(int16_t) * num_rows); 
  data[2] = malloc(sizeof(int64_t) * num_rows); 
  data[3] = malloc(sizeof(int32_t) * num_rows); 
  data[4] = malloc(sizeof(float) * num_rows); 

  nn_data[0] = malloc(num_rows * sizeof(bool));
  nn_data[1] = NULL;
  nn_data[2] = malloc(num_rows * sizeof(bool));
  nn_data[3] = NULL;
  nn_data[4] = malloc(num_rows * sizeof(bool));
  for ( uint32_t i = 0; i < nC; i++ ) { 
    bak_data[i] = data[i];
    bak_nn_data[i] = nn_data[i];
  }
  // START Quick check on lengths file 
  status = rs_mmap(data_file, &Z, &nZ, 0); cBYE(status);
  status = rs_mmap(lens_file, &X, &nX, 0); cBYE(status);
  uint16_t *lens = (uint16_t *)X; 
  uint32_t n_lens = nX / sizeof(uint16_t);
  if ( ( n_lens *  sizeof(uint16_t) ) != nX ) { go_BYE(-1); }
  char *Y = Z;
  for ( uint32_t i = 0; i < n_lens; i++ ) { 
    char *cptr = Y + (lens[i] - 1); 
    if ( *cptr != '\n' ) { 
      printf("Error at Line %u\n", i); 
      go_BYE(-1); 
    } 
    Y += lens[i];
  }
  // STOP  Quick check on lengths file 

  for ( int iter = 1; iter <= 2; iter++ ) {
    uint32_t total_rows = 0;
    if ( iter == 1 ) { // testing PARALLEL LOADER
      for ( ; ; chunk_num++ ) {
        num_rows_this_chunk = 0; 
        status = load_csv_par(
            data_file,
            is_hdr,
            &bytes_read,
            nC,
            str_fld_sep,
            chunk_size,
            chunk_num,
            max_width,
            &num_rows_this_chunk, 
            c_qtypes, 
            is_trim, 
            is_load, 
            has_nulls, 
            width, 
            c_nn_qtype, 
            data, 
            nn_data, 
            lens_file
            );
        cBYE(status);
        // printf("Read %u for chunk %d \n", num_rows_this_chunk, chunk_num);
        total_rows += num_rows_this_chunk;
        if ( num_rows_this_chunk < chunk_size ) { 
          break; 
        }
        // START advance pointers to buffer for next chunk 
        data[0] += ( chunk_size * width[0]);
        data[1] += ( chunk_size * sizeof(int16_t)); 
        data[2] += ( chunk_size * sizeof(int64_t)); 
        data[3] += ( chunk_size * sizeof(int32_t)); 
        data[4] += ( chunk_size * sizeof(float)); 
        for ( uint32_t i = 0; i < nC; i++ ) { 
          if ( nn_data[i] != NULL ) { 
            nn_data[i] += ( chunk_size * sizeof(bool)); 
          }
        }
        // STOP  advance pointers to buffer for next chunk 
      }
    }
    else if ( iter == 2 ) {// testing SEQUENTIAL LOADER
      uint64_t nR = 0;
      uint64_t file_offset = 0;
      for ( uint32_t chunk_num = 0; ; chunk_num++ ) {
        status = load_csv_seq(
            data_file,
            nC,
            str_fld_sep,
            chunk_size,
            max_width,
            &nR,
            &file_offset,
            c_qtypes, 
            c_nn_qtype,
            is_trim, 
            is_hdr, 
            is_load, 
            has_nulls, 
            width, 
            data, 
            nn_data 
            );
        cBYE(status);
        // printf("Read %u for chunk %d \n", nR, chunk_num);
        total_rows += nR;
        if ( nR < chunk_size ) { 
          break; 
        }
      }
    }
    else {
      go_BYE(-1);
    }
    // START: some very rudimentary checking 
    printf("Read %u rows \n",  total_rows);
    if ( total_rows != num_rows ) { go_BYE(-1); } 
    {
      int16_t *I2ptr = (int16_t *)(bak_data[1]);
      int16_t max = SHRT_MIN;
      int16_t min = SHRT_MAX;
      for ( uint32_t i = 0; i < total_rows; i++ ) { 
        if ( I2ptr[i] > max ) { max = I2ptr[i]; }
        if ( I2ptr[i] < min ) { min = I2ptr[i]; }
        if ( I2ptr[i] > 10000 ) {
          printf("hello world\n");
        }
      }
      if ( max != 9999 ) { go_BYE(-1); }
      if ( min != 1326 ) { go_BYE(-1); }
    }
    {
      int64_t *I8ptr = (int64_t *)(bak_data[2]);
      int64_t max = 0;
      int64_t min = LONG_MAX;
      for ( uint32_t i = 0; i < total_rows; i++ ) { 
        if ( I8ptr[i] > max ) { max = I8ptr[i]; }
        if ( I8ptr[i] < min ) { min = I8ptr[i]; }
      }
      if ( max != 998400000005226 ) { go_BYE(-1); }
      if ( min !=  100000002868 ) { go_BYE(-1); }
    }
    {
      float *F4ptr = (float *)(bak_data[4]);
      float max = 0;
      float min = FLT_MAX;
      for ( uint32_t i = 0; i < total_rows; i++ ) { 
        if ( F4ptr[i] > max ) { max = F4ptr[i]; }
        if ( F4ptr[i] < min ) { min = F4ptr[i]; }
      }
      float eps = 0.01;
      if ( ( max > 1516.13+eps ) || ( max < 1516.13-eps ) ) { go_BYE(-1); }
      if ( min !=  0 ) { go_BYE(-1); }
    }
    printf("Test %d completed succesfully\n", iter);
  }
  printf("All tests completed succesfully\n");
BYE:
  free_if_non_null(data);
  free_if_non_null(nn_data);
  if ( bak_data != NULL ) { 
    for ( uint32_t i = 0; i < nC; i++ ) { 
      free_if_non_null(bak_data[i]);
    }
    free_if_non_null(bak_data);
  }
  if ( bak_nn_data != NULL ) { 
    for ( uint32_t i = 0; i < nC; i++ ) { 
      free_if_non_null(bak_nn_data[i]);
    }
    free_if_non_null(bak_nn_data);
  }
  mcr_rs_munmap(X, nX);
  mcr_rs_munmap(Z, nZ);
  return status;
}
