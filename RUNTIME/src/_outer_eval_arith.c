static int l_sclr_sub(lua_State *L)
{
  int status = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  status = set_output_field_type(ptr_sclr1->field_type, ptr_sclr2->field_type, ptr_sclr);
  cBYE(status);
  CDATA_TYPE cdata;
  status = eval_arith( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "-", ptr_sclr1->cdata, ptr_sclr2->cdata, &cdata);
  cBYE(status);
  ptr_sclr->cdata = cdata;
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_sub. ");
  return 2;
}
static int l_sclr_mul(lua_State *L)
{
  int status = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  status = set_output_field_type(ptr_sclr1->field_type, ptr_sclr2->field_type, ptr_sclr);
  cBYE(status);
  CDATA_TYPE cdata;
  status = eval_arith( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "*", ptr_sclr1->cdata, ptr_sclr2->cdata, &cdata);
  cBYE(status);
  ptr_sclr->cdata = cdata;
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_mul. ");
  return 2;
}
static int l_sclr_div(lua_State *L)
{
  int status = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  status = set_output_field_type(ptr_sclr1->field_type, ptr_sclr2->field_type, ptr_sclr);
  cBYE(status);
  CDATA_TYPE cdata;
  status = eval_arith( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "/", ptr_sclr1->cdata, ptr_sclr2->cdata, &cdata);
  cBYE(status);
  ptr_sclr->cdata = cdata;
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_div. ");
  return 2;
}
static int l_sclr_add(lua_State *L)
{
  int status = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  status = set_output_field_type(ptr_sclr1->field_type, ptr_sclr2->field_type, ptr_sclr);
  cBYE(status);
  CDATA_TYPE cdata;
  status = eval_arith( ptr_sclr1->field_type, ptr_sclr2->field_type, 
      "+", ptr_sclr1->cdata, ptr_sclr2->cdata, &cdata);
  cBYE(status);
  ptr_sclr->cdata = cdata;
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr_add. ");
  return 2;
}
