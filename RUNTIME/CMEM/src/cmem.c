#define LUA_LIB

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "B1_to_txt.h"
#include "I1_to_txt.h"
#include "I2_to_txt.h"
#include "I4_to_txt.h"
#include "I8_to_txt.h"
#include "F4_to_txt.h"
#include "F8_to_txt.h"

#include "cmem_struct.h"
#include "aux_lua_to_c.h"
#include "cmem.h"

#define CMEM_ALIGNMENT 64 
#define MIN_VAL 1
#define MAX_VAL 2
#define BUFLEN 2047 // TODO P4: Should not be hard coded. See max txt length

int luaopen_libcmem (lua_State *L);

// Sets the CMEM struct to undefined values
void cmem_undef( // USED FOR DEBUGGING
    CMEM_REC_TYPE *ptr_cmem
    )
{
  ptr_cmem->size = -1;
  strcpy(ptr_cmem->fldtype, "XXX");
  strcpy(ptr_cmem->cell_name, "Uninitialized");
  ptr_cmem->is_foreign = false;
}

int cmem_dupe( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    void *data,
    int64_t size,
    const char *fldtype,
    const char *cell_name
    )
{
  int status = 0;
  if ( data == NULL ) { go_BYE(-1); }
  if ( size < 1 ) { go_BYE(-1); }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  if ( ( fldtype != NULL ) && ( *fldtype != '\0' ) ) { 
    strncpy(ptr_cmem->fldtype, fldtype, Q_MAX_LEN_QTYPE_NAME-1); 
  }
  if ( ( cell_name != NULL ) && ( *cell_name != '\0' ) ) { 
    strncpy(ptr_cmem->cell_name, cell_name, Q_MAX_LEN_INTERNAL_NAME-1);
  }
  ptr_cmem->is_foreign = true;
BYE:
  return status;
}

int cmem_malloc( // INTERNAL NOT VISIBLE TO LUA 
    CMEM_REC_TYPE *ptr_cmem,
    int64_t size,
    const char *fldtype,
    const char *cell_name
    )
{
  int status = 0;
  void *data = NULL;
  if ( size < 0 ) { go_BYE(-1); } // we allow size == 0 
  if ( size > 0 ) { 
    // Always allocate a multiple of CMEM_ALIGNMENT
    size = (size_t)ceil((double)size / CMEM_ALIGNMENT) * CMEM_ALIGNMENT;
    status = posix_memalign(&data, CMEM_ALIGNMENT, size);
    cBYE(status);
    // TODO P4: make sure that posix_memalign is not causing any problems
    return_if_malloc_failed(data);
  }
  ptr_cmem->data = data;
  ptr_cmem->size = size;
  if ( fldtype != NULL ) { 
    strncpy(ptr_cmem->fldtype, fldtype, Q_MAX_LEN_QTYPE_NAME-1);
  }
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, Q_MAX_LEN_INTERNAL_NAME-1);
  }
  ptr_cmem->is_foreign = false;
BYE:
  return status;
}
static int l_cmem_dupe( lua_State *L)  // ONLY FOR TESTING
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  char *fldtype = NULL;
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
      fldtype = (char *)luaL_checkstring(L, 3);
    }
  }
  if ( lua_gettop(L) > 4 ) { 
    if ( lua_isstring(L, 4) ) {
      cell_name = (char *)luaL_checkstring(L, 4);
    }
  }
  status = cmem_dupe(ptr_cmem, data, size, fldtype, cell_name);
  cBYE(status);

  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "CMEM");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}
static int l_cmem_new( lua_State *L) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  bool is_key;

  const char * fldtype = NULL;   // info to be set from input 
  const char * cell_name = NULL; // info to be set from input 
  int64_t size;           // info to be set from input 
  
  //-- get info from input 
  int num_on_stack = lua_gettop(L);
  if ( num_on_stack != 1 ) { go_BYE(-1); }
  if ( lua_isnumber(L, 1 ) ) { 
    size =  luaL_checknumber(L, 1);
  }
  else {
    if ( !lua_istable(L, 1) ) { go_BYE(-1); }
    status = get_int_from_tbl(L, "size", &is_key, &size); cBYE(status);
    if ( !is_key ) { go_BYE(-1); }
    status = get_str_from_tbl(L, "qtype", &is_key, &fldtype); cBYE(status);
    status = get_str_from_tbl(L, "name", &is_key, &cell_name); cBYE(status);
  }
  // Note we allow size == 0 for dummy CMEM so that we do not 
  if ( size < 0 ) { go_BYE(-1); }

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  status = cmem_malloc(ptr_cmem, size, fldtype, cell_name);
  cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

static int l_cmem_name( lua_State *L) {
  int status = 0;
  int num_args = lua_gettop(L);
  if ( num_args != 1 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->cell_name);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}


// set_default used only for debugging. 
// TODO P4 Consider using it elsewhere as well
static int set_default(
    CMEM_REC_TYPE *ptr_cmem,
    lua_Number val
    )
{
  int width;
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  if ( strcmp(ptr_cmem->fldtype, "I1") == 0 ) {
    int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int8_t)val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I2") == 0 ) {
    int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int16_t)val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I4") == 0 ) {
    int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int32_t)val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I8") == 0 ) {
    int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int64_t)val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "F4") == 0 ) {
    float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (float)val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "F8") == 0 ) {
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

static int l_cmem_nop( lua_State *L) // just for debugging 
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem == NULL ) {  // to stop gcc from complaining
    lua_pushnil(L);
    return 1;
  }
  lua_pushboolean(L, true);
  return 1;
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
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
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
  if ( strcmp(ptr_cmem->fldtype, "I1") == 0 ) { 
    int8_t val; int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SCHAR_MIN; } else { val = SCHAR_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I2") == 0 ) { 
    int16_t val; int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SHRT_MIN; } else { val = SHRT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I4") == 0 ) { 
    int32_t val; int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = INT_MIN; } else { val = INT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "I8") == 0 ) { 
    int64_t val; int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = LONG_MIN; } else { val = LONG_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "F4") == 0 ) { 
    float val; float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = FLT_MIN; } else { val = FLT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( strcmp(ptr_cmem->fldtype, "F8") == 0 ) { 
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

static int l_cmem_get_width( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushnumber(L, ptr_cmem->width);
  return 1;
}

static int l_cmem_set_width( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  int64_t width =  luaL_checknumber(L, 2);
  if ( ptr_cmem->width > 0 ) { WHEREAMI; goto BYE; }
  if ( width <= 0 ) { WHEREAMI; goto BYE; }
  if ( ( ( ptr_cmem->size / width )  * width ) != ptr_cmem->size ) {
    WHEREAMI; goto BYE;
  }
  ptr_cmem->width = width;
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

static int l_cmem_fldtype( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, ptr_cmem->fldtype);
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

static int l_cmem_is_data( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  bool ret_val;
  if ( ( ptr_cmem->data == NULL ) || ( ptr_cmem->size == 0 ) ) { 
    ret_val = false;
  }
  else {
    ret_val = true;
  }
  lua_pushboolean(L, ret_val);
  return 1;
}

static int l_cmem_is_foreign( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushboolean(L, ptr_cmem->is_foreign);
  return 1;
}

static int l_cmem_me( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  // Now return meta-data as table 
  lua_newtable(L);
  // size
  lua_pushstring(L, "size");
  lua_pushnumber(L, ptr_cmem->size);
  lua_settable(L, -3);
  // width
  lua_pushstring(L, "width");
  lua_pushnumber(L, ptr_cmem->width);
  lua_settable(L, -3);
  // is_foreign 
  lua_pushstring(L, "is_foreign ");
  lua_pushboolean(L, ptr_cmem->is_foreign );
  lua_settable(L, -3);
  // is_stealable 
  lua_pushstring(L, "is_stealable ");
  lua_pushboolean(L, ptr_cmem->is_stealable );
  lua_settable(L, -3);
  // fldtype
  lua_pushstring(L, "fldtype");
  lua_pushstring(L, ptr_cmem->fldtype );
  lua_settable(L, -3);
  // cell_name
  lua_pushstring(L, "cell_name");
  lua_pushstring(L, ptr_cmem->cell_name );
  lua_settable(L, -3);
  return 1; 
}

static int l_cmem_stealable( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( ( num_args < 1 ) || ( num_args > 2 ) )  { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 1, "CMEM");
  bool stealable = false;
  if ( num_args == 2 ) { 
    stealable = lua_toboolean(L, 2);
  }
  ptr_cmem->is_stealable = stealable;
  lua_pushboolean(L, true);
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
static int l_cmem_free( lua_State *L) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( num_args != 1 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem->data == NULL ) { 
    // explicit free will cause control to come here
    bool ok1 = false, ok2 = false;
    if ( ( ptr_cmem->size == 0 ) &&
         ( *ptr_cmem->fldtype == '\0' ) &&
         ( *ptr_cmem->cell_name == '\0' ) ) {
      ok1 = true;
    }
    if ( ( ptr_cmem->size <= 0 ) && 
         ( strcmp(ptr_cmem->fldtype, "XXX") == 0 ) && 
         ( strcmp(ptr_cmem->cell_name, "Uninitialized") == 0 ) ) {
      ok2 = true;
    }
    if ( !ok1 && !ok2 ) { 
      printf("not good\n"); 
      WHEREAMI; goto BYE;
    }
  }
  else {
    if ( ptr_cmem->is_foreign ) { 
      /* Foreign indicates somebody else responsible for free */
    }
    else {
      // garbage collection of Lua
      if ( ( ptr_cmem->size == -1 ) && 
          ( strcmp(ptr_cmem->fldtype, "XXX") == 0 ) && 
          ( strcmp(ptr_cmem->cell_name, "Uninitialized") == 0 ) ) {
        /* nothing to do */
        printf("TODO P0 not good\n"); WHEREAMI; goto BYE;
      }
      else {
        free(ptr_cmem->data);
        ptr_cmem->data = NULL;
        strcpy(ptr_cmem->fldtype, "XXX");
        strcpy(ptr_cmem->cell_name, "Uninitialized");
        ptr_cmem->size = -1;
      }
    }
  }
  // printf("Freeing %x \n", ptr_cmem);
  lua_pushboolean(L, true); 
  return 1; 
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}

// Following only for debugging 
static int l_cmem_seq( lua_State *L) {
  int status = 0;
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  lua_Number start  = luaL_checknumber(L, 2);
  lua_Number incr   = luaL_checknumber(L, 3);
  lua_Number num    = luaL_checknumber(L, 4);
  const char *qtype = luaL_checkstring(L, 5);
  void *X = ptr_cmem->data;
  // width must be set
  int width = ptr_cmem->width;
  if ( ( width < 1 ) || ( width > 8 ) ) { go_BYE(-1); }
  if ( num > ( ptr_cmem->size / width ) ) { go_BYE(-1); }
  memset(buf, '\0', BUFLEN);
  if ( strcmp(qtype, "I1") == 0 ) { 
    if ( width != sizeof(int8_t) ) { go_BYE(-1); }
    int8_t *ptr = (int8_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I2") == 0 ) { 
    if ( width != sizeof(int16_t) ) { go_BYE(-1); }
    int16_t *ptr = (int16_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I4") == 0 ) { 
    if ( width != sizeof(int32_t) ) { go_BYE(-1); }
    int32_t *ptr = (int32_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "I8") == 0 ) { 
    if ( width != sizeof(int64_t) ) { go_BYE(-1); }
    int64_t *ptr = (int64_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F4") == 0 ) { 
    if ( width != sizeof(float) ) { go_BYE(-1); }
    float *ptr = (float *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else if ( strcmp(qtype, "F8") == 0 ) { 
    if ( width != sizeof(double) ) { go_BYE(-1); }
    double *ptr = (double *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
  }
  else {
    go_BYE(-1); 
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}
// Following only for debugging and hence has limited usage 
static int l_cmem_set( lua_State *L) {

  CMEM_REC_TYPE *ptr_cmem  = luaL_checkudata( L, 1, "CMEM");
  lua_Number val = 0;
  char *str_val = NULL;
  // NOTE: Do NOT change order of if. Lua will claim it as string 
  // even if it is a number
  if ( strcmp(ptr_cmem->fldtype, "SC") == 0 ) { 
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
  char *fldtype = ptr_cmem->fldtype;
  if ( lua_gettop(L) >= 3 ) { 
    if ( lua_isstring(L, 3) ) {
      fldtype = (char *)luaL_checkstring(L, 3);
      if ( strcmp(fldtype,  ptr_cmem->fldtype) != 0 ) {
        WHEREAMI; goto BYE;
      }
    }
  }
  if ( ( fldtype == NULL ) || ( *fldtype == '\0' ) ) { 
    WHEREAMI; goto BYE;
  }
  if ( strcmp(fldtype, "I1") == 0 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "I2") == 0 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "I4") == 0 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "I8") == 0 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "F4") == 0 ) { 
    float *ptr = (float *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "F8") == 0 ) { 
    double *ptr = (double *)X; ptr[0] = val;
  }
  else if ( strcmp(fldtype, "SC") == 0 ) { 
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
  lua_pushstring(L, __func__);
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
  lua_pushstring(L, __func__);
  return 2;
}
// Following only for debugging 
static int l_cmem_prbuf( lua_State *L) {
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  void  *X          = ptr_cmem->data;
  const char *qtype = ptr_cmem->fldtype;
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
  else if ( strcmp(qtype, "SC") == 0 ) { 
    char *Y = (char  *)X; 
    printf("%s", Y);
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
    { "__gc",       l_cmem_free               },
    { "data",       l_cmem_data },
    { "delete",     l_cmem_free               },
    { "dupe",       l_cmem_dupe }, // only for testing
    { "fldtype",    l_cmem_fldtype },
    { "is_foreign", l_cmem_is_foreign },
    { "is_data",    l_cmem_is_data },
    { "me",         l_cmem_me },
    { "name",       l_cmem_name },
    { "new",        l_cmem_new },
    { "nop",        l_cmem_nop },
    { "prbuf",      l_cmem_prbuf },
    { "set",        l_cmem_set               },
    { "set_default", l_cmem_set_default },
    { "set_max",    l_cmem_set_max },
    { "set_min",    l_cmem_set_min },
    { "set_width",  l_cmem_set_width },
    { "seq",        l_cmem_seq               },
    { "size",       l_cmem_size },
    { "stealable",  l_cmem_stealable },
    { "to_str",     l_cmem_to_str },
    { "width",      l_cmem_get_width },
    { "zero",       l_cmem_zero },
    { NULL,  NULL         }
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "data",       l_cmem_data },
    { "delete",     l_cmem_free               },
    { "dupe",       l_cmem_dupe }, // only for testing
    { "fldtype",    l_cmem_fldtype },
    { "is_foreign", l_cmem_is_foreign },
    { "is_data",    l_cmem_is_data },
    { "me",         l_cmem_me },
    { "name",       l_cmem_name },
    { "new",        l_cmem_new },
    { "nop",        l_cmem_nop },
    { "prbuf",      l_cmem_prbuf },
    { "set",        l_cmem_set               },
    { "set_default", l_cmem_set_default },
    { "set_max",    l_cmem_set_max },
    { "set_min",    l_cmem_set_min },
    { "set_width",  l_cmem_set_width },
    { "seq",        l_cmem_seq               },
    { "size",       l_cmem_size },
    { "stealable",  l_cmem_stealable },
    { "to_str",     l_cmem_to_str },
    { "width",      l_cmem_get_width },
    { "zero",       l_cmem_zero },
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
