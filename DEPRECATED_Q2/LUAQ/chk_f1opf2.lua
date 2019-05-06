#!/home/subramon/lua-5.3.0/src/lua
function chk_f1opf2(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local lt = assert(J.tbl)
  assert(chk_tbl_name(lt))
  local metat1 = assert(T[lt], "Table not found " .. lt)
  local lf1 = assert(J.f1)
  local lf2 = assert(J.f2)
  assert(chk_fld_name(lf1))
  assert(chk_fld_name(lf2))
  local metaf1 = assert(metat1[lf1], "No field ", lf1, " in table ", lt)
  assert(J.OP)
  local f1type = assert(metaf1.FldType)
  local args = J.ARGS -- does not have to be provided
  if ( args ~= nil ) then assert(type(args) == "table") end
  local found = false
  --========================================================
  local l0 = assert(f1opf2_IO)
  local l1 = assert(l0.OP)
  found = false
  for k, v in pairs(l1) do 
    if ( v == J.OP ) then found = true; break end
  end
  assert(found, "OP not supported --> " .. J.OP)
  --=== STOP: Verified that op is supported
  local l1 = assert(l0[J.OP])
  local f1types = l1.F1Type
  found = false
  if ( f1type ~= nil ) then
    for k, v in pairs(f1types) do 
      if ( v == f1type ) then found = true; break end
    end
  end
  assert(found, "Type of f1 not supported --> " .. f1type)
  --======================================================
  local xargs = (l0[J.OP]).ARGS;
  local _mandatory = xargs.Mandatory;
  for k, v in pairs(_mandatory) do
    assert(args[v], "Mandatory arg not found " .. v)
  end
  --======================================================
  local newfldtype = nil; local is_newfldtype_provided = false
  if ( args ~= nil ) then 
    newfldtype = args.NewFldType
    if ( newfldtype ) then
      is_newfldtype_provided = true
    end
  end
  --======================================================
  local f2types = l1.F2Type
  if ( type(f2types) == "table" ) then 
    local is_newfldtype_supported = false
    for k, v in pairs(f2types) do
      if ( v == "NewFldType" ) then 
        is_newfldtype_supported = true; 
        break 
      end
    end
    if ( is_newfldtype_supported ) then
      if ( is_newfldtype_provided ) then 
        f2type = newfldtype
      else
        f2type = nil
        for k, v in pairs(f2types) do
          if ( v ~= "NewFldType" ) then 
            f2type = v;
            break 
          end
        end
        assert(f2type, "Unable to determine f2type")
        if ( f2type == "F1Type" ) then 
          f2type = f1type
        end
      end
    else
      if ( is_newfldtype_provided ) then 
        assert(false, "NewFldType provided but not supported")
      else
        for k, v in pairs(f2types ) do 
          if ( k == f1type ) then f2type = v  ; break end
        end
      end
      assert(f2type)
    end
  else
    f2type = f2types;
    if ( f2type == "F1Type" ) then 
      f2type = f1type; 
    elseif ( f2type == "NewFldType" ) then 
      f2type = assert(args.NewFldType)
    end
  end
  -- === augment input with new knowledge
  J.f2type = f2type;
end
