local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local function expander_unpack(invec, out_qtypes, optargs)
  local sp_fn_name = "Q/OPERATORS/UNPACK/lua/unpack_specialize"
  local spfn = assert(require(sp_fn_name))
  subs = assert(spfn(invec, out_qtypes, optargs))
  qc.q_add(subs)
  local func_name = subs.fn 
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local l_chunk_num = 0
  -- this is tricky part where we create multiple generators,
  -- one for each out_qtypes 
  local vectors = {}
  local gens    = {}
  for k, out_qtype in ipairs(out_qtypes) do 
    local my_k = k 
    -- presence of my_k in closure of gen() allows us to distinguish 
    -- between vector for which gen is being called and other vectors
    -- created in this operator 
    local function gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      local in_len, in_chunk = invec:get_chunk(l_chunk_num)
      if ( in_len == 0 ) then
        for k = 1, subs.n_vals do 
          if ( k ~= my_k ) then 
            vectors[k]:eov() -- tell other vectors they are over 
          end
        end
        subs.c_width:delete()
        subs.c_cols:delete()
        return 0  -- tell my vector that it is over 
      end
      --==========================================================
      -- allocate buffers for output 
      local out_bufs = {}
      for k, out_qtype in ipairs(out_qtypes) do
        out_bufs[k] = cmem.new({ subs.bufszs[k], out_qtype})
        out_bufs[k]:zero() 
        out_bufs[k]:stealable(true)
        subs.c_cols[k-1] = get_ptr(out_bufs[k], subs.out_qtypes[k])
      end
      --==========================================================
      local in_ptr = get_ptr(in_chunk, subs.in_qtype)
      local widths = get_ptr(subs.c_width, subs.in_qtype)
      local status = qc[fn](in_ptr, in_len, subs.c_cols, subs.n_vals, 
        widths)
      assert(status == 0)
      -- put chunk for everybody other than me. 
      for k = 1, subs.n_vals do 
        if ( k ~= my_k ) then 
          vectors[k]:put_chunk(out_bufs[k], in_len)
        end
      end
      --=================================================
      if ( in_len < subs.max_num_in_chunk ) then 
        for k = 1, subs.n_vals do 
          if ( k ~= my_k ) then 
            vectors[k]:eov() -- tell other vectors they are over 
          end
        end
        subs.c_width:delete()
        subs.c_cols:delete()
      end
      --=================================================
      invec:unget_chunk(l_chunk_num)
      l_chunk_num = l_chunk_num + 1 
      return in_len, out_bufs[my_k]
    end
    gens[k] = gen
  end
  for k, out_qtype in ipairs(out_qtypes) do 
    local subs = multi_subs[join_type]
    local vargs = {}
    vargs.has_nulls        = false
    vargs.gen              = gens[k]
    vargs.qtype            = out_qtype
    vargs.max_num_in_chunk = subs.max_num_in_chunk
    vectors[k] = lVector(vargs)
  end
  return vectors
end
return expander_unpack
