#!/home/subramon/lua-5.3.0/src/lua
function exec_tbl_meta (J)
  local _X = {}
  local tbl      = assert(J.tbl)
  local t = T[tbl]
  local property = assert(J.property)
  local value = nil
  if ( property == "_Exists" ) then 
    if ( t == nil ) then
      value = false
    else 
      value = true
    end
  else
    assert(t)
    if ( property == "_All" ) then 
      value = "TODO: FIX: TO BE IMPLEMENTED"
    else 
      value    = assert(t[property])
    end
  end
  _X[property] = value
  return _X
end
