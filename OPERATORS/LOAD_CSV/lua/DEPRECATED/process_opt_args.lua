local function process_opt_args(opt_args)
  -- opt_args default values
  -- is_hdr is set to false
  local is_hdr = false
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["is_hdr"] ~= nil then
      assert(type(opt_args["is_hdr"]) == "boolean", 
      "type of is_hdr is not boolean")
      is_hdr = opt_args["is_hdr"]
    end
  end
  return is_hdr
end
return  process_opt_args
