local plpath = require 'pl.path'
local srcdir = "../gen_src/"
local incdir = "../gen_inc/"
if ( not plpath.isdir(srcdir) ) then plpath.mkdir(srcdir) end
if ( not plpath.isdir(incdir) ) then plpath.mkdir(incdir) end
local gen_code =  require("Q/UTILS/lua/gen_code")

local qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local join_type = {"sum", "min", "max", "min_idx", "max_idx", "count", "any"}
-- local join_type = {"sum", "min", "max", "min_idx", "max_idx", "count", "and", "or"}

local num_produced = 0
local status, reason
local sp_fn = assert(require("Q/OPERATORS/JOIN/lua/join_specialize"))

local function generate_files(src_lnk_qtype, src_fld_qtype, join_type, args)
  local status, subs = pcall(sp_fn, src_lnk_qtype, src_fld_qtype, join_type, args)
  if ( status ) then
    assert(type(subs) == "table")
    gen_code.doth(subs, incdir)
    gen_code.dotc(subs, srcdir)
    print("Produced ", subs.fn)
    num_produced = num_produced + 1
  else
    assert(nil, subs)
  end
  return true
end

--TODO: For (min, max, any) or (min_idx, max_idx, count), generated files are same for same qtype, avoid redundancy
for _, op in ipairs(join_type) do
  for _, src_lnk_qtype in ipairs(qtypes) do
    for _, src_fld_qtype in ipairs(qtypes) do
      status, reason = pcall(generate_files, src_lnk_qtype, src_fld_qtype, src_lnk_qtype, op )
      if not status then print(reason) end
      assert(status, 
     "Failed to generate files" .. src_lnk_qtype .. src_fld_qtype .. src_lnk_qtype)
    end
  end
end
assert(num_produced > 0)
