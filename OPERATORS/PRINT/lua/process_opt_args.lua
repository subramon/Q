local function process_opt_args(
  inV, 
  opt_args
  )
  if ( type(inV) == "lVector" ) then inV = { inV } end 
  assert(type(inV) == "table")
  local opfile
  local filter
  local lenV
  local hdr
  
  local outV = inV
  if opt_args then
    assert(type(opt_args) == "table")
    if ( opt_args.header ) then 
      hdr = opt_args.header
      assert(type(hdr) == "string")
      assert(#hdr > 0)
    end 
    if opt_args.opfile ~= nil then
      opfile = opt_args.opfile
      assert(type(opfile) == "string")
      assert(#opfile > 0)
    end
    if opt_args.filter then
      filter = opt_args.filter
    end
  end

  local max_num_in_chunk = 0 
  for i, v in ipairs(outV) do 
    assert(type(v) == "lVector")
    assert(v:is_eov())
    if ( i == 1 ) then
      lenV = v:num_elements()
      max_num_in_chunk = v:max_num_in_chunk()
    else
      assert(lenV == v:num_elements())
      assert(max_num_in_chunk == v:max_num_in_chunk())
    end
  end
  assert(max_num_in_chunk > 0)
  assert(type(lenV) == "number")
  assert(lenV > 0)
  return outV, opfile, filter, lenV, max_num_in_chunk, hdr
end
return  process_opt_args
