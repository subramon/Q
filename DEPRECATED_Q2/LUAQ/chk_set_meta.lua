#!/home/subramon/lua-5.3.0/src/lua
function chk_set_meta(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl), "Invalid table name")
  local t = assert(T[tbl])

  local fld  = assert(J.fld)
  assert(chk_fld_name(fld), "Invalid field name")

  local action  = assert(J.action)
  if ( action == "set" )  then
  elseif ( action == "unset" ) then
  else assert(false) end

  local f = assert(t[fld])
  local property = assert(tostring(J.property))
  assert ( ( 
  ( property == "_Sum" )  or 
  ( property == "_Min" )  or 
  ( property == "_Max" )  or 
  ( property == "_NDV" )  or 
  ( property == "_ApproxNDV" ) ) , 
  "Unknown field property " .. property)
end
