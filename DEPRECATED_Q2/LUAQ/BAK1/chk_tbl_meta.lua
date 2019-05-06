#!/home/subramon/lua-5.3.0/src/lua
function chk_tbl_meta(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl), "Invalid table name")
  local property = assert(tostring(J.property))
  assert ( ( 
  ( property == "NumRows" )  or 
  ( property == "Exists" )  or 
  ( property == "RefCount" )  or 
  ( property == "All" ) ) , 
  "Unknown table property " .. property)
end
