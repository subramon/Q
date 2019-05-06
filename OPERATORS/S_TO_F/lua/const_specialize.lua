local Scalar   = require 'libsclr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

return function (
  args
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')

  assert(type(args) == "table")
  local val   = args.val
  assert(type(val) ~= nil, "No val provided")
  local qtype = assert(args.qtype, "No qtype provided")
  local len   = assert(args.len, "No length provided")
  local out_ctype = qconsts.qtypes[qtype].ctype
  assert( (is_base_qtype(qtype)) or (qtype == "B1") ) 
  assert(len > 0, "vector length must be positive")

  --=======================
  local subs = {};
  subs.fn = "const_" .. qtype
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/S_TO_F/lua/const.tmpl"

  subs.out_ctype = out_ctype
  subs.len = len
  if ( ( qtype == "F4" ) or ( subs.qtype == "F8" ) )  then 
    subs.format = "%llf"
  else
    subs.format = "%lld"
  end
  subs.out_qtype = qtype
  if ( qtype == "B1" ) then
    tmpl = nil -- this is not generated code 
    assert(type(val) == "boolean")
    -- val needs to be treated as integer for mem_initialize
    if ( val == true )  then subs.val = Scalar.new(1, "I4") end
    if ( val == false ) then subs.val = Scalar.new(0, "I4") end
    subs.out_ctype = "int32_t" 

  else
    subs.val = assert(to_scalar(val, qtype))
  end
  return subs, tmpl
end

