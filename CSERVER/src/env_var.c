#include "q_incs.h"
#include "auxil.h"
#include "env_var.h"

extern char g_q_data_dir[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_metadata_file[Q_MAX_LEN_FILE_NAME+1];
extern char g_qc_flags[Q_MAX_LEN_FLAGS+1];
extern char g_link_flags[Q_MAX_LEN_FLAGS+1];
extern char g_ld_library_path[Q_MAX_LEN_PATH+1];
extern char g_q_src_root[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_root[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_trace_dir[Q_MAX_LEN_FILE_NAME+1];
extern char g_q_build_dir[Q_MAX_LEN_FILE_NAME+1];
extern char g_lua_path[Q_MAX_LEN_PATH+1];

static int
chk_path(
    const char *const label,
    char *X,
    size_t nX
    )
{
  int status = 0;

  if ( ( label == NULL ) || ( *label == '\0' ) )  { go_BYE(-1); }
  char *cptr = getenv(label);
  if ( ( cptr == NULL ) || ( *cptr == '\0' ) ) { go_BYE(-1); }
  if ( ( strlen(cptr) > nX ) ) { go_BYE(-1); }
  strncpy(X, cptr, nX);
  for ( int i = 0; ; i++ ) {
    char *xptr;
    if ( i == 0 ) {
      xptr = strtok(cptr, ":");
    }
    else {
      xptr = strtok(NULL, ":");
    }
    if ( xptr == NULL ) { break; }
    // TODO: do we require to be too harsh on checking existance of dir and checking .so files into it?
    // check with Ramesh
    // if ( !isdir(xptr) ) { go_BYE(-1); }
    /* TODO: Should we look for certain .so files here? */
  }
BYE:
  return status;
}
//-----------------------------------------------------
static int
chk_env_dir(
    const char *const label,
    char *X,
    size_t nX
    )
{
  int status = 0;

  if ( ( label == NULL ) || ( *label == '\0' ) )  { go_BYE(-1); }
  char *cptr = getenv(label);
  if ( cptr == NULL ) { go_BYE(-1); }
  if ( strlen(cptr) > nX ) { go_BYE(-1); }
  if ( !isdir(cptr) ) { go_BYE(-1); }
  strncpy(X, cptr, nX);
  if ( !isdir(X) ) { go_BYE(-1); }
BYE:
  return status;
}
//-----------------------------------------------------
static int
chk_file_make_if_not(
    const char *const label,
    char *X,
    size_t nX,
    bool is_mandatory
    )
{
  int status = 0;
  FILE *fp = NULL;

  if ( ( label == NULL ) || ( *label == '\0' ) )  { go_BYE(-1); }
  char *cptr = getenv(label);
  if ( ( is_mandatory ) && ( cptr == NULL ) ) { go_BYE(-1); }
  if ( cptr != NULL ) {
    if ( strlen(cptr) > nX ) { go_BYE(-1); }
    strncpy(X, cptr, nX);
    fp = fopen(X, "r");
    if ( fp == NULL ) {
      fp = fopen(X, "w");
      int nw = fprintf(fp, "\n");
      if ( nw != 1 ) { go_BYE(-1); }
      fclose_if_non_null(fp);
    }
  }
BYE:
  fclose_if_non_null(fp);
  return status;
}
//-----------------------------------------------------
static int
chk_flags(
    const char *const label,
    char *X,
    size_t nX
    )
{
  int status = 0;
  if ( ( label == NULL ) || ( *label == '\0' ) ) { go_BYE(-1); }
  if ( X == NULL ) { go_BYE(-1); }
  if ( nX <= 2 ) { go_BYE(-1); }
  char *cptr = getenv(label);
  if ( cptr == NULL ) { go_BYE(-1); }
  if ( strlen(cptr) > nX ) { go_BYE(-1); }
  if ( *cptr == '\0' ) { go_BYE(-1); }
  for ( char *xptr = cptr; *xptr != '\0'; xptr++ ) {
    if ( ( isspace(*xptr) ) || ( isalnum(*xptr) )  || ( *xptr == '-' ) || ( *xptr == '=' ) ) {
      /* all is well */
    }
    else {
      go_BYE(-1);
    }
  }
  strncpy(X, cptr, nX);
BYE:
  return status;
}
  //-----------------------------------------------------
int
env_var(
    void
    )
{
  int status = 0;
  char *cptr;
  FILE *fp = NULL;

  // Q_DATA_DIR
  status = chk_env_dir("Q_DATA_DIR", g_q_data_dir, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  //-----------------------------------------------------
  // QC_FLAGS
  status = chk_flags("QC_FLAGS", g_qc_flags, Q_MAX_LEN_FLAGS);
  cBYE(status);
  //-----------------------------------------------------
  // Q_LINK_FLAGS
  status = chk_flags("Q_LINK_FLAGS", g_link_flags, Q_MAX_LEN_FLAGS);
  cBYE(status);
  //-----------------------------------------------------
  // Q_METADATA_FILE -> is not a mandatory env variable
  status = chk_file_make_if_not("Q_METADATA_FILE", g_q_metadata_file,
      Q_MAX_LEN_FILE_NAME, false);
  cBYE(status);
  //-----------------------------------------------------
  // LD_LIBRARY_PATH
  status = chk_path("LD_LIBRARY_PATH", g_ld_library_path, Q_MAX_LEN_PATH);
  cBYE(status);
  //-----------------------------------------------------
  // Q_SRC_ROOT
  status = chk_env_dir("Q_SRC_ROOT", g_q_src_root, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  //-----------------------------------------------------
  // Q_ROOT
  status = chk_env_dir("Q_ROOT", g_q_root, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  // TODO: shall we check Q_ROOT/lib, Q_ROOT/include ?
  //-----------------------------------------------------
  // Q_TRACE_DIR
  status = chk_env_dir("Q_TRACE_DIR", g_q_trace_dir, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  //-----------------------------------------------------
  // Q_BUILD_DIR
  status = chk_env_dir("Q_BUILD_DIR", g_q_trace_dir, Q_MAX_LEN_FILE_NAME);
  cBYE(status);
  //-----------------------------------------------------
  // LUA_PATH
  status = chk_path("LUA_PATH", g_lua_path, Q_MAX_LEN_PATH);
  cBYE(status);

BYE:
  fclose_if_non_null(fp);
  return status;
}
