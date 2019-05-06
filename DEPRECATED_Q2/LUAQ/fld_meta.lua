#!/home/subramon/lua-5.3.0/src/lua
function chk_fld_meta(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local tbl  = assert(J.tbl)
  local t = assert(T[tbl], "Table not found")

  local fld  = assert(J.fld)
  local f = (t.Fields)[fld]
  local property = assert(J.property)
  if ( property ~= "Exists" ) then assert(f, "Field not found " .. fld) end

  local good_properties = assert( (T_fld_meta.PROPERTY))
  local found = false
  for k, v in pairs(good_properties ) do 
    -- print("k, v, property = ", k, v, property)
    if ( v == property ) then found = true; break; end
  end
  assert(found, "Unknown field property " .. property)
  return true
end
--=========================================================
function exec_fld_meta (J)
  local tbl      = assert(J.tbl)
  local t        = assert(T[tbl])
  local fld      = assert(J.fld)
  local property = assert(J.property)
  local prop_val = nil
  local f        = (t.Fields)[fld]
  if ( property == "Exists" ) then 
    if ( f == nil ) then
      prop_val = false
    else 
      prop_val = true
    end
  else
    assert(f, "Field not found " .. fld)
    if ( property == "All" ) then 
      prop_val = "TODO: FIX: TO BE IMPLEMENTED"
    else 
      prop_val    = f[property]
      if ( property == "FldType" ) then 
        assert(prop_val)
      else
        if ( prop_val == nil ) then 
          if ( ( property == "HasLenFld" )  or 
               ( property == "HasNullFld" ) ) then
            prop_val = false
          elseif ( 
            ( property == "SortType" ) or
            ( property == "Min" ) or
            ( property == "Max" ) or
            ( property == "Sum" ) or
            ( property == "NDV" ) or
            ( property == "ApproxNDV" ) 
            ) then 
            prop_val = "Unknown"
          else 
            assert(nil, "Unknown property" .. property)
          end
        end
      end
    end
  end
  print(prop_val)
  return true
end
--=========================================================
function update_fld_meta(J)
  return true
end
