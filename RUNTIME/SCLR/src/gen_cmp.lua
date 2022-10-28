function gen_code(T1, T3)
  hdr = [[
#include "q_incs.h"
#include "sclr_struct.h"
static int 
eval_cmp(
    qtype_t qtype1,
    qtype_t qtype2,
    const char *const op,
    SCLR_REC_TYPE sclr1,
    SCLR_REC_TYPE sclr2,
    int *ptr_ret_val
    )
{
  int status = 0;
  int ret_val;
  ]]
  io.write(hdr)
  s1 = 'if ( qtype1 == __QTYPE__ ) {\n'
  s11 = 'else if ( qtype1 == __QTYPE__ ) {\n'
  s2 = '    if ( qtype2 == __QTYPE__ ) {\n'
  s21 = '\n    else if ( qtype2 == __QTYPE__ ) {\n'
  s3 = [[
      if ( strcmp(op, "__CMP__") == 0 ) {
        ret_val = sclr1.val.__QTYPE1__  __CMP__ sclr2.val.__QTYPE2__ ;
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
        str = string.gsub(str, "__CMP__", v3)
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
  *ptr_ret_val = ret_val;
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
  int ret_val;

  SCLR_REC_TYPE *ptr_sclr1 = (SCLR_REC_TYPE *)luaL_checkudata(L, 1, "Scalar");
  if ( lua_isnumber(L, 2) ) { 
    SCLR_REC_TYPE val2; 
    memset(&val2, 0, sizeof(SCLR_REC_TYPE));
    val2.qtype = F8;
    val2.val.f8 = luaL_checknumber(L, 2);
    status = eval_cmp( ptr_sclr1->qtype, F8, 
      "__VAL__", *ptr_sclr1, val2, &ret_val);
  }
  else {
    SCLR_REC_TYPE *ptr_sclr2 = (SCLR_REC_TYPE *)luaL_checkudata(L, 2, "Scalar");
    status = eval_cmp( ptr_sclr1->qtype, ptr_sclr2->qtype, 
      "__VAL__", *ptr_sclr1, *ptr_sclr2, &ret_val);
  }
  cBYE(status);
  lua_pushboolean(L, ret_val);
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


T1 = { "BL", "I1", "I2", "I4", "I8", "F4", "F8" }
T3 = { "==", "!=", ">", "<", ">=", "<=" }
io.output("_eval_cmp.c")
gen_code(T1, T3)
io.close()
-- os.exit()

T = { eq = "==", neq = "!=", gt = ">", lt = "<", geq = ">=", leq = "<=" }

io.output("_outer_eval_cmp.c")
gen_outer(T)
io.close()
