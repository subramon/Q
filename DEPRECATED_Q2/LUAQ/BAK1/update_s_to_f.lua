#!/home/subramon/lua-5.3.0/src/lua
function update_s_to_f (M)
  local tbl   = assert(M.tbl)
  local fld   = assert(M.fld)
  local t     = assert(T[tbl])
  t[fld]      = M.f
end
