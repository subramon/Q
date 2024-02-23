#include "q_incs.h"
#include "q_macros.h"
#include "rs_mmap.h"
#include "isfile.h"
#include "hash.h"
#include "isdir.h"
#include <libgen.h>
#include "file_split.h"

#define AB_SEED_1 961748941 // large prime number
#define AB_SEED_2 982451653 // some other large primenumber
int 
file_split(
    const char * const infile,
    const char * const opdir,
    uint32_t nB, // number of subdirs in opdir
    uint32_t split_col_idx // which column to split on
    )
{
  int status = 0;
#define MAXLINE 2047
#define MAXFIELD 1023
  char line[MAXLINE+1];
  char colbuf[MAXFIELD+1];
  char *X = NULL; size_t nX = 0;
  char *subdir = NULL;
  char *bak_X = NULL; size_t bak_nX = 0;
  FILE **ofps = NULL;
  char *tmp = NULL;
  char *filename = NULL;

  if ( ( infile == NULL ) || ( *infile == '\0' ) )  { go_BYE(-1); }
  if ( !isfile(infile) ) { go_BYE(-1); }
  if ( !isdir(opdir) ) { go_BYE(-1); }
  if ( ( opdir == NULL ) || ( *opdir == '\0' ) )  { go_BYE(-1); }
  if ( nB == 0 ) { go_BYE(-1); } 
  if ( nB > 1024 ) { go_BYE(-1); } // sanity test, relax later
  subdir = malloc(strlen(opdir) + 16);
  return_if_malloc_failed(subdir);
  memset(subdir, 0, strlen(opdir) + 16);
  for ( uint32_t i = 0; i < nB; i++ ) { 
    sprintf(subdir, "%s/%d", opdir, i+1);
    if ( !isdir(subdir) ) { 
      status = mkdir(subdir, 0755); cBYE(status);
    }
  }
  // open a file in each subdir 
  ofps = malloc(nB * sizeof(FILE *));
  return_if_malloc_failed(ofps);
  memset(ofps, 0,  nB * sizeof(FILE *));
  
  tmp = strdup(infile);
  char *base_file = basename(tmp);
  int len = strlen(opdir) + strlen(base_file) + 16;
  filename = malloc(len);
  return_if_malloc_failed(filename);
  memset(filename, 0, len);
  for ( uint32_t i = 0; i < nB; i++ ) { 
    sprintf(filename, "%s/%d/%s", opdir, i+1, base_file);
    ofps[i] = fopen(filename, "w");
  }

  uint64_t level = (uint64_t)AB_SEED_1 << 32 | (uint64_t)AB_SEED_2;
  status = rs_mmap(infile, &X, &nX, 0); cBYE(status);
  bak_X = X;
  bak_nX = nX;
  int lno = 0;
  for ( ; nX > 0; lno++ ) { 
    // copy a line into buffer
    memset(line, 0, MAXLINE+1);
    bool is_eoln = false; 
    int line_len = 0;
    for ( int i = 0; i <= MAXLINE; i++ ) { 
      if ( *X == '\0' ) { go_BYE(-1); }
      // TODO P2 Must be smarter about separating lines 
      line[i] = *X;
      line_len++;
      X++; nX--; 
      if ( line[i] == '\n' ) { is_eoln = true; break; }
      if ( nX == 0 ) { break; }
    }
    if ( is_eoln == false ) { go_BYE(-1); }
    // now we have the line we are interest in 
    // TODO P2 Must be smarter about separating columns
    char fld_sep = ',';
    int lidx = 0;
    // TODO P1 Error if split_col_idx too big
    uint32_t seps_seen = 0;
    for ( seps_seen = 0; seps_seen < split_col_idx; seps_seen++ ) {
      for ( ; lidx < line_len; lidx++ ) { 
        if ( line[lidx] = fld_sep ) { 
          seps_seen++;
          break;
        }
      }
    }
    if ( split_col_idx > seps_seen ) { go_BYE(-1); } // no such col
    int bidx = 0;
    memset(colbuf, 0, MAXFIELD+1);
    for ( ; lidx < line_len; lidx++ ) { 
      if ( ( line[lidx] == '\n' ) || ( line[lidx] == fld_sep ) ) { 
        break;
      }
      colbuf[bidx++] = line[lidx];
    }

    // now we have the column we are interested in 
    uint64_t hashval = hash2(colbuf, bidx, level);
    int partition = hashval % nB;
    fwrite(line, line_len, 1, ofps[partition]);
    if ( lno == 1000 ) { break; }
  }
  printf("Processed %d lines \n", lno);
  


BYE:
  if ( ofps != NULL ) { 
    for ( uint32_t i = 0; i < nB; i++ ) { 
      fclose_if_non_null(ofps[i]);
    }
    free_if_non_null(ofps);
  }
  mcr_rs_munmap(bak_X, bak_nX);
  free_if_non_null(subdir);
  free_if_non_null(tmp);
  free_if_non_null(filename);
  return status;
}
