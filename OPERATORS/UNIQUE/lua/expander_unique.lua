local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local sort_utility = require 'Q/OPERATORS/UNIQUE/lua/unique_sort_utility'

local function expander_unique(op, a, b)
  -- Verification
  assert(op == "unique")
  assert(type(a) == "lVector", "a must be a lVector ")
  if b then
    assert(type(b) == "lVector", "b must be a lVector ")
    assert(b:qtype() == "B1", "b must be of type B1")
    assert(a:length() == b:length(), "a and b must be of same length")
  end
  
  local sp_fn_name = "Q/OPERATORS/UNIQUE/lua/unique_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local sz_out          = qconsts.chunk_size 
  local sz_out_in_bytes = sz_out * qconsts.qtypes[a:qtype()].width
  local out_buf = nil
  local cnt_buf = nil
  local sum_buf = nil
  local first_call = true
  local unq_idx = nil
  local in_idx  = nil
  local in_chunk_idx = 0
  local last_unq_element = 0
  local brk_n_write
  
  a = sort_utility(a)
  
  local unique_vec = lVector( { gen = true, has_nulls = false, qtype = a:qtype() } )
  local cnt_vec    = lVector( { gen = true, has_nulls = false, qtype = "I8" } )
  local sum_vec    = nil
  if b then
    sum_vec = lVector( { gen = true, has_nulls = false, qtype = "I8" } )
  end

  local function unique_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    --assert(chunk_num == a_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      out_buf = assert(cmem.new(sz_out_in_bytes))
      cnt_buf = assert(cmem.new(sz_out * ffi.sizeof("int64_t")))
      if b then
        sum_buf = assert(cmem.new(sz_out * ffi.sizeof("int64_t")))
        sum_buf:zero()
      end

      unq_idx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      unq_idx = ffi.cast("uint64_t *", unq_idx)

      in_idx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      in_idx = ffi.cast("uint64_t *", in_idx)
      in_idx[0] = 0
      
      last_unq_element = assert(get_ptr(cmem.new(ffi.sizeof(subs.in_ctype))))
      last_unq_element = ffi.cast(subs.in_ctype .. " *", last_unq_element)

      brk_n_write = assert(get_ptr(cmem.new(ffi.sizeof("bool"))))
      brk_n_write = ffi.cast("bool *", brk_n_write)

      first_call = false
    end
    
    -- Initialize num in out_buf to zero
    unq_idx[0] = 0
    brk_n_write[0] = false
    cnt_buf:zero()

    repeat 
      local in_len, in_chunk, in_nn_chunk = a:chunk(in_chunk_idx)
      local in_B1_len, in_B1_chunk, in_B1_nn_chunk
      if b then
        in_B1_len, in_B1_chunk, in_B1_nn_chunk = b:chunk(in_chunk_idx)
      end
      
      if in_len == 0 then
        if tonumber(unq_idx[0]) > 0 then
          unique_vec:put_chunk(out_buf, nil, tonumber(unq_idx[0]))
          cnt_vec:put_chunk(cnt_buf, nil, tonumber(unq_idx[0]))
          if b then
            sum_vec:put_chunk(sum_buf, nil, tonumber(unq_idx[0]))
          end
        end
        if tonumber(unq_idx[0]) < qconsts.chunk_size then
          unique_vec:eov()
          cnt_vec:eov()
          if b then
            sum_vec:eov()
          end
        end
        return tonumber(unq_idx[0])
        -- return tonumber(cidx[0]), out_buf, nil 
      end
      assert(in_nn_chunk == nil, "Unique vector cannot have nulls")
      
      local casted_in_chunk = ffi.cast( subs.in_ctype .. "*",  get_ptr(in_chunk))
      local casted_unq_buf = ffi.cast( subs.in_ctype .. "*",  get_ptr(out_buf))
      local casted_cnt_buf = ffi.cast( "int64_t *",  get_ptr(cnt_buf))
      local casted_in_B1_chunk = ffi.cast( "uint64_t *", get_ptr(in_B1_chunk))
      local casted_sum_buf = nil
      if b then
        casted_sum_buf = ffi.cast( "int64_t *",  get_ptr(sum_buf))
      end
      local status = qc[func_name](casted_in_chunk, in_len, in_idx, casted_unq_buf, sz_out,
        unq_idx,casted_cnt_buf, last_unq_element, in_chunk_idx, brk_n_write, casted_in_B1_chunk, casted_sum_buf )
      assert(status == 0, "C error in UNIQUE")

      if ( tonumber(in_idx[0]) == in_len ) then
        in_chunk_idx = in_chunk_idx + 1
        in_idx[0] = 0
      end
    until ( tonumber(unq_idx[0]) == sz_out and brk_n_write[0] == true)

    -- Write values to vector
    unique_vec:put_chunk(out_buf, nil, tonumber(unq_idx[0]))
    cnt_vec:put_chunk(cnt_buf, nil, tonumber(unq_idx[0]))
    if b then
      sum_vec:put_chunk(sum_buf, nil, tonumber(unq_idx[0]))
    end
    if tonumber(unq_idx[0]) < qconsts.chunk_size then
      unique_vec:eov()
      cnt_vec:eov()
      if b then
        sum_vec:eov()
      end
    end
    return tonumber(unq_idx[0])
    --return tonumber(cidx[0]), out_buf, nil
  end
  unique_vec:set_generator(unique_gen)
  cnt_vec:set_generator(unique_gen)
  if b then
    sum_vec:set_generator(unique_gen)
  end
  if b then
    return unique_vec, cnt_vec, sum_vec
  else
    return unique_vec, cnt_vec
  end
  --return lVector( { gen = unique_gen, has_nulls = false, qtype = a:qtype() } )
end

return expander_unique
