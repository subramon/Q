local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1opf2f3(op, x, optargs)
  -- Verification
  assert(op == "split")
  assert(type(x) == "lVector", "a must be a lVector ")
  assert(not x:has_nulls())
  
  local sp_fn_name = "Q/OPERATORS/F1OPF2F3/lua/split_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, x, optargs)
  if not status then print(subs) end

  local func_name = assert(subs.fn)
  qc.q_add(subs)
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local l_chunk_num = 0
  local gens = {}
  local vecs = {}
  local bufs = {}
  local cbufs = {}

  for i = 1, 2 do 
    local myidx = i
    gens[i] = function (chunk_num)
      assert(chunk_num == l_chunk_num)

      local in_len, in_chunk = x:get_chunk(l_chunk_num)
      if ( in_len == 0 ) then 
        for i = 1, 2 do 
          if ( myidx ~= i ) then 
            vecs[i]:eov()
          end
        end
        return 0 
      end 
      local c_in_chunk = get_ptr(in_chunk, subs.in_cast_as)
  
      for i = 1, 2 do 
        bufs[i]  = cmem.new(subs.out_bufsz[i]); bufs[i]:stealable(true)
        cbufs[i] = get_ptr(bufs[i], subs.out_cast_as[i])
      end
    
      local start_time = cutils.rdtsc()
      local status = qc[func_name](c_in_chunk, in_len, 
        subs.shift_by, cbufs[1], cbufs[2])
      record_time(start_time, func_name)
      assert(status == 0)
    
      -- Write values to vector
      for i = 1, 2 do 
        if ( myidx ~= i ) then 
          vecs[i]:put_chunk(bufs[i], in_len)
        end
      end
      x:unget_chunk(l_chunk_num)
      l_chunk_num = l_chunk_num + 1
      if ( in_len < subs.max_num_in_chunk ) then 
        -- call for eov
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
    vecs[i] = lVector({
      gen = gens[i], 
      has_nulls = subs.has_nulls, 
      max_num_in_chunk = subs.max_num_in_chunk, 
      qtype = subs.out_qtypes[i]} )
  end
  return vecs
end
return expander_f1opf2f3
