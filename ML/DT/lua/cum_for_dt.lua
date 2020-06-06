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

local function cum_for_dt(f, g, ng)
  -- f is the data vector
  -- g is the goal vector
  -- ng is the number of values goal can take on
  -- Note: It is implicit that the goal values are 0, 1, ... (ng-1)
  -- Verification
  assert(type(f) == "lVector", "f must be a lVector ")
  assert(type(g) == "lVector", "g must be a lVector ")
  assert(not f:has_nulls())
  assert(not g:has_nulls())
  assert(type(ng) == "number")
  assert(ng > 0)
  -- TODO P3: Check that f is sorted ascending
  --=======================
  local sp_fn_name = "Q/ML/DT/lua/cum_for_dt_specialize"
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

  local v_qtype = subs.v_qtype
  local v_buf_sz = chunk_size * subs.v_width
  local cst_v_as = subs.v_ctype .. "*"

  local c_qtype = subs.c_qtype
  local c_buf_sz = chunk_size * subs.c_width
  local cst_c_as = subs.c_ctype .. "*"

  -- c_cnts_buf is needed to pass cnts_buf to C
  pcall(ffi.cdef, "void *malloc(size_t)")
  pcall(ffi.cdef, " void free(void *ptr)")
  local sz = ng * ffi.sizeof(subs.c_ctype .. " *")
  local c_cnts_buf = ffi.C.malloc(sz)
  c_cnts_buf = ffi.cast(subs.c_ctype .. " **", c_cnts_buf)
  for i = 1, ng do 
    c_cnts_buf[i-1] = ffi.NULL
  end
  --========================
  local a_chunk_idx = 0
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
  for i = 1, ng+1 do 
    if ( i == 1 ) then 
      vectors[i] = lVector({qtype = v_qtype})
      local name = "valvec"
      vectors[i].name = name
      outbufs[name] = cmem.new(0)
    else
      vectors[i] = lVector({qtype = c_qtype})
      local name = "cntvec_" .. tostring(i-1)
      vectors[i].name = name
      outbufs[name] = cmem.new(0)
    end
  end
  --========================
  -- Create array of generators
  local lgens = {}
  for i = 1, ng+1 do 
    local my_name = vectors[i].name
    local function cum_for_dt_gen(chunk_num)
      assert(chunk_num == l_chunk_num)
      if ( not outbufs.valvec:is_data() ) then
        for k, v in pairs(outbufs) do 
          if ( k == "valvec" ) then 
            outbufs[k] = assert(cmem.new({size=v_buf_sz,qtype=v_qtype}))
            outbufs[k]:stealable(true)
          else
            outbufs[k] = assert(cmem.new({size=c_buf_sz,qtype=c_qtype}))
            outbufs[k]:stealable(true)
          end
        end
      end
      repeat
        local f_len, f_chunk = f:get_chunk(l_chunk_num)
        local g_len, g_chunk = g:get_chunk(l_chunk_num)
        assert(f_len == g_len) -- vectors need to be same size 
        if ( f_len == 0 ) then -- no more input, return whatever is in out
          ffi.C.free(c_cnts_buf)
          put_others(my_name, vectors, outbufs, tonumber(n_out[0]))
          return tonumber(n_out[0]), outbufs[my_name]
        end
        local cst_f_chunk  = ffi.cast(cst_f_as,   get_ptr(f_chunk))
        local cst_g_chunk  = ffi.cast(cst_g_as,   get_ptr(g_chunk))
        local cst_v_buf    = ffi.cast(cst_v_as,   get_ptr(outbufs.valvec))
        for i = 1, ng do 
          local name = "cntvec_" .. tostring(i)
          c_cnts_buf[i-1] = ffi.cast(cst_c_as, get_ptr(outbufs[name]))
        end
        local start_time = qc.RDTSC()
        local status = qc[func_name](is_first, cst_f_chunk, cst_g_chunk, 
          ng, fidx, f_len, cst_v_buf, c_cnts_buf, chunk_size, n_out)
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
    lgens[i] = cum_for_dt_gen
  end
  --========================
  -- Now give each vector its generator function
  for i = 1, ng+1 do 
    vectors[i]:set_gen(lgens[i])
  end
  --========================
  -- Now return the vectors in 2 parts
  local  val_vector = vectors[1]
  local cnt_vectors = {}
  for i = 2, ng+1 do 
    cnt_vectors[#cnt_vectors+1] = vectors[i]
  end
  return val_vector, cnt_vectors
end
return cum_for_dt
