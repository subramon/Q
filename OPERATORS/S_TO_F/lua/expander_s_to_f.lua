local qc      = require 'Q/UTILS/lua/qcore'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local qcfg    =  require 'Q/UTILS/lua/qcfg'
local num_in_chunk =  qcfg.num_in_chunk

return function (a, largs)
  -- Get name of specializer function. By convention
  local sp_fn_name     = "Q/OPERATORS/S_TO_F/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name), "Specializer not found")
  local subs = assert(spfn(largs))
  -- subs should contain 
  -- (1) out_ctype (2) len (3) out_qtype (4) buf_size 
  -- (5) cast_buf_as (6) cargs (7) cast_cargs_as 
  local fn         = assert(subs.fn)
  local cargs      = assert(subs.cargs)
  local cast_cargs = assert(get_ptr(cargs, subs.cast_cargs_as))

  qc.q_add(subs)

  local l_chunk_num = 0
  local buf = assert(cmem.new(0)) -- note we don't really allocate data
  
  local generator = function(chunk_num)
    -- Adding assert on l_chunk_num to have sync between 
    -- expected chunk_num and generator's l_chunk_num state
    --=== START: buffer allocation
    if ( not buf:is_data() ) then 
      buf = assert(
        cmem.new({size = subs.buf_size, qtype = subs.out_qtype}))
      buf:stealable(true)
    end
    --=== STOP : buffer allocation
    --=============================
    assert(chunk_num == l_chunk_num)
    local lb = num_in_chunk * l_chunk_num
    if ( lb >= subs.len) then 
      cargs:delete()
      return 0, nil 
    end 
    local num_elements = subs.len - lb
    -- generate no more than a chunk at a time 
    if ( num_elements > num_in_chunk ) then num_elements = num_in_chunk end
    -- quit if nothing more to produce 
    if ( num_elements <= 0 ) then 
      cargs:delete()
      return 0, nil 
    end
    --=============================
    local cbuf   = get_ptr(buf, subs.cast_buf_as)
    local start_time = cutils.rdtsc()
    qc[fn](cbuf, num_elements, cast_cargs, lb)
    record_time(start_time, fn)
    l_chunk_num = l_chunk_num + 1 
    return num_elements, buf
  end
  return lVector{gen = generator, qtype = subs.out_qtype}
end
