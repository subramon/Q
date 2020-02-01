local ffi     = require 'ffi'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1opf2f3(op, x, optargs)
  -- Verification
  assert(op == "split")
  assert(type(x) == "lVector", "a must be a lVector ")
  assert(not x:has_nulls())
  
  local sp_fn_name = "Q/OPERATORS/F1OPF2F3/lua/split_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, x:fldtype())
  if not status then print(subs) end

  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local shift  = subs.shift
  local chunk_size = cVector.chunk_size()
  local out_qtype = subs.out_qtype
  local bufsz = chunk_size * qconsts.qtypes[out_qtype].width
  local bufs = {}
  

  local in_cast_as  = subs.in_ctype  .. "*"
  local out_cast_as = subs.out_ctype .. "*"
  local l_chunk_num = 0
  local gens = {}
  local vecs = {}
  local bufs = {}
  for i = 1, 2 do 
    bufs[i] = cmem.new(0)
    local myidx = i
    gens[i] = function(chunk_num)
      assert(chunk_num == l_chunk_num)
      for i = 1, 2 do 
        if ( not bufs[i]:is_data() ) then
          bufs[i] = assert(cmem.new(bufsz))
          bufs[i]:stealable(true)
        end
      end
      
      local in_len, in_chunk = x:get_chunk(l_chunk_num)
      if ( in_len == 0 ) then 
        for i = 1, 2 do 
          bufs[i]:delete()
        end
        for i = 1, 2 do 
          if ( myidx ~= i ) then 
            vecs[i]:eov()
          end
        end
        return 0
      end
      
      local cbufs = {}
      local cst_in_chunk = ffi.cast(in_cast_as,  get_ptr(in_chunk))
      for i = 1, 2 do 
        cbufs[i] = ffi.cast(out_cast_as, get_ptr(bufs[i]))
      end
  
      local start_time = qc.RDTSC()
      local status = qc[func_name](cst_in_chunk, in_len, shift,
        cbufs[1], cbufs[2])
      record_time(start_time, func_name)
      assert(status == 0)
  
      -- Write values to vector
      for i = 1, 2 do 
        if ( myidx ~= i ) then 
          vecs[i]:put_chunk(bufs[i], nil, in_len)
        end
      end
      local is_put_chunk = true
      x:unget_chunk(l_chunk_num)
      l_chunk_num = l_chunk_num + 1
      if ( in_len < chunk_size ) then 
        --[[ TODO 
        for i = 1, 2 do 
          bufs[i]:delete()
        end
        --]]
        for i = 1, 2 do 
          if ( myidx ~= i ) then 
            vecs[i]:eov()
          end
        end
      end
      return in_len, bufs[myidx]
    end
  end
  for i = 1, 2 do 
    vecs[i] = lVector({gen= gens[i], has_nulls=false, qtype=out_qtype} )
  end
  return vecs
end
return expander_f1opf2f3
