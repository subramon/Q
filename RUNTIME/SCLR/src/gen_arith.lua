function get_output_type(
  f1,
  f2
  )
  if f1 == "I1" then
    if f2 == "I1" then
      f3 = "I1"
    elseif f2 == "I2" then
      f3 = "I2"
    elseif f2 == "I4" then
      f3 = "I4"
    elseif f2 == "I8" then
      f3 = "I8"
    elseif f2 == "F4" then
      f3 = "F4"
    elseif f2 == "F8" then
      f3 = "F8"
    else 
      assert(nil)
    end
  elseif f1 ==  "I2" then
    if f2 == "I1" then
      f3 = "I2"
    elseif f2 == "I2" then
      f3 = "I2"
    elseif f2 == "I4" then
      f3 = "I4"
    elseif f2 == "I8" then
      f3 = "I8"
    elseif f2 == "F4" then
      f3 = "F4"
    elseif f2 == "F8" then
      f3 = "F8"
    else
      assert(nil)
    end
  elseif f1 ==  "I4" then
    if f2 == "I1" then
      f3 = "I4"
    elseif f2 == "I2" then
      f3 = "I4"
    elseif f2 == "I4" then
      f3 = "I4"
    elseif f2 == "I8" then
      f3 = "I8"
    elseif f2 == "F4" then
      f3 = "F4"
    elseif f2 == "F8" then
      f3 = "F8"
    else
      assert(nil)
    end
  elseif f1 ==  "I8" then
    if f2 == "I1" then
      f3 = "I8"
    elseif f2 == "I2" then
      f3 = "I8"
    elseif f2 == "I4" then
      f3 = "I8"
    elseif f2 == "I8" then
      f3 = "I8"
    elseif f2 == "F4" then
      f3 = "F4"
    elseif f2 == "F8" then
      f3 = "F8"
    else
      assert(nil)
    end
  elseif f1 ==  "F4" then
    if f2 == "I1" then
      f3 = "F4"
    elseif f2 == "I2" then
      f3 = "F4"
    elseif f2 == "I4" then
      f3 = "F4"
    elseif f2 == "I8" then
      f3 = "F4"
    elseif f2 == "F4" then
      f3 = "F4"
    elseif f2 == "F8" then
      f3 = "F8"
    else
      assert(nil)
    end
  elseif f1 ==  "F8" then
    f3 = "F8"
  else
    assert(nil)
  end
  return f3
end
----------------------
function gen_code(T1, T3)
  hdr = [[
#include "q_incs.h"
#include "sclr_struct.h"
static int 
eval_arith(
    qtype_t qtype1,
    qtype_t qtype2,
    const char *const op,
    SCLR_REC_TYPE sclr1,
    SCLR_REC_TYPE sclr2,
    SCLR_REC_TYPE *ptr_sclr
    )
{
  int status = 0;
  ]]
  io.write(hdr)
  s1 = 'if ( qtype1 == __QTYPE__ ) {\n'
  s11 = 'else if ( qtype1 == __QTYPE__ ) {\n'
  s2 = '    if ( qtype2 == __QTYPE__ ) {\n'
  s21 = '\n    else if ( qtype2 == __QTYPE__ ) {\n'
  s3 = [[
      if ( strcmp(op, "__AOP__") == 0 ) {
        ptr_sclr->val.__QTYPE3__ = sclr1.val.__QTYPE1__  __AOP__ sclr2.val.__QTYPE2__ ;
      }
]]
  for k1, v1 in pairs(T1) do
    local str = ""
    if ( k1 == 1 ) then 
      str = string.gsub(s1, "__QTYPE__", v1)
    else
      str = string.gsub(s11, "__QTYPE__", v1)
    end
    io.write(str)
    for k2, v2 in pairs(T1) do
      local str = ""
      if ( k2 == 1 ) then 
        str = string.gsub(s2, "__QTYPE__", v2)
      else
        str= string.gsub(s21, "__QTYPE__", v2)
      end
      io.write(str)
      for k3, v3 in pairs(T3) do
        local str = ""
        if ( k3 > 1 ) then io.write("      else") end
        str = string.gsub(s3, "__QTYPE1__", string.lower(v1))
        str = string.gsub(str, "__QTYPE2__", string.lower(v2))
        output_type = get_output_type(v1, v2)
        str = string.gsub(str, "__QTYPE3__", string.lower(output_type))
        str = string.gsub(str, "__AOP__", v3)
        io.write(str)
      end
      io.write("      else /* LOOP 3 */{\n        go_BYE(-1);\n      }\n");
      io.write("    }")
    end
    io.write("    else /* LOOP2 */ {\n      go_BYE(-1);\n    }");
    io.write("  }")
  end
  io.write("  else /* LOOP 1 */{\n    go_BYE(-1);\n  } ");
  tail = [[
BYE:
  return status;
}
]]
  io.write(tail)

end
function gen_outer(T)
  str = [[
static int l_sclr___KEY__(lua_State *L)
{
  int status = 0;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
  SCLR_REC_TYPE *ptr_sclr = (SCLR_REC_TYPE *)lua_newuserdata(L, sizeof(SCLR_REC_TYPE));
  memset(ptr_sclr, '\0', sizeof(SCLR_REC_TYPE));
  status = set_output_qtype(ptr_sclr1->qtype, ptr_sclr2->qtype, ptr_sclr);
  cBYE(status);
  status = eval_arith( ptr_sclr1->qtype, ptr_sclr2->qtype, 
      "__VAL__", *ptr_sclr1, *ptr_sclr2, ptr_sclr);
  cBYE(status);
  /* Add the metatable to the stack. */
  luaL_getmetatable(L, "Scalar");
  /* Set the metatable on the userdata. */
  lua_setmetatable(L, -2);
  return 1;
BYE:
  lua_pushnil(L);
  lua_pushstring(L, "ERROR: sclr___KEY__. ");
  return 2;
}
]]
for k, v in pairs(T) do
  s1 = string.gsub(str, "__KEY__", k)
  s1 = string.gsub(s1, "__VAL__", v)
  io.write(s1)
end

end
-- gen_outer(T3)


T1 = { "I1", "I2", "I4", "I8", "F4", "F8" }
T3 = { "+", "-", "*", "/" }
io.output("_eval_arith.c")
gen_code(T1, T3)
io.close()
-- os.exit()

T = { add = "+", sub = "-", mul = "*", div = "/" }

io.output("_outer_eval_arith.c")
gen_outer(T)
io.close()
