local qconsts = require 'Q/UTILS/lua/q_consts'

function f_to_s_min_chk(
  intype
  )

    local tmpl = 'reduce.tmpl'
    local subs = {}
    -- This includes is just as a demo. Not really needed
    subs.includes = "#include <math.h>\n#include <curl/curl.h>"
    subs.fn = "min_" .. intype 
    subs.intype = qconsts.qtypes[intype].ctype
    subs.reducer = "mcr_sum"
    return subs, tmpl
end
