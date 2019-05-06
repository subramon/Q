#!/home/subramon/lua-5.3.0/src/lua
function chk_set_meta(J)
  local tbl  = assert(J.tbl)
  local t = assert(T[tbl], "Table not found " .. tbl)

  local fld  = assert(J.fld)

  local action  = assert(J.action)
  if ( action == "set" )  then
  elseif ( action == "unset" ) then
  else assert(nil, "Invalid action " .. set) end 

  print("00000")
  local f = assert((t.Fields)[fld], "Field not found " .. fld)
  print("11111")
  local property = assert(tostring(J.property))
  found = false
  for k, v in pairs(fld_meta_IO.SET_PROPERTY) do
    if ( v == property ) then found = true; break end 
  end
  return true
end
function exec_set_meta (J)
  return
end
-- ===========================================================
function update_set_meta (J)
  -- TODO
  local tbl      = assert(J.tbl)
  local t        = assert(T[tbl])
  local fld      = assert(J.fld)
  local f        = assert(t.Fields[fld])
  local property = assert(J.property)
  local fldtype  = assert(f.FldType)
  local action   = assert(J.action)
  local nR       = t.Properties.NumRows

  if ( action == "unset" )  then
    assert(nil, "NOT IMPLEMENTED")
    return true
  end
  if ( action == "set" )  then
    local val      = assert(J.value)
    val = assert(tonumber(val))
    --=============================================================
    if ( ( property == "NDV" )  or ( property == "ApproxNDV" ) ) then
      assert(val == math.floor(val), "Invalid value " .. val)
      assert( ( val >= 0 ) and ( val <= nR ), "Invalid value " .. val)
      f[property] = val 
      return true
    end
    --=============================================================
    if ( 
      ( property == "Sum" ) or 
      ( property == "Min" ) or
      ( property == "Max" ) 
      ) then
      assert ( ( 
          ( fldtype == "I1" ) or 
          ( fldtype == "I2" ) or
          ( fldtype == "I4" ) or
          ( fldtype == "I8" ) or
          ( fldtype == "F4" ) or
          ( fldtype == "F8" ) 
          ), "Not applicable for fldtype = " .. fldtype)
      if ( ( property == "_Min" ) or ( property == "_Max" ) ) then
        if ( fldtype == "I1" ) then 
          assert( (val >= -128) and ( val < 127 ) ) 
        elseif ( fldtype == "I2" ) then 
          assert( (val >= -65536) and ( val <= 65535 ) ) 
        elseif ( fldtype == "I4" ) then 
          assert( (val >= -2147483648) and ( val <= 2147483647 ) ) 
        elseif ( fldtype == "F4" ) then 
          assert( false, "TODO")
        end
      end
      return true
    end
    --=============================================================
    return true
  end
end
