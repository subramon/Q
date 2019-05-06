#!/home/subramon/lua-5.3.0/src/lua
function chk_f1f2opf3(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  print("In chk_f1f2opf3")
  -- for k, v in pairs(J) do print(k, v) end
  -- print(J.tbl)
  local x_t  = assert(J.tbl)
  local x_f1 = assert(J.fld1)
  local x_f2 = assert(J.fld2)
  local x_op = assert(J.op)

  local t   = assert(T[x_t])
  local f1  = assert(t[x_f1])
  local f2  = assert(t[x_f2])
  assert(type(f1) == "table")
  assert(type(f2) == "table")

  local f1type = assert(f1.fldtype)
  local f2type = assert(f2.fldtype)
  assert(f1type == f2type)
  local is_null_flds = false
  local nulls = ""
  if ( ( f1["nn"] ~= nil ) or ( f2["nn"] ~= nil ) ) then
    is_null_flds = true
    nulls = "nulls_"
  end
  signature = nulls .. f1type .. f2type .. x_op
  print("signature = " .. signature)

  print("PASSED: chk_f1f2opf3")
end
