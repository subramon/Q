#!/home/subramon/lua-5.3.0/src/lua
function chk_add_tbl(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local x_t  = assert(J.tbl)
  assert(chk_tbl_name(x_t))
  local args = assert(J.ARGS)
  assert(type(args) == "table")
  local NumRows = assert(tonumber(args.NumRows))
  assert(math.floor(NumRows) == NumRows)
  assert(NumRows > 0)
end
