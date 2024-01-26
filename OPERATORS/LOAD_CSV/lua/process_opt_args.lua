local qcfg = require 'Q/UTILS/lua/qcfg'
local function process_opt_args(opt_args)
  -- opt_args default values
  -- is_hdr is set to false
  local is_hdr = false
  local is_par = false
  local fld_sep = "comma"
  local memo_len  = qcfg.memo_len -- default 
  local max_num_in_chunk = qcfg.max_num_in_chunk
  local nn_qtype = "BL" -- default 
  if opt_args then
    assert(type(opt_args) == "table", "opt_args must be of type table")
    if opt_args["is_hdr"] ~= nil then
      assert(type(opt_args["is_hdr"]) == "boolean")
      is_hdr = opt_args["is_hdr"]
    end
    if opt_args["is_par"] ~= nil then
      assert(type(opt_args["is_par"]) == "boolean")
      is_par = opt_args["is_par"]
    end
    if opt_args["fld_sep"] ~= nil then
      assert(type(opt_args["fld_sep"]) == "string")
      fld_sep = opt_args["fld_sep"]
      assert( ( fld_sep == "comma" ) or ( fld_sep == "tab" ) )
    end
    if opt_args["memo_len"] ~= nil then
      assert(type(opt_args["memo_len"]) == "number")
      memo_len = opt_args["memo_len"]
    end
    if opt_args["nn_qtype"] ~= nil then
      assert(type(opt_args["nn_qtype"]) == "string")
      nn_qtype = opt_args["nn_qtype"]
      assert((nn_qtype == "B1") or (nn_qtype == "BL"))
    end
    if opt_args["max_num_in_chunk"] ~= nil then
      assert(type(opt_args["max_num_in_chunk"]) == "number")
      max_num_in_chunk = opt_args["max_num_in_chunk"]
      assert(max_num_in_chunk > 0)
      assert( ( ( max_num_in_chunk / 64 ) * 64 ) == max_num_in_chunk)
    end
  end
  return is_hdr, is_par, fld_sep, memo_len, max_num_in_chunk, nn_qtype
end
return  process_opt_args
