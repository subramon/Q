#!/home/subramon/lua-5.3.0/src/lua
function chk_del_tbl(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl))
  -- silent return if table does not exist. 
  local t = T[tbl]
  if ( t == nil ) then return end
  local properties = assert(t.Properties)
  local refcount = assert(properties.RefCount)
  assert (refcount == 0, "Cannot delete. ")
end
