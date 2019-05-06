#!/home/subramon/lua-5.3.0/src/lua
function exec_fld_meta (J)
  local tbl      = assert(J.tbl)
  local t        = assert(T[tbl])
  local fld      = assert(J.fld)
  local property = assert(J.property)
  local value = nil
  local f        = t[fld]
  if ( property == "_Exists" ) then 
    if ( f == nil ) then
      value = false
    else 
      value = true
    end
  else
    assert(t)
    if ( property == "_All" ) then 
      value = "TODO: FIX: TO BE IMPLEMENTED"
    else 
      value    = f[property]
      if ( property == "FldType" ) then 
        assert(value)
      else
        if ( value == nil ) then 
          if ( ( property == "_HasLenFld" )  or 
               ( property == "_HasNullFld" ) ) then
            value = false
          elseif ( 
            ( property == "_SortType" ) or
            ( property == "_Min" ) or
            ( property == "_Max" ) or
            ( property == "_Sum" ) or
            ( property == "_NDV" ) or
            ( property == "_ApproxNDV" ) 
            ) then 
            value = "Unknown"
          else 
            print("property ", property)
            assert(false)
          end
        end
      end
    end
  end
  J[property_value] = value
end
