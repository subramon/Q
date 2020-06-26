local ffi      = require 'ffi'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local cVector  = require 'libvctr'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function put_others(my_name, vectors, outbufs, num_rows)
  assert(type(my_name)  == "string")
  assert(type(vectors)  == "table")
  assert(type(num_rows) == "number")
  assert(num_rows >= 0)
  for k, v in pairs(vectors) do
    if ( v.name ~= my_name ) then
      v:put_chunk(outbufs[v.name], nil, num_rows)
    end
  end
end

local function cum_for_evan_dt(f, g)
  -- f is the data vector
  -- g is the goal vector
  -- Verification
  assert(type(f) == "lVector", "f must be a lVector ")
  assert(type(g) == "lVector", "g must be a lVector ")
  assert(not f:has_nulls())
  assert(not g:has_nulls())
  -- TODO P3: Check that f is sorted ascending
  --=======================
  local sp_fn_name = "Q/ML/DT/lua/cum_for_evan_dt_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, f:qtype(), g:qtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)
  --================================
  -- Note implicit assumption that number of elements for a specific 
  -- data value will be no more than 2^32
  --=================================
  local cst_f_as = subs.f_ctype .. " * "
  local cst_g_as = subs.g_ctype .. " * "
  --=================================
  local chunk_size = cVector.chunk_size()

  -- set up for val vector 
  local v_qtype  = f:qtype()
  local v_ctype  = qconsts.qtypes[v_qtype].ctype
  local v_width  = qconsts.qtypes[v_qtype].width
  local v_buf_sz = chunk_size * v_width
  local cst_v_as = v_ctype .. "*"

  -- set up for sum vector 
  local s_qtype  = "F8"
  local s_ctype  = qconsts.qtypes[s_qtype].ctype
  local s_width  = qconsts.qtypes[s_qtype].width
  local s_buf_sz = chunk_size * s_width
  local cst_s_as = s_ctype .. "*"

  -- set up for cnt vector 
  local c_qtype  = "I4"
  local c_ctype  = qconsts.qtypes[c_qtype].ctype
  local c_width  = qconsts.qtypes[c_qtype].width
  local c_buf_sz = chunk_size * c_width
  local cst_c_as = c_ctype .. "*"

  --========================
  local l_chunk_num = 0
  -- n_out counts number of entries in output buffer
  local x_n_out = cmem.new(ffi.sizeof("uint64_t"))
  local n_out = get_ptr(x_n_out, "I8")
  n_out[0] = 0 
  -- fidx counts how much of input buffer we have consumed
  -- useful because we may have consumed half of it and have
  -- to return because output bufer is full. When we come back
  -- we need to know where we left off
  local x_fidx = cmem.new(ffi.sizeof("uint64_t"))
  local fidx = get_ptr(x_fidx, "I8")
  fidx[0] = 0 
  local is_first = true
  --========================
  -- Create output vectors, except do not set generator just yet
  local vectors = {}
  local outbufs = {}
  -- Note that it is important that val vector must be in position 1 
  -- This is because we nil out position 1 of vectors at end
  vectors[1] = lVector({qtype = v_qtype})
  vectors[1].name = "val"
  vectors[2] = lVector({qtype = s_qtype})
  vectors[2].name = "sum"
  vectors[3] = lVector({qtype = c_qtype})
  vectors[3].name = "cnt"
  outbufs.val = cmem.new(0)
  outbufs.sum = cmem.new(0)
  outbufs.cnt = cmem.new(0)
  --========================
  -- Create array of generators
  local lgens = {}
  for i = 1, 3 do
    local my_name = vectors[i].name
    local function cum_for_evan_dt_gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      if ( not outbufs.val:is_data() ) then
        for k, v in pairs(outbufs) do 
          local buf_sz, qtype
          if ( k == "val" ) then 
            buf_sz = v_buf_sz; qtype = v_qtype
          elseif ( k == "sum" ) then 
            buf_sz = s_buf_sz; qtype = s_qtype
          elseif ( k == "cnt" ) then 
            buf_sz = c_buf_sz; qtype = c_qtype
          else
            error("")
          end
          outbufs[k] = assert(cmem.new({size = buf_sz, qtype = qtype}))
          outbufs[k]:stealable(true)
          outbufs[k]:zero() -- important initialization
        end
      end
      repeat
        local f_len, f_chunk = f:get_chunk(l_chunk_num)
        local g_len, g_chunk = g:get_chunk(l_chunk_num)
        assert(f_len == g_len) -- vectors need to be same size 
        if ( f_len == 0 ) then -- no more input, return whatever is in out
          put_others(my_name, vectors, outbufs, tonumber(n_out[0]))
          return tonumber(n_out[0]), outbufs[my_name]
        end
        local cst_f_chunk  = ffi.cast(cst_f_as,   get_ptr(f_chunk))
        local cst_g_chunk  = ffi.cast(cst_g_as,   get_ptr(g_chunk))
        local cst_v_buf    = ffi.cast(cst_v_as,   get_ptr(outbufs.val))
        local cst_s_buf    = ffi.cast(cst_s_as,   get_ptr(outbufs.sum))
        local cst_c_buf    = ffi.cast(cst_c_as,   get_ptr(outbufs.cnt))
        local start_time = qc.RDTSC()
        local status = qc[func_name](is_first, cst_f_chunk, cst_g_chunk, 
          fidx, f_len, cst_v_buf, cst_s_buf, cst_c_buf, chunk_size, n_out)
        is_first = false
        assert(status == 0)
        record_time(start_time, func_name)
        -- if you have consumed all you got from the a_chunk,
        -- then you need to move to the next chunk
        if ( tonumber(fidx[0]) == f_len ) then
          f:unget_chunk(l_chunk_num)
          g:unget_chunk(l_chunk_num)
          l_chunk_num = l_chunk_num + 1
          fidx[0] = 0
        end
      until ( tonumber(n_out[0]) == chunk_size )
      put_others(my_name, vectors, outbufs, tonumber(n_out[0]))
      return tonumber(n_out[0]), out_bufs[my_name]
    end
    lgens[i] = cum_for_evan_dt_gen
  end
  --========================
  -- Now give each vector its generator function
  for i = 1, 3 do 
    vectors[i]:set_gen(lgens[i])
  end
  --========================
  -- Now return the vectors in 2 parts
  local  val_vector = vectors[1]
  local  sum_vector = vectors[2]
  local  cnt_vector = vectors[3]
  return val_vector, sum_vector, cnt_vector
end
return cum_for_evan_dt
