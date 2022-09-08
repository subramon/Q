#define LUA_LIB

#include "luaconf.h"
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "q_incs.h"

#include "cmem_struct.h"
#include "aux_cmem.h"
#include "aux_lua_to_c.h"
#include "qtypes.h"

#include "I1_to_txt.h" 
#include "I2_to_txt.h" 
#include "I4_to_txt.h" 
#include "I8_to_txt.h" 
#include "F4_to_txt.h" 
#include "F8_to_txt.h" 

#define MIN_VAL 1
#define MAX_VAL 2
#define BUFLEN 2047 // TODO P4: Should not be hard coded. See max txt length

int luaopen_libcmem (lua_State *L);

static int 
l_cmem_dupe( 
    lua_State *L
    )  // ONLY FOR TESTING
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  const char *str_qtype = NULL;
  const char *cell_name = NULL;
  void *data = NULL;

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));

  if ( !lua_islightuserdata(L, 1) ) { go_BYE(-1); }
  data = lua_touserdata(L, 1);

  int64_t size =  luaL_checknumber(L, 2);
  if ( size <= 0 ) { go_BYE(-1); }

  if ( lua_gettop(L) > 3 ) { 
    if ( lua_isstring(L, 3) ) {
      str_qtype = luaL_checkstring(L, 3);
    }
  }
  qtype_t qtype = get_c_qtype(str_qtype); 
  if ( qtype == Q0 ) { go_BYE(-1); }
  if ( lua_gettop(L) > 4 ) { 
    if ( lua_isstring(L, 4) ) {
      cell_name = luaL_checkstring(L, 4);
    }
  }
  status = cmem_dupe(ptr_cmem, data, size, qtype, cell_name);
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
static int 
l_cmem_new( 
    lua_State *L
    ) 
{
  int status = 0;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  bool is_key;

  const char * str_qtype = NULL;   // info to be set from input 
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
    status = get_int_from_tbl(L, 1, "size", &is_key, &size); cBYE(status);
    if ( !is_key ) { 
      fprintf(stderr, "CMEM size not specified\n"); 
      go_BYE(-1); 
    }
    status = get_str_from_tbl(L, 1, "qtype", &is_key, &str_qtype); 
    cBYE(status);
    status = get_str_from_tbl(L, 1, "name", &is_key, &cell_name); 
    cBYE(status);
  }
  // Note we allow size == 0 for dummy CMEM so that we do not 
  if ( size < 0 ) { go_BYE(-1); }

  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  return_if_malloc_failed(ptr_cmem);
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */

  qtype_t qtype = get_c_qtype(str_qtype); 
  // This is okay: if ( qtype == Q0 ) { go_BYE(-1); }
  status = cmem_malloc(ptr_cmem, size, qtype, cell_name);
  cBYE(status);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  return 2;
}

static int 
l_cmem_set_name( 
    lua_State *L
    ) {
  int status = 0;
  int num_args = lua_gettop(L);
  if ( num_args != 2 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  const char * const cell_name = luaL_checkstring(L, 2);
  memset(ptr_cmem->cell_name, 0, Q_MAX_LEN_CELL_NAME+1); 
  if ( cell_name != NULL ) { 
    strncpy(ptr_cmem->cell_name, cell_name, Q_MAX_LEN_CELL_NAME);
  }
  lua_pushboolean(L, true);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}

static int 
l_cmem_name( 
    lua_State *L
    ) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( num_args != 1 ) { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem->cell_name == NULL ) { 
    lua_pushnil(L);
  }
  else {
    lua_pushstring(L, ptr_cmem->cell_name);
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, __func__);
  lua_pushnumber(L, status);
  return 3;
}


// set_default used only for debugging. 
// TODO P4 Consider using it elsewhere as well
static int 
set_default(
    CMEM_REC_TYPE *ptr_cmem,
    lua_Number val
    )
{
  int width;
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->qtype == I1 ) { 
    int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int8_t)val; }
  }
  else if ( ptr_cmem->qtype == I2 ) { 
    int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int16_t)val; }
  }
  else if ( ptr_cmem->qtype == I4 ) { 
    int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int32_t)val; }
  }
  else if ( ptr_cmem->qtype == I8 ) { 
    int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (int64_t)val; }
  }
  else if ( ptr_cmem->qtype == F4 ) { 
    float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    for ( int i = 0; i  < n; i++ ) { x[i] = (float)val; }
  }
  else if ( ptr_cmem->qtype == F8 ) { 
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

static int 
l_cmem_nop( 
    lua_State *L
    ) // just for debugging 
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  if ( ptr_cmem == NULL ) {  // to stop gcc from complaining
    lua_pushnil(L);
    return 1;
  }
  lua_pushboolean(L, true);
  return 1;
}

static int 
l_cmem_set_default( 
    lua_State *L
    )
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

static int 
cmem_set_min_max(
    CMEM_REC_TYPE *ptr_cmem,
    int mode 
    )
{
  int width;
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->qtype == I1 ) { 
    int8_t val; int8_t *x = (int8_t *)(ptr_cmem->data);
    width = sizeof(int8_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SCHAR_MIN; } else { val = SCHAR_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( ptr_cmem->qtype == I2 ) { 
    int16_t val; int16_t *x = (int16_t *)(ptr_cmem->data);
    width = sizeof(int16_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = SHRT_MIN; } else { val = SHRT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( ptr_cmem->qtype == I4 ) { 
    int32_t val; int32_t *x = (int32_t *)(ptr_cmem->data);
    width = sizeof(int32_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = INT_MIN; } else { val = INT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( ptr_cmem->qtype == I8 ) { 
    int64_t val; int64_t *x = (int64_t *)(ptr_cmem->data);
    width = sizeof(int64_t);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = LONG_MIN; } else { val = LONG_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( ptr_cmem->qtype == F4 ) { 
    float val; float *x = (float *)(ptr_cmem->data);
    width = sizeof(float);
    int n = ptr_cmem->size / width;
    if ( mode == MIN_VAL ) { val = FLT_MIN; } else { val = FLT_MAX; }
    for ( int i = 0; i  < n; i++ ) { x[i] = val; }
  }
  else if ( ptr_cmem->qtype == F8 ) { 
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

static int 
l_cmem_set_max( 
    lua_State *L
    )
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

static int 
l_cmem_set_min( 
    lua_State *L
    )
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


static int 
cmem_zero( 
    CMEM_REC_TYPE *ptr_cmem
    )
{
  if ( ptr_cmem == NULL ) { WHEREAMI; return -1; }
  if ( ptr_cmem->size <= 0 ) { WHEREAMI; return -1; }
  if ( ptr_cmem->data == NULL ) { WHEREAMI; return -1; }
  memset(ptr_cmem->data, '\0', ptr_cmem->size);
  return 0;
}

static int 
l_cmem_zero( 
    lua_State *L
    ) {
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

static int 
l_cmem_qtype( 
    lua_State *L
    ) 
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushstring(L, get_str_qtype(ptr_cmem->qtype));
  return 1;
}
static int l_cmem_data( 
    lua_State *L
    ) 
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushlightuserdata(L, ptr_cmem->data);
  return 1;
}

static int l_cmem_size( 
    lua_State *L
    ) 
{
  CMEM_REC_TYPE *ptr_cmem = (CMEM_REC_TYPE *)luaL_checkudata(L, 1, "CMEM");
  lua_pushnumber(L, ptr_cmem->size);
  return 1;
}

static int 
l_cmem_is_data( 
    lua_State *L
    ) 
{
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

static int 
l_cmem_is_foreign( 
    lua_State *L
    ) 
{
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
  // is_foreign 
  lua_pushstring(L, "is_foreign ");
  lua_pushboolean(L, ptr_cmem->is_foreign );
  lua_settable(L, -3);
  // is_stealable 
  lua_pushstring(L, "is_stealable ");
  lua_pushboolean(L, ptr_cmem->is_stealable );
  lua_settable(L, -3);
  // qtype
  lua_pushstring(L, "qtype");
  lua_pushstring(L, get_str_qtype(ptr_cmem->qtype));
  lua_settable(L, -3);
  // cell_name
  lua_pushstring(L, "cell_name");
  if ( ptr_cmem->cell_name  == NULL ) {
    lua_pushnil(L);
  }
  else {
    lua_pushstring(L, ptr_cmem->cell_name );
  }
  lua_settable(L, -3);
  return 1; 
}

static int 
l_cmem_stealable( 
    lua_State *L
    ) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( ( num_args < 1 ) || ( num_args > 2 ) )  { go_BYE(-1); }
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata(L, 1, "CMEM");
  // you must own it to make it stealable 
  if ( ptr_cmem->is_foreign ) { go_BYE(-1); }
  bool stealable = true; // default behavior
  if ( num_args == 2 ) { 
    if ( !lua_isboolean(L, 2) ) { go_BYE(-1); }
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
  status = cmem_free(ptr_cmem);  cBYE(status);
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
  const char *str_qtype = luaL_checkstring(L, 5);
  void *X = ptr_cmem->data;
  qtype_t qtype = get_c_qtype(str_qtype);
  int width = get_width_qtype(str_qtype);
  if ( width < 0 ) { go_BYE(-1); }
  if ( ( width < 1 ) || ( width > 8 ) ) { go_BYE(-1); }
  // check if enough space in CMEM
  if ( (num * width) > ptr_cmem->size ) { go_BYE(-1); }
  memset(buf, '\0', BUFLEN);
  switch ( qtype ) { 
    case I1 : 
      {
    if ( width != sizeof(int8_t) ) { go_BYE(-1); }
    int8_t *ptr = (int8_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
      }
    break;
    case I2 : 
    {
    if ( width != sizeof(int16_t) ) { go_BYE(-1); }
    int16_t *ptr = (int16_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
    }
    break;
    case I4 : 
    {
    if ( width != sizeof(int32_t) ) { go_BYE(-1); }
    int32_t *ptr = (int32_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
    }
    break;
    case I8 : 
    {
    if ( width != sizeof(int64_t) ) { go_BYE(-1); }
    int64_t *ptr = (int64_t *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
    }
    break;
    case F4 : 
    {
    if ( width != sizeof(float) ) { go_BYE(-1); }
    float *ptr = (float *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
    }
    break;
    case F8 : 
    {
    if ( width != sizeof(double) ) { go_BYE(-1); }
    double *ptr = (double *)X; ptr[0] = start;
    for ( int i = 1; i < num; i++ ) { ptr[i] = ptr[i-1] + incr; }
    }
    break;
    default : 
    go_BYE(-1);
    break;
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
static int l_cmem_set( 
    lua_State *L
    ) 
{
  int status = 0;
  int num_args = lua_gettop(L);
  if ( !( ( num_args == 2  ) || ( num_args == 3  ) ) ) { 
    go_BYE(-1);
  }

  CMEM_REC_TYPE *ptr_cmem  = luaL_checkudata( L, 1, "CMEM");
  lua_Number val = 0;
  const char *str_val = NULL;
  // NOTE: Do NOT change order of if. Lua will claim it as string 
  // even if it is a number
  if ( ptr_cmem->qtype == SC ) { 
    if ( lua_isstring(L, 2) ) {
      str_val = luaL_checkstring(L, 2);
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
  const char *str_qtype;
  qtype_t qtype = ptr_cmem->qtype;
  if ( num_args == 3 ) { 
  if ( lua_isstring(L, 3) ) {
    str_qtype = luaL_checkstring(L, 3);
    qtype = get_c_qtype(str_qtype);
    // Convert str_qtype to qtype 
    if ( qtype !=  ptr_cmem->qtype) {
      WHEREAMI; goto BYE;
    }
  }
  else {
    go_BYE(-1);
  }
  }
  if ( qtype == Q0 ) { go_BYE(-1); }
  if ( qtype == I1 ) { 
    int8_t *ptr = (int8_t *)X; ptr[0] = val;
  }
  else if ( qtype == I2 ) { 
    int16_t *ptr = (int16_t *)X; ptr[0] = val;
  }
  else if (  qtype == I4 ) { 
    int32_t *ptr = (int32_t *)X; ptr[0] = val;
  }
  else if ( qtype == I8 ) { 
    int64_t *ptr = (int64_t *)X; ptr[0] = val;
  }
  else if ( qtype == F4 ) { 
    float *ptr = (float *)X; ptr[0] = val;
  }
  else if ( qtype == F8 ) { 
    double *ptr = (double *)X; ptr[0] = val;
  }
  else if ( qtype == SC ) { 
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
  lua_pushnumber(L, status);
  return 3;
}
// Following only for debugging 
static int l_cmem_to_str( lua_State *L) {
  int status = 0;
  char buf[BUFLEN+1]; 
  CMEM_REC_TYPE *ptr_cmem = luaL_checkudata( L, 1, "CMEM");
  const char *str_qtype = luaL_checkstring(L, 2);
  memset(buf, '\0', BUFLEN);
  void  *X          = ptr_cmem->data;
  if ( strcmp(str_qtype, "B1") == 0 ) { 
    go_BYE(-1); // TODO 
    // status = B1_to_txt(X, buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "I1") == 0 ) { 
    status = I1_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "I2") == 0 ) { 
    status = I2_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "I4") == 0 ) { 
    status = I4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "I8") == 0 ) { 
    status = I8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "F4") == 0 ) { 
    status = F4_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "F8") == 0 ) { 
    status = F8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "F8") == 0 ) { 
    status = F8_to_txt(X, "", buf, BUFLEN); cBYE(status);
  }
  else if ( strcmp(str_qtype, "SC") == 0 ) { 
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
//----------------------------------------
static const struct luaL_Reg cmem_methods[] = {
    { "__gc",       l_cmem_free               },
    { "data",       l_cmem_data },
    { "delete",     l_cmem_free               },
    { "dupe",       l_cmem_dupe }, // only for testing
    { "is_foreign", l_cmem_is_foreign },
    { "is_data",    l_cmem_is_data },
    { "me",         l_cmem_me },
    { "name",       l_cmem_name },
    { "new",        l_cmem_new },
    { "nop",        l_cmem_nop },
    { "qtype",      l_cmem_qtype },
    { "set",        l_cmem_set               },
    { "set_default", l_cmem_set_default },
    { "set_max",    l_cmem_set_max },
    { "set_min",    l_cmem_set_min },
    { "set_name",   l_cmem_set_name },
    { "seq",        l_cmem_seq               },
    { "size",       l_cmem_size },
    { "stealable",  l_cmem_stealable },
    { "to_str",     l_cmem_to_str },
    { "zero",       l_cmem_zero },
    { NULL,  NULL         }
};
 
static const struct luaL_Reg cmem_functions[] = {
    { "data",       l_cmem_data },
    { "delete",     l_cmem_free               },
    { "dupe",       l_cmem_dupe }, // only for testing
    { "is_foreign", l_cmem_is_foreign },
    { "is_data",    l_cmem_is_data },
    { "me",         l_cmem_me },
    { "name",       l_cmem_name },
    { "new",        l_cmem_new },
    { "nop",        l_cmem_nop },
    { "qtype",      l_cmem_qtype },
    { "set",        l_cmem_set               },
    { "set_default", l_cmem_set_default },
    { "set_max",    l_cmem_set_max },
    { "set_min",    l_cmem_set_min },
    { "set_name",   l_cmem_set_name },
    { "seq",        l_cmem_seq               },
    { "size",       l_cmem_size },
    { "stealable",  l_cmem_stealable },
    { "to_str",     l_cmem_to_str },
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
  // TODO P1 fix hard coding below 
  int status = luaL_dostring(L, 
      "return require 'Q/UTILS/lua/register_type'");
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
