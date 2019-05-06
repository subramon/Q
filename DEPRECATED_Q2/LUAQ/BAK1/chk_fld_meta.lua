#!/home/subramon/lua-5.3.0/src/lua
function chk_fld_meta(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl), "Invalid table name")
  local t = assert(T[tbl])

  local fld  = assert(J.fld)
  assert(chk_fld_name(fld), "Invalid field name")
  local property = assert(tostring(J.property))
  assert ( ( 
  ( property == "_SortType" )  or 
  ( property == "_FldType" )  or 
  ( property == "_HasNullFld" )  or 
  ( property == "_HasLenFld" )  or 
  ( property == "_Min" )  or 
  ( property == "_Max" )  or 
  ( property == "_Sum" )  or 
  ( property == "_NDV" )  or 
  ( property == "_ApproxNDV" )  or 
  ( property == "_All" ) ) , 
  "Unknown field property " .. property)
end
