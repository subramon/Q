local function process_opt_args(opt_args)
  -- opt_args default values
  -- is_hdr is set to false
  local is_hdr = false
  local fld_sep = "comma"
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["is_hdr"] ~= nil then
      assert(type(opt_args["is_hdr"]) == "boolean")
      is_hdr = opt_args["is_hdr"]
    end
    if opt_args["fld_sep"] ~= nil then
      assert(type(opt_args["fld_sep"]) == "string")
      fld_sep = opt_args["fld_sep"]
      assert( ( fld_sep == "comma" ) or ( fld_sep == "tab" ) )
    end
  end
  return is_hdr, fld_sep
end
return  process_opt_args
