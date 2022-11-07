local cutils  = require 'libcutils'
local lgutils = require 'liblgutils'
local is_in   = require 'Q/UTILS/lua/is_in'

local function permute_specialize(invec, p, direction, optargs)
  local subs = {}

  if ( optargs ) then assert(type(optargs) == "table") end 
  assert(type(invec) == "lVector")
  assert(type(p) == "lVector")

  assert(not invec:has_nulls())
  assert(not p:has_nulls())

  assert(type(direction) == "string")
  assert( ( direction == "from" ) or ( direction == "to" ) ) 
  if ( direction == "from" ) then
    error("TO BE IMPLEMENTED")
  elseif ( direction == "to" ) then
    local n1 = invec:num_elements()
    local n2 = p:num_elements()
    subs.num_elements = assert(n1 or n2 )

  else
    error("invalid direction" .. direction)
  end
  subs.width = x:width()
  if ( subs.num_elements <= 127 ) then 
    assert(is_in(subs.perm_qtype, { "I1", "I2", "I4", "I8" }))
  elseif ( subs.num_elements <= 32767 ) then 
    assert(is_in(subs.perm_qtype, { "I2", "I4", "I8" }))
  elseif ( subs.num_elements <= 2147483647 ) then 
    assert(is_in(subs.perm_qtype, { "I4", "I8" }))
  else
    assert(is_in(subs.perm_qtype, { "I8" }))
  end

  subs.direction = direction
  subs.file_name = "_permute_" .. cutils.rdtsc() -- some temp name 
  subs.dir_name  = lgutils.data_dir()
  subs.file_sz   = subs.width * subs.num_elements()
  --========================================
  subs.in_qtype   = invec:qtype()
  subs.perm_qtype = p:qtype()
  subs.fn = "permute_" .. subs.in_qtype .. "_" .. subs.perm_qtype

  subs.tmpl   = "OPERATORS/SORT1/lua/permute.tmpl"
  subs.incdir = "OPERATORS/SORT1/gen_inc/"
  subs.srcdir = "OPERATORS/SORT1/gen_src/"
  subs.incs = { "OPERATORS/SORT1/gen_inc/" }
  return subs
end
return permute_specialize

