#define LUA_LIB

#define ALIGNMENT  256 // TODO P2 DOCUMENT AND PLACE CAREFULLY

#include <stdlib.h>
#include <malloc.h>
#include <math.h>

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "_B1_to_txt.h"
#include "_I1_to_txt.h"
#include "_I2_to_txt.h"
#include "_I4_to_txt.h"
#include "_I8_to_txt.h"
#include "_F4_to_txt.h"
#include "_F8_to_txt.h"

#include "cmem_struct.h"
#include "cmem.h"
#include "mm.h"

#define MIN_VAL 1
#define MAX_VAL 2
#define BUFLEN 2047 // TODO: Should not be hard coded. See max txt length

int luaopen_libcmem (lua_State *L);

static int 
l_cmem_print_mem( 
    lua_State *L
    ) 
{
  int status = 0;
  char buf[128];
  bool is_quiet = true;
  if ( lua_isboolean(L, 2) ) { 
    is_quiet = lua_toboolean(L, 2);
  }
  uint64_t sz1, cmem_sz;
  status = mm(0, false, false, &sz1, &cmem_sz); cBYE(status);

  if ( !is_quiet ) { 
    fprintf(stdout, "CMEM,sz_malloc,0,%" PRIu64 "\n", cmem_sz);
  }
  lua_pushnumber(L, cmem_sz);
  return 1;
BYE:
  lua_pushnil(L);
  sprintf(buf, "ERROR: Failure in %s \n", __func__);
  lua_pushstring(L, buf);
  return 2;
}

void cmem_undef( // USED FOR DEBUGGING
    CMEM_REC_TYPE *ptr_cmem
    )
{
  ptr_cmem->size = -1;
  strcpy(ptr_cmem->field_type, "XXX");
  strcpy(ptr_cmem->cell_name, "Uninitialized");
}
int cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    const char *field_type,
    const char *cell_name
    )
{
  int status = 0;
  if ( data == NULL ) { go_BYE(-1); }
  if ( size < 1 ) { go_BYE(-1); }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  if ( ( field_type != NULL ) && ( *field_type != '\0' ) ) { 
    strncpy(ptr_cmem->field_type, field_type, 4-1); // TODO Undo hard code
  }
  if ( ( cell_name != NULL ) && ( *cell_name != '\0' ) ) { 
    strncpy(ptr_cmem->cell_name, cell_name, 16-1); // TODO Undo hard code
  }
  ptr_cmem->is_foreign = true;
BYE:
  return status;
}

int cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    const char *field_type,
    const char *cell_name,
    int alignment
    )
{
  int status = 0;
  void *data = NULL;
  uint64_t sz1, sz2;
  if ( size <= 0 ) { go_BYE(-1); }
  if ( ( ( size / 16 ) * 16 ) != size ) { 
    size = ( size / 16 ) * 16 + 16;
  }
  // following is a precaution. change if necessary
  if ( alignment > 1024 ) { go_BYE(-1); }
  if ( alignment <    0 ) { go_BYE(-1); }
  if ( alignment == 0 ) {
    data = malloc(size);
  }
  else {
    data = memalign(alignment, size);
  }
  return_if_malloc_failed(data);
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  bool is_incr = true, is_vec = false;
  status = mm(ptr_cmem->size, is_incr, is_vec, &sz1, &sz2); cBYE(status);
  if ( field_type != NULL ) { 
    strncpy(ptr_cmem->field_type, field_type, 4-1); // TODO Undo hard code
  }
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, 16-1); // TODO Undo hard code
  }
  ptr_cmem->is_foreign = false;
BYE:
  return status;
}

static int l_cmem_dupe( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  char *field_type = NULL;
  char *cell_name = NULL;
  void *data = NULL;

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));

  if ( lua_islightuserdata(L, 1) ) {
    data = lua_touserdata(L, 1);
  }
  else {
    go_BYE(-1);
  }
  int64_t size =  luaL_checknumber(L, 2);
  if ( size <= 0 ) { go_BYE(-1); }

  if ( lua_gettop(L) > 3 ) { 
    if ( lua_isstring(L, 3) ) {
      field_type = (char *)luaL_checkstring(L, 3);
    }
  }
  if ( lua_gettop(L) > 4 ) { 
    if ( lua_isstring(L, 4) ) {
      cell_name = (char *)luaL_checkstring(L, 4);
    }
  }
  status = cmem_dupe(ptr_cmem, data, size, field_type, cell_name);
  cBYE(status);

  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "CMEM");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not dupe cmem\n");
  return 2;
}
static int l_cmem_new( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  char *field_type = NULL;
  char *cell_name = NULL;
  int alignment = ALIGNMENT; // default 

  int64_t size =  luaL_checknumber(L, 1);
  if ( size <= 0 ) { go_BYE(-1); }

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  // printf("cmem new  to %x \n", ptr_cmem);
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  if ( lua_gettop(L) > 2 ) {  
    if ( lua_isstring(L, 2) ) {
      field_type = (char *)luaL_checkstring(L, 2);
    }
  }
  if ( lua_gettop(L) > 3 ) { 
    if ( lua_isstring(L, 3) ) {
      cell_name = (char *)luaL_checkstring(L, 3);
    }
  }
  if ( lua_gettop(L) > 4 ) { 
    if ( lua_isnumber(L, 4) ) {
      alignment = luaL_checknumber(L, 4);
      if ( alignment < 0 ) { go_BYE(-1); }
    }
  }
  status = cmem_malloc(ptr_cmem, size, field_type, cell_name, alignment);
  cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: Could not create cmem\n");
  return 2;
}

static int l_cmem_name( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->cell_name);
  return 1;
}

static int set_default(
    CMEM_REC_TYPE *ptr_cmem,
    lua_Number val
    )
{
  int width;
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  if ( strcmp(ptr_cmem->field_type, "I1") == 0 ) {
    int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int8_t)val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I2") == 0 ) {
    int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int16_t)val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I4") == 0 ) {
    int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int32_t)val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I8") == 0 ) {
    int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int64_t)val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "F4") == 0 ) {
    float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (float)val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "F8") == 0 ) {
    double *x = (double *)(ptr_cmem->data);
    width = sizeof(double);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (double)val; }
  }
  else {
    WHEREAMI; return -1;
  }
  //---------------------------------
  if ( ( ptr_cmem->size % width ) != 0 ) { WHEREAMI; return -1; }
  return 0;
}

static int l_cmem_set_default( lua_State *L)
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_Number val = 0;
  if ( lua_isnumber(L, 2) ) {
    val    = luaL_checknumber(L, 2);
  }
  else { WHEREAMI; goto BYE; }

  int status = set_default(ptr_cmem, val);
  if ( status < 0 ) {
    goto BYE;
  }
  else {
    lua_pushboolean(L, true);
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: cmem:set_default. ");
  return 2;
}

static int cmem_set_min_max(
    CMEM_REC_TYPE *ptr_cmem,
    int mode 
    )
{
  int width;
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  if ( strcmp(ptr_cmem->field_type, "I1") == 0 ) { 
    int8_t val; int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SCHAR_MIN; } else { val = SCHAR_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I2") == 0 ) { 
    int16_t val; int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SHRT_MIN; } else { val = SHRT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I4") == 0 ) { 
    int32_t val; int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = INT_MIN; } else { val = INT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "I8") == 0 ) { 
    int64_t val; int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = LONG_MIN; } else { val = LONG_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "F4") == 0 ) { 
    float val; float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = FLT_MIN; } else { val = FLT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->field_type, "F8") == 0 ) { 
    double val; double *x = (double *)(ptr_cmem->data);
    width = sizeof(double);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = DBL_MIN ; } else { val = DBL_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else {
    WHEREAMI; return -1; 
  }
  //---------------------------------
  if ( ( ptr_cmem->size % width ) != 0 ) { WHEREAMI; return -1; }
  return 0;
}

static int l_cmem_set_max( lua_State *L)
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  int status = cmem_set_min_max(ptr_cmem, MAX_VAL);
  if ( status < 0 ) { 
    lua_pushboolean(L, true);
  }
  else {
    lua_pushboolean(L, false);
  }
  return 1;
}

static int l_cmem_set_min( lua_State *L)
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  int status = cmem_set_min_max(ptr_cmem, MIN_VAL);
  if ( status < 0 ) { 
    lua_pushboolean(L, true);
  }
  else {
    lua_pushboolean(L, false);
  }
  return 1;
}


static int cmem_zero( 
    CMEM_REC_TYPE *ptr_cmem
    )
{
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  memset(ptr_cmem->data, '\0', ptr_cmem->size);
  return 0;
}

static int l_cmem_zero( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  int status = cmem_zero(ptr_cmem);
  if ( status < 0 ) { 
    lua_pushboolean(L, true);
  }
  else {
    lua_pushboolean(L, false);
  }
  return 1;
}


static int l_cmem_fldtype( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->field_type);
  return 1;
}

static int l_cmem_data( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushlightuserdata(L, ptr_cmem->data);
  return 1;
}


static int l_cmem_size( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushnumber(L, ptr_cmem->size);
  return 1;
}

static int l_cmem_is_foreign( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushboolean(L, ptr_cmem->is_foreign);
  return 1;
}
static int l_cmem_free( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem->data == NULL ) { 
    // explicit free will cause control to come here
    if ( ( ptr_cmem->size == -1 ) && 
         ( strcmp(ptr_cmem->field_type, "XXX") == 0 ) && 
         ( strcmp(ptr_cmem->cell_name, "Uninitialized") == 0 ) ) {
      /* all is well */
    }
    else {
      go_BYE(-1); 
    }
  } 
  if ( ptr_cmem->size <= 0 ) {
    // Control should never come here except as nelow
    if ( ( ptr_cmem->size == -1 ) && 
         ( strcmp(ptr_cmem->field_type, "XXX") == 0 ) && 
         ( strcmp(ptr_cmem->cell_name, "Uninitialized") == 0 ) ) {
      /* okay */
    }
    else {
      WHEREAMI; goto BYE; 
    }
  }
  if ( !ptr_cmem->is_foreign ) { 
    // garbage collection of Lua
    if ( ( ptr_cmem->size == -1 ) && 
         ( strcmp(ptr_cmem->field_type, "XXX") == 0 ) && 
         ( strcmp(ptr_cmem->cell_name, "Uninitialized") == 0 ) ) {
      /* nothing to do */
    }
    else {
      // CONTROL SHOULD NEVER COME HERE
      if ( ptr_cmem->data == NULL ) { WHEREAMI; goto BYE; }
      free(ptr_cmem->data);
      bool is_add = false, is_vec = false;
      uint64_t sz1, sz2;
      status = mm(ptr_cmem->size, is_add, is_vec, &sz1, &sz2); cBYE(status);
    }
  }
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  // printf("Freeing %x \n", ptr_cmem);
  // OLD lua_pushboolean(L, true);
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: free failed. ");
  return 2;
}

// Following only for debugging 
static int l_cmem_seq( lua_State *L) {
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  lua_Number start  = luaL_checknumber(L, 2);
  lua_Number incr   = luaL_checknumber(L, 3);
  lua_Number num    = luaL_checknumber(L, 4);
  const char *qtype = luaL_checkstring(L, 5);
  void *X = ptr_cmem->data;
  memset(buf, '\0', BUFLEN);
  if ( strcmp(qtype, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: tostring. ");
  return 2;
}
// Following only for debugging and hence has limited usage 
static int l_cmem_set( lua_State *L) {

  CMEM_REC_TYPE *ptr_cmem  = luaL_checkudata( L, 1, "CMEM");
  lua_Number val = 0;
  char *str_val = NULL;
  // NOTE: Do NOT change order of if. Lua will claim it as string 
  // even if it is a number
  if ( strcmp(ptr_cmem->field_type, "SC") == 0 ) { 
    if ( lua_isstring(L, 2) ) {
      str_val = (char *)luaL_checkstring(L, 2);
    }
    else { WHEREAMI; goto BYE; }
  }
  else {
    if ( lua_isnumber(L, 2) ) { 
      val    = luaL_checknumber(L, 2);
    }
    else { WHEREAMI; goto BYE; }
  }
  void *X = ptr_cmem->data;
  char *field_type = ptr_cmem->field_type;
  if ( lua_gettop(L) >= 3 ) { 
    if ( lua_isstring(L, 3) ) {
      field_type = (char *)luaL_checkstring(L, 3);
      if ( strcmp(field_type,  ptr_cmem->field_type) != 0 ) {
        WHEREAMI; goto BYE;
      }
    }
  }
  if ( ( field_type == NULL ) || ( *field_type == '\0' ) ) { 
    WHEREAMI; goto BYE;
  }
  if ( strcmp(field_type, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = val;
  }
  else if ( strcmp(field_type, "SC") == 0 ) { 
    if ( str_val == NULL ) { WHEREAMI; goto BYE; }
    memset(ptr_cmem->data, '\0', ptr_cmem->size);
    if ( strlen(str_val) >= (uint64_t)ptr_cmem->size ) { 
      WHEREAMI; goto BYE; 
    }
    strcpy(ptr_cmem->data, str_val);
  }
  else {
    WHEREAMI; goto BYE;
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: cmem:set. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_to_str( lua_State *L) {
  int status = 0;
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  const char *qtype = luaL_checkstring(L, 2);
  memset(buf, '\0', BUFLEN);
  void  *X          = ptr_cmem->data;
  if ( strcmp(qtype, "B1") == 0 ) { 
    status = B1_to_txt(X, buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I1") == 0 ) { 
    status = I1_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    status = I2_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    status = I4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    status = I8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    status = F4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    status = F8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    status = F8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(qtype, "SC") == 0 ) { 
    int len = mcr_min(ptr_cmem->size, BUFLEN);
    strncpy(buf, X, len);
  }
  else {
    go_BYE(-1);
  }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: tostring. ");
  return 2;
}
// Following only for debugging 
static int l_cmem_prbuf( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  void  *X          = ptr_cmem->data;
  const char *qtype = ptr_cmem->field_type;
  int num_bytes     = ptr_cmem->size;
  int num_to_pr = 1; // default 
  if ( lua_isnumber(L, 2) ) { 
    num_to_pr  = luaL_checknumber(L, 2);
    if ( num_to_pr <= 0 ) { WHEREAMI goto BYE; }
  }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; goto BYE; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; goto BYE; }
  if ( strcmp(qtype, "I1") == 0 ) { 
    int8_t *Y = (int8_t *)X; int fldsz = sizeof(int8_t);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRI1 ":", Y[i]); }
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    int16_t *Y = (int16_t *)X; int fldsz = sizeof(int16_t);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRI2 ":", Y[i]); }
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    int32_t *Y = (int32_t *)X; int fldsz = sizeof(int32_t);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRI4 ":", Y[i]); }
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    int64_t *Y = (int64_t *)X; int fldsz = sizeof(int64_t);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRI8 ":", Y[i]); }
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    float *Y = (float *)X; int fldsz = sizeof(float);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRF4 ":", Y[i]); }
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    double *Y = (double *)X; int fldsz = sizeof(double);
    if ( num_bytes < (num_to_pr * fldsz) ) { WHEREAMI; goto BYE; }
    for ( int i = 0; i < num_to_pr; i++ ) { printf("%" PRF8 ":", Y[i]); }
  }
  else {
    WHEREAMI; goto BYE; 
  }
  fprintf(stdout, "\n");
  lua_pushboolean(L, true); return 1;
BYE:
  lua_pushboolean(L, false); return 1;
}
//----------------------------------------
static const struct luaL_Reg cmem_methods[] = {
    { "__gc",          l_cmem_free               },
    { "delete",          l_cmem_free               },
    { "set",          l_cmem_set               },
    { "seq",          l_cmem_seq               },
    { "zero",        l_cmem_zero },
    { "set_min",        l_cmem_set_min },
    { "set_max",        l_cmem_set_max },
    { "to_str",        l_cmem_to_str },
    { "prbuf",        l_cmem_prbuf },
    { "fldtype",     l_cmem_fldtype },
    { "data",     l_cmem_data },
    { "size",     l_cmem_size },
    { "is_foreign",     l_cmem_is_foreign },
    { "print_mem",     l_cmem_print_mem },
    { "dupe",     l_cmem_dupe },
    { "name",     l_cmem_name },
    { "set_default", l_cmem_set_default },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "new", l_cmem_new },
    { "to_str",        l_cmem_to_str },
    { "prbuf",        l_cmem_prbuf },
    { "zero",        l_cmem_zero },
    { "set_min",        l_cmem_set_min },
    { "set_max",        l_cmem_set_max },
    { "fldtype",     l_cmem_fldtype },
    { "data",     l_cmem_data },
    { "size",     l_cmem_size },
    { "is_foreign",     l_cmem_is_foreign },
    { "print_mem",     l_cmem_print_mem },
    { "dupe",     l_cmem_dupe },
    { "name",     l_cmem_name },
    { "set",          l_cmem_set               },
    { "seq",          l_cmem_seq               },
    { "set_default", l_cmem_set_default },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/
int luaopen_libcmem (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "CMEM");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");
  lua_pushcfunction(L, l_cmem_to_str); lua_setfield(L, -2, "__tostring");

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_register(L, NULL, cmem_methods);

  /* Register CMEM in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
  if (status != 0 ) {
    printf("Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "CMEM");
  lua_pushstring(L, "CMEM");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering type failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    printf("Running Q registration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "CMEM");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cmem_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     printf("%d\n", status);
     printf("Registering with q_export failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  
  return 1;
}
#ifdef OLD
  /* Register the object.func functions into the table that is at the
   * top of the stack. */
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, cmem_functions);

  return 1;
#endif
