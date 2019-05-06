local is_in    = require 'Q/UTILS/lua/is_in'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local cmem    = require 'libcmem'
local ffi = require 'Q/UTILS/lua/q_ffi'


-- TODO: Need to confirm that input does not have nulls
-- TODO: Need to send length of SC if appropriate?
return function (
  vec_meta,
  optargs
  )

  local in_qtype = vec_meta.field_type
  -- seed values are referred from AB repo seed values
  local seed1 = 961748941
  local seed2 = 982451653
  local seed  = 128356055 
  local out_qtype = "I8"
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.seed1 ) then seed1 = optargs.seed1 end
    if ( optargs.seed2 ) then seed2 = optargs.seed2 end
    if ( optargs.seed  ) then seed  = optargs.seed  end
    if ( optargs.out_qtype) then out_qtype = optargs.out_qtype end
  end

  -- TODO Ideally test with SV as well
  assert(is_in(in_qtype, {"I1", "I2", "I4", "I8", "F4", "F8", "SC"}))
  assert(is_in(out_qtype, {"I1", "I2", "I4", "I8"}))
  assert(type(seed1) == "number")
  assert(type(seed2) == "number")
  assert(type(seed ) == "number")

  local subs = {}
  local in_ctype = qconsts.qtypes[in_qtype].ctype
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.fn = "hash_" .. out_qtype
  subs.in_qtype  = in_qtype
  subs.out_qtype = out_qtype
  subs.in_ctype  = in_ctype
  subs.out_ctype = out_ctype

  subs.seed1 = seed1
  subs.seed2 = seed2
  subs.seed = seed
  if ( in_qtype == "SC" ) then
    subs.stride = vec_meta.field_size
  else
    subs.stride = ffi.sizeof(in_ctype)
  end

  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/HASH/lua/hash.tmpl"
  return subs, tmpl
end
