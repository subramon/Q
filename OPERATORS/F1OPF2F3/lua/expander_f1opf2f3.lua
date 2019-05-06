local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qtils = require 'Q/QTILS/lua/is_sorted'
local sort = require 'Q/OPERATORS/SORT/lua/sort'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1opf2f3(op, x, optargs)
  -- Verification
  assert(op == "split")
  assert(type(x) == "lVector", "a must be a lVector ")
  
  local sp_fn_name = "Q/OPERATORS/F1OPF2F3/lua/split_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, x:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  
  local shift = subs.shift
  assert(type(shift) == "number")
  assert(shift > 0)
  local sz_out          = qconsts.chunk_size 
  local out_qtype = subs.out_qtype
  local sz_out_in_bytes = sz_out * qconsts.qtypes[out_qtype].width
  local out1_buf = nil
  local out2_buf = nil
  local first_call = true
  
  local out1_vec = lVector({gen=true, has_nulls=false, qtype=out_qtype} )
  local out2_vec = lVector({gen=true, has_nulls=false, qtype=out_qtype} )

  local chunk_idx = 0
  local function f1opf2f3_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx, "chunk_num = " .. chunk_num 
      .. " chunk_idx = " .. chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out1_buf = assert(cmem.new(sz_out_in_bytes))
      out2_buf = assert(cmem.new(sz_out_in_bytes))
      first_call = false
    end
    
    local in_len, in_chunk, in_nn_chunk = x:chunk(chunk_idx)
    -- TODO DISCUSS FOLLOWING WITH KRUSHNAKANT
    if ( in_len == 0 ) then 
      return 0
      --[[
      out1_vec:eov()
      out2_vec:eov()
      return nil, nil, nil, true -- indicating put chunk done
      --]]
    end
    if ( first_call ) then  assert(in_len > 0) end 
    assert(in_nn_chunk == nil, "nulls not supported as yet")
    
    local in_cast_as  = subs.in_ctype  .. "*"
    local out_cast_as = subs.out_ctype .. "*"
    local cst_in_chunk = ffi.cast(in_cast_as,  get_ptr(in_chunk))
    local cst_out1_buf = ffi.cast(out_cast_as, get_ptr(out1_buf))
    local cst_out2_buf = ffi.cast(out_cast_as, get_ptr(out2_buf))

    local start_time = qc.RDTSC()
    local status = qc[func_name](cst_in_chunk, in_len, shift,
      cst_out1_buf, cst_out2_buf)
    record_time(start_time, func_name)
    assert(status == 0, "C error in split")

    -- Write values to vector
    out1_vec:put_chunk(out1_buf, nil, in_len)
    out2_vec:put_chunk(out2_buf, nil, in_len)
    local is_put_chunk = true
    chunk_idx = chunk_idx + 1
    if ( in_len < qconsts.chunk_size ) then 
      out1_vec:eov()
      out2_vec:eov()
    end
    return in_len, nil, nil
  end
  out1_vec:set_generator(f1opf2f3_gen)
  out2_vec:set_generator(f1opf2f3_gen)
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.names ) then
      assert(type(optargs.names) == "table") 
      assert(optargs.names[1] and type(optargs.names[1] == "string"))
      assert(optargs.names[2] and type(optargs.names[2] == "string"))
      assert(optargs.names[1] ~= optargs.names[2])
      out1_vec:set_name(optargs.names[1])
      out1_vec:set_name(optargs.names[2])
    end
  end

  return out1_vec, out2_vec
end

return expander_f1opf2f3
