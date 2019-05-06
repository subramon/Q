#!/home/subramon/lua-5.3.0/src/lua
function update_set_meta (J)
  -- TODO
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl      = assert(J.tbl)
  local t        = assert(T[tbl])
  local fld      = assert(J.fld)
  local f        = assert(t[fld])
  local property = assert(J.property)
  local fldtype  = assert(f._FldType)
  local action   = assert(J.action)

  if ( action == "unset" )  then
  elseif ( action == "set" )  then
    local val      = assert(J.value)
    val = assert(tonumber(val))
    if ( ( property == "NDV" )  or ( property == "ApproxNDV" ) ) then
      local nR       = t.Properties.NumRows
      assert(val == math.floor(val))
      assert( ( val >= 0 ) and ( val <= nR ) ) 
      f[property] = val 
    elseif ( 
      ( property == "_Sum" ) or 
      ( property == "_Min" ) or
      ( property == "_Max" ) 
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
    else
      assert(false)
    end
  else
    print("action = ", action)
    assert(false)
  end
  _junk = {}
  _junk.name = value
  return _junk
end
