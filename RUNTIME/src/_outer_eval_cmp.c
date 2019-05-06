static int l_sclr_eq(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      "==", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "==", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_eq. ");
  return 2;
}
static int l_sclr_neq(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      "!=", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "!=", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_neq. ");
  return 2;
}
static int l_sclr_geq(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      ">=", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      ">=", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_geq. ");
  return 2;
}
static int l_sclr_leq(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      "<=", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "<=", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_leq. ");
  return 2;
}
static int l_sclr_gt(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      ">", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      ">", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_gt. ");
  return 2;
}
static int l_sclr_lt(lua_State *L)
{
  int status = 0;
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    strcpy(val2.field_type, "F8");
    val2.cdata.valF8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->field_type, "F8",
      "<", ptr_sclr1->cdata, val2.cdata, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "<", ptr_sclr1->cdata, ptr_sclr2->cdata, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_lt. ");
  return 2;
}
