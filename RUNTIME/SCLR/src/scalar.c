#define LUA_LIB

#include "q_incs.h"

#include "lauxlib.h"
#include "lua.h"
#include "luaconf.h"
#include "lualib.h"

#include "txt_to_B1.h"
#include "txt_to_I1.h"
#include "txt_to_I2.h"
#include "txt_to_I4.h"
#include "txt_to_I8.h"
#include "txt_to_F4.h"
#include "txt_to_F8.h"

#include "cmem_struct.h"
#include "cmem.h"
#include "scalar_struct.h"

extern int luaopen_libsclr (lua_State *L);

static int l_sclr_to_cmem( lua_State *L) 
{
  SCLR_REC_TYPE *ptr_sclr = NULL;
  CMEM_REC_TYPE *ptr_cmem = NULL;
  // Note that we return a copy of the data, not the original data
  bool is_foreign = false;

  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  ptr_sclr = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( ptr_sclr == NULL ) { WHEREAMI; goto BYE; }
/*
  if ( lua_isstring(L, 2) ) {
    const char *x = luaL_checkstring(L, 2);
    if ( strcmp(x, "is_foreign") == 0 ) {
      is_foreign = false;
    }
    if ( strcmp(x, "not_is_foreign") == 0 ) {
      is_foreign = false;
    }
    else {
      WHEREAMI; goto BYE;
    }
  }
  else {
    is_foreign = false;
  }
  */
  ptr_cmem = (CMEM_REC_TYPE *)lua_newuserdata(L, sizeof(CMEM_REC_TYPE));
  if ( ptr_cmem == NULL ) { WHEREAMI; goto BYE; }
  memset(ptr_cmem, '\0', sizeof(CMEM_REC_TYPE));
  int status = 0;
  if ( ! is_foreign ) {
    status = cmem_malloc(ptr_cmem,  ptr_sclr->field_width, 
        ptr_sclr->field_type, "");
    memcpy(ptr_cmem->data, &(ptr_sclr->cdata), ptr_sclr->field_width);
  }
  else { 
    // Control should not come here, not just yet
    WHEREAMI; goto BYE;
    status = cmem_dupe(ptr_cmem,  &(ptr_sclr->cdata), ptr_sclr->field_width,
        ptr_sclr->field_type, "");
  }
  if ( status < 0 ) { WHEREAMI; goto BYE; }
  strncpy(ptr_cmem->fldtype, ptr_sclr->field_type, 4-1);
  ptr_cmem->size = ptr_sclr->field_width;

  luaL_getmetatable(L, "CMEM"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_cmem. ");
  return 2;
}

#define OP_BUF_LEN 4095
#define BUF_LEN 63
static int l_sclr_reincarnate(lua_State *L) {
  int status = 0;
  char op_str_buf[OP_BUF_LEN+1]; // TODO P3 try not to hard code bound
  char  buf[BUF_LEN+1];          //  TODO P3 try not to hard code bound

  memset(op_str_buf, '\0', OP_BUF_LEN+1);
  memset(buf,        '\0', BUF_LEN+1);
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  const char *field_type = ptr_sclr->field_type;

  strncpy(op_str_buf, "Scalar.new(", OP_BUF_LEN);
  if ( strcmp(field_type, "B1" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%s", ptr_sclr->cdata.valB1 ? "true" : "false");
  }
  else if ( strcmp(field_type, "I1" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRI1, ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRI2, ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRI4, ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRI8, ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRF4, ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) {
    snprintf(buf, BUF_LEN, "%" PRF8, ptr_sclr->cdata.valF8);
  }
  else {
    WHEREAMI; goto BYE;
  }
  strncat(op_str_buf, buf, OP_BUF_LEN);

  strncat(op_str_buf, ", '", OP_BUF_LEN);

  strncat(op_str_buf, field_type, OP_BUF_LEN);

  strncat(op_str_buf, "')", OP_BUF_LEN);

  lua_pushstring(L, op_str_buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_reincarnate. ");
  lua_pushnumber(L, status);
  return 2;
}

static int l_sclr_to_num( lua_State *L) {
  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  const char *field_type = ptr_sclr->field_type;
  if ( strcmp(field_type, "B1" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valB1);
  }
  else if ( strcmp(field_type, "I1" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) { 
    lua_pushnumber(L, ptr_sclr->cdata.valF8);
  }
  else {
    WHEREAMI; goto BYE;
  }
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_num. ");
  return 2;
}

static int l_fldtype(lua_State *L) {
  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  lua_pushstring(L, ptr_sclr->field_type);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: fldtype. ");
  return 2;
}

static int l_sclr_to_str( lua_State *L) {
  int status = 0;
#define BUFLEN 127
  char buf[BUFLEN+1];
  int nw = 0;

  if ( lua_gettop(L) < 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  // TODO Allow user to provide format
  memset(buf, '\0', BUFLEN+1);
  const char *field_type = ptr_sclr->field_type;

  if ( strcmp(field_type, "B1" ) == 0 ) { 
    if (  ptr_sclr->cdata.valB1 ) { 
      strncpy(buf, "true", BUFLEN);
    }
    else {
      strncpy(buf, "false", BUFLEN);
    }
  }
  else if ( strcmp(field_type, "I1" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(field_type, "I2" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(field_type, "I4" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%d", ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(field_type, "I8" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%" PRId64, ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(field_type, "F4" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%e", ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(field_type, "F8" ) == 0 ) { 
    nw = snprintf(buf, BUFLEN, "%e", ptr_sclr->cdata.valF8);
  }
  else {
    go_BYE(-1);
  }
  if ( ( nw < 0 ) || ( nw >= BUFLEN ) )  { go_BYE(-1); }
  lua_pushstring(L, buf);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_to_str. ");
  lua_pushnumber(L, status);
  return 3;
}

#define mcr_chk_int(x) { if ( ceil(x) != floor(x) ) { go_BYE(-1); } }
#define mcr_chk_range_set(x, y, lb, ub) { \
      if ( ( x < lb ) || ( x > ub ) ) { go_BYE(-1); } \
       y = x;  \
}

static int l_sclr_abs( lua_State *L) {
  int status = 0;

  if ( lua_gettop(L) != 1 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( strcmp(ptr_sclr->field_type, "I1") == 0 ) {
    ptr_sclr->cdata.valI1 = abs(ptr_sclr->cdata.valI1);
  }
  else if ( strcmp(ptr_sclr->field_type, "I2") == 0 ) { 
    ptr_sclr->cdata.valI2 = abs(ptr_sclr->cdata.valI2);
  }
  else if ( strcmp(ptr_sclr->field_type, "I4") == 0 ) { 
    ptr_sclr->cdata.valI4 = abs(ptr_sclr->cdata.valI4);
  }
  else if ( strcmp(ptr_sclr->field_type, "I8") == 0 ) { 
    ptr_sclr->cdata.valI8 = llabs(ptr_sclr->cdata.valI8);
  }
  else if ( strcmp(ptr_sclr->field_type, "F4") == 0 ) { 
    ptr_sclr->cdata.valF4 = fabsf(ptr_sclr->cdata.valF4);
  }
  else if ( strcmp(ptr_sclr->field_type, "F8") == 0 ) { 
    ptr_sclr->cdata.valF8 = fabs(ptr_sclr->cdata.valF8);
  }
  else {
    go_BYE(-1);
  }
  // Push the scalar back 
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_abs. ");
  lua_pushnumber(L, status);
  return 3;
}
static int l_sclr_conv( lua_State *L) {
  int status = 0;

  if ( lua_gettop(L) != 2 ) { WHEREAMI; goto BYE; }
  SCLR_REC_TYPE *ptr_sclr=(SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  const char *qtype   = luaL_checkstring(L, 2);
  if ( strcmp(ptr_sclr->field_type, "I1") == 0 ) {
    if ( strcmp(qtype, "I1") == 0 ) { 
      // Nothing to do 
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      ptr_sclr->cdata.valI2 = ptr_sclr->cdata.valI1;
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      ptr_sclr->cdata.valI4 = ptr_sclr->cdata.valI1;
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      ptr_sclr->cdata.valI8 = ptr_sclr->cdata.valI1;
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      ptr_sclr->cdata.valF4 = ptr_sclr->cdata.valI1;
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      ptr_sclr->cdata.valF8 = ptr_sclr->cdata.valI1;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr->field_type, "I2") == 0 ) { 
    if ( strcmp(qtype, "I1") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI2, ptr_sclr->cdata.valI2, SCHAR_MIN, SCHAR_MAX);
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      // Nothing to do 
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      ptr_sclr->cdata.valI4 = ptr_sclr->cdata.valI2;
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      ptr_sclr->cdata.valI8 = ptr_sclr->cdata.valI2;
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      ptr_sclr->cdata.valF4 = ptr_sclr->cdata.valI2;
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      ptr_sclr->cdata.valF8 = ptr_sclr->cdata.valI2;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr->field_type, "I4") == 0 ) { 
    if ( strcmp(qtype, "I1") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI4, ptr_sclr->cdata.valI1, SCHAR_MIN, SCHAR_MAX);
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI4, ptr_sclr->cdata.valI2, SHRT_MIN, SHRT_MAX);
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      // nothing to do 
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      ptr_sclr->cdata.valI8 = ptr_sclr->cdata.valI4;
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      if ( ptr_sclr->cdata.valI4 > 16777217 ) { go_BYE(-1); }
      if ( ptr_sclr->cdata.valI4 < -16777217 ) { go_BYE(-1); }
      ptr_sclr->cdata.valF4 = ptr_sclr->cdata.valI4;
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      ptr_sclr->cdata.valF8 = ptr_sclr->cdata.valI4;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr->field_type, "I8") == 0 ) { 
    if ( strcmp(qtype, "I1") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI8, ptr_sclr->cdata.valI1, SCHAR_MIN, SCHAR_MAX);
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI8, ptr_sclr->cdata.valI1, SHRT_MIN, SHRT_MAX);
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      mcr_chk_range_set(ptr_sclr->cdata.valI8, ptr_sclr->cdata.valI1, INT_MIN, INT_MAX);
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      // nothing to do 
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      if ( ptr_sclr->cdata.valI8 > 16777217 ) { go_BYE(-1); }
      if ( ptr_sclr->cdata.valI8 < -16777217 ) { go_BYE(-1); }
      ptr_sclr->cdata.valF4 = ptr_sclr->cdata.valI8;
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      if ( ptr_sclr->cdata.valI8 > 9007199254740993LL ) { go_BYE(-1); }
      if ( ptr_sclr->cdata.valI8 < -9007199254740993LL ) { go_BYE(-1); }
      ptr_sclr->cdata.valF8 = ptr_sclr->cdata.valI8;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr->field_type, "F4") == 0 ) { 
    float val = ptr_sclr->cdata.valF4;
    if ( strcmp(qtype, "I1") == 0 ) { 
      mcr_chk_int(val);
      if ( ( val < SCHAR_MIN ) || ( val > SCHAR_MAX ) ) { go_BYE(-1); }
      ptr_sclr->cdata.valI1 = val;
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      mcr_chk_int(val);
      if ( ( val < SHRT_MIN ) || ( val > SHRT_MAX ) ) { go_BYE(-1); }
      ptr_sclr->cdata.valI2 = val;
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      mcr_chk_int(val);
      ptr_sclr->cdata.valI4 = val;
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      mcr_chk_int(val);
      ptr_sclr->cdata.valI8 = val;
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      // Nothing to do 
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      ptr_sclr->cdata.valF8 = ptr_sclr->cdata.valF4;
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(ptr_sclr->field_type, "F8") == 0 ) { 
    double val = ptr_sclr->cdata.valF8;
    if ( strcmp(qtype, "I1") == 0 ) { 
      mcr_chk_int(val);
      if ( ( val < SCHAR_MIN ) || ( val > SCHAR_MAX ) ) { go_BYE(-1); }
      ptr_sclr->cdata.valI1 = val;
    }
    else if ( strcmp(qtype, "I2") == 0 ) { 
      mcr_chk_int(val);
      if ( ( val < SHRT_MIN ) || ( val > SHRT_MAX ) ) { go_BYE(-1); }
      ptr_sclr->cdata.valI2 = val;
    }
    else if ( strcmp(qtype, "I4") == 0 ) { 
      mcr_chk_int(val);
      if ( ( val < INT_MIN ) || ( val > INT_MAX ) ) { go_BYE(-1); }
      ptr_sclr->cdata.valI4 = val;
    }
    else if ( strcmp(qtype, "I8") == 0 ) { 
      mcr_chk_int(val);
      ptr_sclr->cdata.valI8 = val;
    }
    else if ( strcmp(qtype, "F4") == 0 ) { 
      if ( ptr_sclr->cdata.valF8 >    FLT_MAX ) { go_BYE(-1); }
      if ( ptr_sclr->cdata.valF8 < -1*FLT_MAX ) { go_BYE(-1); }
      ptr_sclr->cdata.valF4 = (double)ptr_sclr->cdata.valF8;
      // TODO P3 Consider case where double value is close
      // to 0 but coercion to float makes it 0
    }
    else if ( strcmp(qtype, "F8") == 0 ) { 
      // Nothing to do 
    }
    else {
      go_BYE(-1);
    }
  }
  else {
    go_BYE(-1);
  }
  strcpy(ptr_sclr->field_type, qtype);

  // Push the scalar back 
  lua_pop(L, 1);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_conv. ");
  lua_pushnumber(L, status);
  return 3;
}

static int l_sclr_new( lua_State *L) {
  int status = 0;
  bool    tempB1;
  int8_t  tempI1;
  int16_t tempI2;
  int32_t tempI4;
  int64_t tempI8;
  float   tempF4;
  double  tempF8;
  const char *str_val = NULL;
  char *dst = NULL;
  char *src = NULL;
  lua_Number  in_val;
  CMEM_REC_TYPE *ptr_cmem = NULL;

  // TESTING GC problems lua_gc(L, LUA_GCCOLLECT, 0);  

  bool found = false;
  if ( lua_gettop(L) < 2 ) { go_BYE(-1); }
  if ( lua_isstring(L, 1) ) { 
    str_val = luaL_checkstring(L, 1);
    found = true;
  }
  else if (  lua_isuserdata(L, 1) ) { 
    ptr_cmem = luaL_checkudata(L, 1, "CMEM");
    found = true;
  }
  else if ( lua_isnumber(L, 1) ) {
    // No matter how I invoke it, Lua sends value as string
    go_BYE(-1); 
    in_val = luaL_checknumber(L, 1);
  }
  else if ( lua_isboolean(L, 1) ) {
    // However, if I invoke as true, then it comes here
    in_val = lua_toboolean(L, 1);
    found = true;
  }
  else {
    go_BYE(-1);
  }
  const char *qtype   = luaL_checkstring(L, 2);
  SCLR_REC_TYPE *ptr_sclr = NULL;
  ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  return_if_malloc_failed(ptr_sclr);
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  dst = (char *)&(ptr_sclr->cdata);

  if ( ptr_cmem != NULL ) {
    src = (char*)ptr_cmem->data;
    if ( ( ptr_cmem->fldtype != NULL ) && 
        ( *(ptr_cmem->fldtype) != '\0' ) ) {
      if ( strcmp(qtype, ptr_cmem->fldtype) != 0 ) { go_BYE(-1); }
    }
  }
  if ( !found ) { go_BYE(-1); }
  if ( ( str_val != NULL ) && ( ptr_cmem != NULL ) ) { go_BYE(-1); }

  if ( qtype == NULL ) { /* TODO P4 Infer qtype go_BYE(-1); */ }

  if ( strcmp(qtype, "B1" ) == 0 ) {
    if ( src != NULL ) { 
      memcpy(dst, src, 1);
    }
    else {
      if ( str_val == NULL ) { 
        tempB1 = in_val;
      }
      else {
        status = txt_to_B1(str_val, &tempB1); cBYE(status);
      }
      ptr_sclr->cdata.valB1 = tempB1;
    }
    strcpy(ptr_sclr->field_type, "B1"); 
    ptr_sclr->field_width = sizeof(bool);
  }
  else if ( strcmp(qtype, "I1" ) == 0 ) { 
    if ( src != NULL ) { 
      memcpy(dst, src, 1);
    }
    else {
      status = txt_to_I1(str_val, &tempI1); cBYE(status);
      memcpy(dst, &tempI1, 1); 
    }
    strcpy(ptr_sclr->field_type, "I1"); 
    ptr_sclr->field_width = 1;
  }
  else if ( strcmp(qtype, "I2" ) == 0 ) { 
    if ( src != NULL ) { 
      memcpy(dst, src, 2);
      if ( ptr_cmem->size < 2 ) { go_BYE(-1); }
    }
    else {
      status = txt_to_I2(str_val, &tempI2); cBYE(status);
      memcpy(dst, &tempI2, 2); 
    }
    strcpy(ptr_sclr->field_type, "I2"); 
    ptr_sclr->field_width = 2;
  }
  else if ( strcmp(qtype, "I4" ) == 0 ) { 
    if ( src != NULL ) { 
      if ( ptr_cmem->size < 4 ) { go_BYE(-1); }
      memcpy(dst, src, 4);
    }
    else {
      status = txt_to_I4(str_val, &tempI4); cBYE(status);
      memcpy(dst, &tempI4, 4); 
    }
    strcpy(ptr_sclr->field_type, "I4"); 
    ptr_sclr->field_width = 4;
  }
  else if ( strcmp(qtype, "I8" ) == 0 ) { 
    if ( src != NULL ) { 
      if ( ptr_cmem->size < 8 ) { go_BYE(-1); }
      memcpy(dst, src, 8);
    }
    else {
      status = txt_to_I8(str_val, &tempI8); cBYE(status);
      memcpy(dst, &tempI8, 8); 
    }
    strcpy(ptr_sclr->field_type, "I8"); 
    ptr_sclr->field_width = 8;
  }
  else if ( strcmp(qtype, "F4" ) == 0 ) { 
    if ( src != NULL ) { 
      if ( ptr_cmem->size < 4 ) { go_BYE(-1); }
      memcpy(dst, src, 4);
    }
    else {
      status = txt_to_F4(str_val, &tempF4); cBYE(status);
      memcpy(dst, &tempF4, 4); 
    }
    strcpy(ptr_sclr->field_type, "F4"); 
    ptr_sclr->field_width = 4;
  }
  else if ( strcmp(qtype, "F8" ) == 0 ) { 
    if ( src != NULL ) { 
      if ( ptr_cmem->size < 8 ) { go_BYE(-1); }
      memcpy(dst, src, 8);
    }
    else {
      status = txt_to_F8(str_val, &tempF8); cBYE(status);
      memcpy(dst, &tempF8, 8); 
    }
    strcpy(ptr_sclr->field_type, "F8"); 
    ptr_sclr->field_width = 8;
  }
  else {
    fprintf(stderr, "Unknown qtype [%s] \n", qtype);
    go_BYE(-1);
  }
  luaL_getmetatable(L, "Scalar"); /* Add the metatable to the stack. */
  lua_setmetatable(L, -2); /* Set the metatable on the userdata. */
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_new. ");
  return 2;
}

static int set_output_field_type(
    const char *const fldtype1,
    const char *const fldtype2,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;
  if ( strcmp(fldtype1, "I1") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I1");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I2") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I2");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "I8") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "I8");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "F4") == 0 ) {
    if ( strcmp(fldtype2, "I1") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I2") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "I8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F4") == 0 ) {
      strcpy(ptr_sclr->field_type, "F4");
    }
    else if ( strcmp(fldtype2, "F8") == 0 ) {
      strcpy(ptr_sclr->field_type, "F8");
    }
    else {
      go_BYE(-1);
    }
  }
  else if ( strcmp(fldtype1, "F8") == 0 ) {
    strcpy(ptr_sclr->field_type, "F8");
  }
  else {
    go_BYE(-1);
  }
BYE:
  return status;
}
//----------------------------------------

#include "_eval_cmp.c"
#include "_outer_eval_cmp.c"
#include "_eval_arith.c"
#include "_outer_eval_arith.c"
//-----------------------
static const struct luaL_Reg sclr_methods[] = {
    { "to_str", l_sclr_to_str },
    { "to_num", l_sclr_to_num },
    { "to_cmem", l_sclr_to_cmem },
    { "conv", l_sclr_conv },
    { "abs", l_sclr_abs },
    { "fldtype", l_fldtype },
    { "reincarnate", l_sclr_reincarnate },
    { NULL,          NULL               },
};
 
static const struct luaL_Reg sclr_functions[] = {
    { "new", l_sclr_new },
    { "fldtype", l_fldtype },
    { "to_str", l_sclr_to_str },
    { "to_num", l_sclr_to_num },
    { "reincarnate", l_sclr_reincarnate },
    { "to_cmem", l_sclr_to_cmem },
    { "conv", l_sclr_conv },
    { "eq", l_sclr_eq },
    { "neq", l_sclr_neq },
    { "gt", l_sclr_gt },
    { "lt", l_sclr_lt },
    { "geq", l_sclr_geq },
    { "leq", l_sclr_leq },
    { "add", l_sclr_add },
    { "sub", l_sclr_sub },
    { "mul", l_sclr_mul },
    { "div", l_sclr_div },
    { "abs", l_sclr_abs },
    { NULL,  NULL         }
};
 
/*
** Open test library
*/

int luaopen_libsclr (lua_State *L) {
  /* Create the metatable and put it on the stack. */
  luaL_newmetatable(L, "Scalar");
  /* Duplicate the metatable on the stack (We know have 2). */
  lua_pushvalue(L, -1);
  /* Pop the first metatable off the stack and assign it to __index
   * of the second one. We set the metatable for the table to itself.
   * This is equivalent to the following in lua:
   * metatable = {}
   * metatable.__index = metatable
   */
  lua_setfield(L, -2, "__index");
  lua_pushcfunction(L, l_sclr_to_str); lua_setfield(L, -2, "__tostring");

  lua_pushcfunction(L, l_sclr_eq); lua_setfield(L, -2, "__eq");
  lua_pushcfunction(L, l_sclr_lt); lua_setfield(L, -2, "__lt");
  lua_pushcfunction(L, l_sclr_gt); lua_setfield(L, -2, "__gt");
  lua_pushcfunction(L, l_sclr_leq); lua_setfield(L, -2, "__le");
  lua_pushcfunction(L, l_sclr_geq); lua_setfield(L, -2, "__ge");
  /* negations of above happen automatically. No need to do them here */

  lua_pushcfunction(L, l_sclr_add); lua_setfield(L, -2, "__add");
  lua_pushcfunction(L, l_sclr_sub); lua_setfield(L, -2, "__sub");
  lua_pushcfunction(L, l_sclr_mul); lua_setfield(L, -2, "__mul");
  lua_pushcfunction(L, l_sclr_div); lua_setfield(L, -2, "__div");

  // Following do not work currently
  // Will not work in 5.1 as per Indrajeet
  lua_pushcfunction(L, l_sclr_to_num); lua_setfield(L, -2, "__tonumber");
  // Above do not work currently

  /* Register the object.func functions into the table that is at the 
   * top of the stack. */

  /* Set the methods to the metatable that should be accessed via
   * object:func */
  luaL_register(L, NULL, sclr_methods);

  /* Register Scalar in types table */
  int status = luaL_dostring(L, "return require 'Q/UTILS/lua/q_types'");
  if (status != 0 ) {
    fprintf(stderr, "Running require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  } 
  luaL_getmetatable(L, "Scalar");
  lua_pushstring(L, "Scalar");
  status =  lua_pcall(L, 2, 0, 0);
  if (status != 0 ) {
     fprintf(stderr, "%d\n", status);
     fprintf(stderr, "Type registration failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  /* Register the object.func functions into the table that is at the
   op of the stack. */
  
  // Registering with Q
  status = luaL_dostring(L, "return require('Q/q_export').export");
  if (status != 0 ) {
    fprintf(stderr, "Q registration require failed:  %s\n", lua_tostring(L, -1));
    exit(1);
  }
  lua_pushstring(L, "Scalar");
  lua_createtable(L, 0, 0);
  luaL_register(L, NULL, sclr_functions);
  status = lua_pcall(L, 2, 1, 0);
  if (status != 0 ){
     fprintf(stderr, "%d\n", status);
     fprintf(stderr, "q_export registration failed: %s\n", lua_tostring(L, -1));
     exit(1);
  }
  return 1; // TODO P4: Why 1?
}
