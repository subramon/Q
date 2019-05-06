#!/home/subramon/lua-5.3.0/src/lua
function chk_s_to_f(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local t = assert(J.tbl)
  assert(chk_tbl_name(t))
  assert(is_tbl(t), "Table not found" .. t)
  local f = assert(J.fld)
  assert(chk_fld_name(f))
  assert(J.op)
  assert(J.fld)
  local args = assert(J.ARGS)
  assert(type(args) == "table")
  local fldtype = args.FldType
  local distribution = args.Distribution
  
  local found = false
  --========================================================
  local l0 = assert(s_to_f_IO)
  local l1 = assert(l0.OP)
  found = false
  for k, v in pairs(l1) do 
    if ( v == J.op ) then found = true; break end
  end
  assert(found, "OP not supported --> " .. J.op)
  --=== STOP: Verified that op is supported
  local xargs = (l0[J.op]).ARGS;
  local _mandatory = xargs.Mandatory;
  for k, v in pairs(_mandatory) do
    assert(args[v], "Mandatory arg not found " .. v)
  end
  --======================================================
  local _fldtype = xargs.FldType
  found = false
  for k, v in pairs(_fldtype) do
    if (  v == fldtype ) then found = true; break; end
  end
  assert(found, "FldType not supported --> " .. fldtype)
  --======================================================
  local _distribution = xargs.Distribution
  if ( distribution ~= nil ) then 
    found = false
    for k, v in pairs(_distribution) do
      if (  v == distribution ) then found = true; break; end
    end
    assert(found, "Distribution not supported --> " .. distribution)
    local key = "Distribution_" .. distribution
    local l2 = assert(xargs[key])
    _mandatory = assert(l2.Mandatory)
    for k, v in pairs(_mandatory) do
      assert(args[v], "Mandatory arg not found " .. v)
    end
  end
end
