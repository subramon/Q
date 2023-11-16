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
  local formats
  local is_html = false
  
  local outV = inV
  if opt_args then
    assert(type(opt_args) == "table")
    if ( opt_args.header ) then 
      hdr = opt_args.header
      assert(type(hdr) == "string")
      assert(#hdr > 0)
    end 
    if ( opt_args.is_html ~= nil ) then 
      assert(type(opt_args.is_html) == "boolean")
      is_html = opt_args.is_html
    end 
    if opt_args.opfile ~= nil then
      opfile = opt_args.opfile
      assert(type(opfile) == "string")
      assert(#opfile > 0)
    end
    if opt_args.filter then
      filter = opt_args.filter
    end
    if ( opt_args.formats ) then
      assert(type(opt_args.formats) == "table")
      assert(#opt_args.formats == #inV)
      for k, v in ipairs(opt_args.formats) do 
        assert(type(v) == "string")
      end
      formats = opt_args.formats
    end
  end

  local max_num_in_chunk = 0 
  local num_vecs = 0
  for i, v in ipairs(outV) do 
    num_vecs = num_vecs + 1
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
  assert(num_vecs > 0, "Check that you have provided an indexed table")
  assert(max_num_in_chunk > 0)
  assert(type(lenV) == "number")
  assert(lenV > 0)
  return outV, opfile, is_html, filter, lenV, max_num_in_chunk, hdr, formats
end
return  process_opt_args
