#!/home/subramon/lua-5.3.0/src/lua
function exec_s_to_f(J, chk_ret)
  local op      = assert(J.op)
  local tbl     = assert(J.tbl)
  local t       = assert(T[tbl])
  local fld     = assert(J.fld)
  local args    = assert(J.ARGS)
  local fldtype = assert(args.FldType)
  local nR      = assert(t.Properties.NumRows)

  --================================================
  if ( op == "Constant" ) then 
    local val     = assert(args.Value);
    local width   = args.Width; if ( width == nil ) then width = "" end
    if ( fldtype == "SC" ) then 
      local  w = assert(tonumber(width))
      assert( ((w>1) and (w<127)), "width out of bounds " .. width)
      _f.Width = width
    else
      local x = assert(tonumber(val));
      _f.MinVal =  x;
      _f.MaxVal =  x;
    end
    -- status, err = s_to_f_const(tbl, fld, nR, fldtype, args.val, width)
    _f.FldType = fldtype
    t[fld] = _f
  elseif  ( op == "Sequence" ) then 
    local start     = assert(args.Start);
    local increment = assert(args.Increment);
    assert(tonumber(start));
    assert(tonumber(increment));
    -- status, err = s_to_f_seq(tbl, fld, nR, fldtype, start, increment)
  elseif  ( op == "Period" ) then 
    local start     = assert(args.Start);
    local increment = assert(args.Increment);
    local period    = assert(args.Period);
    assert(tonumber(start));
    assert(tonumber(increment));
    period = assert(tonumber(period));
    assert(period > 1);
    -- status, err = s_to_f_period(tbl, fld, nR, fldtype, start
    -- , increment, period)
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
end
