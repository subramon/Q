#!/home/subramon/lua-5.3.0/src/lua
function chk_s_to_f(J)
  assert(J ~= nil)
  assert(type(J) == "table")
  local t = assert(J.tbl)
  assert(chk_tbl_name(t))
  assert(is_tbl(t), "Table not found " .. t)
  local f = assert(J.fld)
  assert(chk_fld_name(f))
  local jop = assert(J.OP)
  assert(J.fld)
  local jargs = assert(J.ARGS)
  assert(type(jargs) == "table")
  local jfldtype      = jargs.FldType
  local jdistribution = jargs.Distribution
  
  local found = false
  --========================================================
  assert(chk_op_supported((s_to_f_IO.OP), jop))
  assert(chk_mandatory_args(((s_to_f_IO[jop].ARGS).Mandatory), jargs))
  assert(chk_fldtype(((s_to_f_IO[jop].ARGS).FldType), jfldtype))
  --======================================================
  local _distribution = s_to_f_IO[jop].ARGS.Distribution
  if ( distribution ~= nil ) then 
    found = false
    for k, v in pairs(_distribution) do
      if (  v == distribution ) then found = true; break; end
    end
    assert(found, "Distribution not supported --> " .. distribution)
    local key = "Distribution_" .. distribution
    local l2 = assert(largs[key])
    _mandatory = assert(l2.Mandatory)
    for k, v in pairs(_mandatory) do
      assert(jargs[v], "Mandatory arg not found " .. v)
    end
  end
  return true
end
--===========================================================
function exec_s_to_f(J, chk_ret)
  local op      = assert(J.OP)
  local tbl     = assert(J.tbl)
  local t       = assert(T[tbl])
  local fld     = assert(J.fld)
  local args    = assert(J.ARGS)
  local fldtype = assert(args.FldType)
  local nR      = assert(tonumber(t.Properties.NumRows))

  cwd  = g_lfs.currentdir()
  tbldir = DOCROOT .. "/" .. tbl
  assert(g_lfs.chdir(tbldir, "ERROR: cd failed to directory " .. tbldir))
  -- not sure we need following TODO P3
  if ( file_exists(fld) ) then os.remove(fld) end
  --================================================
  _f.FldType = fldtype
  if ( op == "Constant" ) then 
    local val     = assert(args.Value);
    local fldlen   = 0;
    if ( args.FldLen ~= nil ) then 
      fldlen = assert(tonumber(args.FldLen), "Field Length not number")
    end

    if ( fldtype == "SC" ) then 
      assert(fldlen ~= 0, "Field Length must be provided for SC")
      assert( ((fldlen>1) and (fldlen <127)), 
        "fldlen out of bounds " .. fldlen)
      _f.FldLen = fldlen
    else
      local x = assert(tonumber(val));
      _f.MinVal =  x;
      _f.MaxVal =  x;
    end
    local status, err = assert(
    qglue.s_to_f_const(fld, nR, fldtype, val, fldlen));
  elseif  ( op == "Sequence" ) then 
    local start     = assert(tonumber(args.Start), 
    "Start not provided or not number")
    local increment = assert(tonumber(args.Increment), 
    "Increment nor provided or not number")
    local status, err = assert(
    qglue.s_to_f_seq(fld, nR, fldtype, start, increment))
  elseif  ( op == "Period" ) then 
    local start     = assert(tonumber(args.Start), 
    "Start not provided or not number")
    local increment = assert(tonumber(args.Increment), 
    "Increment nor provided or not number")
    local period    = assert(tonumber(args.Period), 
    "Period not provided or not number")
    assert(period > 1, "Period must be greater than 1")
    assert(period < nR, "Period must be less than num rows")
    local status, err = assert(
    qglue.s_to_f_period(fld, nR, fldtype, start, increment, period))
  elseif  ( op == "Random" ) then 
    local distribution     = assert(args.Distribution);
    if ( distribution == "Uniform" ) then 
      local minval = assert(tonumber(args.MinVal));
      local maxval = assert(tonumber(args.MaxVal));
      assert(minval < maxval)
    -- status, err = s_to_f_rand_uniform(tbl, fld, nR, fldtype, minval, maxval)
    elseif ( distribution == "Gaussian " ) then
      local mu    = assert(tonumber(args.Mu));
      local sigma = assert(tonumber(args.Sigma));
      assert(sigma > 0)
    -- status, err = s_to_f_rand_gaussian(tbl, fld, nR, fldtype, mu, sigma)
    else 
      assert(false)
    end
  else
    assert(false)
  end
  if ( not status ) then -- TODO confirm this is correct
    t[fld] = nil
  end
  -- augment J with meta data for update function
  J.f   = _f
  assert(g_lfs.chdir(cwd, "ERROR: failed to cd to original directory "))
  return true
end
--===========================================================
function update_s_to_f (J)
  local tbl    = assert(J.tbl)
  local fld    = assert(J.fld)
  local t      = assert(T[tbl])
  if ( t.Fields == nil ) then t.Fields = {} end
  local fields = t.Fields
  fields[fld] = J.f
  return true
end
