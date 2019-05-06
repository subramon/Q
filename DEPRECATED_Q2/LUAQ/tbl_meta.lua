#!/home/subramon/lua-5.3.0/src/lua
function chk_tbl_meta(J)
  local tbl  = assert(J.tbl)
  assert(chk_tbl_name(tbl), "Invalid table name")
  local property = assert(tostring(J.property))
  assert ( ( 
  ( property == "NumRows" )  or 
  ( property == "Exists" )  or 
  ( property == "RefCount" )  or 
  ( property == "Fields" )  or 
  ( property == "All" ) ) , 
  "Unknown table property " .. property)
  return true
end
-- ===============================================================
function exec_tbl_meta(J)
  local tbl = assert(J.tbl)
  local t   = assert ( T[tbl], "Table not found " .. tbl)
  local property = assert(J.property, "ERROR")
  local rtbl = {}
  if ( property == "Fields" ) then 
    local fields = assert(t.Fields)
    local num_fields = 0
    for k, v in pairs(fields) do 
      print(k)
      num_fields = num_fields + 1
      rtbl[num_fields] = k
    end
    if ( num_fields == 0 ) then print("NO FIELDS") end
  else 
    local properties = assert(t.Properties)
    local propval = assert(properties[property], 
    "Property not found " .. property)
    print(propval)
    rtbl[property] = propval
  end
  return rtbl
end
-- ===============================================================
function update_tbl_meta(J)
  return true
end
