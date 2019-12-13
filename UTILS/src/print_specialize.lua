local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local tmpl = qconsts.Q_SRC_ROOT .. '/UTILS/src/print.tmpl'
return function (
  qtype, 
  optargs
  )
    local fmt = ""
    assert(is_base_qtype(qtype))
    if ( optargs ) then
      assert(type(optargs) == "table")
      if (  optargs.format ) then 
        fmt = optargs.format
        assert(type(fmt) == "string")
      end
    end
    local default_fmt = "PR" .. qtype

    local subs = {}
    subs.fn = qtype .. "_to_txt"
    subs.ctype = assert(qconsts.qtypes[qtype].ctype)
    subs.qtype = qtype
    subs.fmt   = fmt
    subs.default_fmt   = default_fmt
    subs.tmpl = tmpl
    return subs
end
