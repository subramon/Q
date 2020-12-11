#include "incs.h"
#include "dump_data.h"

int 
dump_data(
    float **X, /* [m][n] */
    uint32_t m,
    uint32_t n,
    uint8_t *g,
    const char * const bin_file_prefix

   )
{
  int status = 0;
  FILE *fp = NULL;
  char *file_name = NULL;
  int len = strlen(bin_file_prefix)+64;
  file_name = malloc(len);

  for ( uint32_t i = 0; i < m; i++ ) { 
    sprintf(file_name, "%s_feature_%d.bin", bin_file_prefix, i);
    fp = fopen(file_name, "wb");
    return_if_fopen_failed(fp, file_name, "wb");
    fwrite(X[i], sizeof(float), n, fp);
    fclose_if_non_null(fp);
  }
  sprintf(file_name, "%s_goal.bin", bin_file_prefix);
  fp = fopen(file_name, "wb");
  return_if_fopen_failed(fp, file_name, "wb");
  fwrite(g, sizeof(uint8_t), n, fp);
  fclose_if_non_null(fp);
BYE:
  free_if_non_null(file_name);
  return status;
}
