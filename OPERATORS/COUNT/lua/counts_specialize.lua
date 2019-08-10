local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local Scalar  = require 'libsclr'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local cmem    = require 'libcmem'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/COUNT/lua/counts.tmpl"

return function (
  qtype
  )
    local subs = {}
    if ( qtype == "B1" ) then
      assert(nil, "TODO")
      subs.reduce_qtype = "I1"
    else
      assert(is_base_qtype(qtype), "qtype must be base type")
      subs.op = "counts"
      subs.fn = subs.op .. "_" .. qtype 
      subs.ctype = qconsts.qtypes[qtype].ctype
      subs.qtype = qtype
      subs.reduce_ctype = subs.ctype
      subs.reduce_qtype = qtype

      --==============================
      -- TODO: is it right place to malloc for count variable
      --TODO: is it required to introduce mem_initialize?
      local count_size = ffi.sizeof("uint64_t")
      local count = assert(cmem.new(count_size))
      count = ffi.cast('uint64_t *' , get_ptr(count))
      -- initializing count to 0
      count[0] = 0
      -- subs.count_ctype = 'uint64_t *'
      subs.count = count
    --==============================
      subs.getter = function (x) 
        return Scalar.new(tonumber(count[0]), "I8")
      end
    --==============================
    end
    subs.tmpl = tmpl
    return subs
end
