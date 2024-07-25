local cutils    = require 'libcutils'
local cmem      = require 'libcmem'
local ffi       = require 'ffi'
local qc        = require 'Q/UTILS/lua/qcore'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local get_ptr   = require 'Q/UTILS/lua/get_ptr'
local stringify = require 'Q/UTILS/lua/stringify'

-- =======================
local function min(x, y) if x < y then return x else return y end end
local function max(x, y) if x > y then return x else return y end end
-- =======================


local function cprint( 
  opfile, -- file for destination fo print
  is_html, -- whether to format for HTML 
  where, -- nil or lVector of type B1
  formats, -- how to print a column
  lb, -- number
  ub, -- number
  V, -- table of lVectors to be printed
  max_num_in_chunk
  )
  -- TODO P3: Avoid having all this compilation every time
  local subs = {}
  local func_name = "cprint"
  subs.fn = func_name
  -- IMPORTANT: In specifying files, Do not start with a backslash
  subs.dotc = "OPERATORS/PRINT/src/cprint.c"
  subs.doth = "OPERATORS/PRINT/inc/cprint.h"
  subs.srcs = { "UTILS/src/get_bit_u64.c" }
  local rsutils_src_root = assert(os.getenv("RSUTILS_SRC_ROOT"))
  subs.incs = { "OPERATORS/PRINT/inc/", "UTILS/inc/", 
    rsutils_src_root ..  "/RSUTILS/inc/", }
  subs.structs = nil -- no structs need to be cdef'd
  subs.libs = nil -- no libaries need to be linked
  -- changed to following because of core re-org
  subs.srcs = nil
  local q_root = os.getenv("Q_ROOT")
  subs.libs = { q_root .. "/lib/librsutils.so", }
  qc.q_add(subs); 
-- =======================
  local nC = #V -- determine number of columns to be printed
  assert(nC > 0)
  local chunk_num = math.floor(lb / max_num_in_chunk) -- first usable chunk
  -- adjust chunk_num upwards until it includes lb 
  while ( true ) do
    local clb = chunk_num * max_num_in_chunk
    local cub = clb +  max_num_in_chunk
    if ( ( lb >= clb ) and ( lb < cub ) ) then
      break
    end
    chunk_num = chunk_num + 1 
  end

  -- Create array of qtypes/widths
  local qtypes = {}
  local widths = {}
  for i, v in ipairs(V) do 
    local str_qtype = v:qtype()
    widths[i] = v:width()
    qtypes[i] = cutils.get_c_qtype(str_qtype)
    -- assert(v:check())
  end
  --====================================
  local c_opfile = opfile 
  --======================
  while true do 
    local clb = chunk_num * max_num_in_chunk
    local cub = clb + max_num_in_chunk
    if ( clb >= ub ) then break end -- TODO verify boundary conditions
    -- [xlb, xub) is what we print from this chunk
    local xlb = max(lb, clb) 
    local xub = min(ub, cub)
    local wlen -- length of where fld if any 
    local cfld = ffi.NULL -- pointer to where fld or nil
    --=========================================
    local chk_len -- to make sure all get_chunk() calls return same length 
    local c_data = ffi.C.malloc(ffi.sizeof("void *") * nC)
    c_data = ffi.cast("const void **", c_data)
    -- TODO P4 Implement for B1 in addition to BL
    local nn_c_data = ffi.C.malloc(ffi.sizeof("bool *") * nC)
    nn_c_data = ffi.cast("const bool **", nn_c_data)
    local pre_num_readers = {}
    for i, v in ipairs(V) do
      pre_num_readers[i] = v:num_readers(chunk_num)
    end
    for i, v in ipairs(V) do
      local len, chnk, nn_chnk = v:get_chunk(chunk_num)
      assert(len > 0)
      if ( i == 1 ) then
        chk_len = len
      else
        assert(chk_len == len)
      end
      c_data[i-1] = get_ptr(chnk, "void *")
      nn_c_data[i-1] = ffi.NULL
      if ( nn_chnk ) then 
        assert(type(nn_chnk) == "CMEM")
        nn_c_data[i-1] = get_ptr(nn_chnk, "bool *")
      end 
    end
    --=========================================
    if ( where ) then 
      local wchunk
      wlen, wchunk = where:get_chunk(chunk_num)
      assert(wlen > 0)
      if ( where:qtype() == "BL" ) then 
        cfld = get_ptr(wchunk, "bool *")
      elseif ( where:qtype() == "B1" ) then 
        cfld = get_ptr(wchunk, "uint64_t *")
      else
        error("bad qtype for where Vector ")
      end
      assert(chk_len == wlen) 
      error("NOT YET IMPLEMENTED on THE C side")
    end
    --=========================================
    local chnk_lb = xlb - clb -- relative to chunk
    local chnk_ub = xub - clb -- relative to chunk

    --=======================
    local c_qtypes = ffi.C.malloc(ffi.sizeof("int32_t") * nC)
    c_qtypes = ffi.cast("int32_t *", c_qtypes)
    for i, v in ipairs(V) do
      c_qtypes[i-1] = qtypes[i]
    end
    --=======================
    local c_widths = ffi.C.malloc(ffi.sizeof("int32_t") * nC)
    c_widths = ffi.cast("int32_t *", c_widths)
    for i, v in ipairs(V) do
      c_widths[i-1] = widths[i]
    end
    --=======================
    local c_formats = ffi.NULL
    if ( formats ) then 
      c_formats = ffi.C.malloc(ffi.sizeof("char *") * nC)
      c_formats = ffi.cast("char **", c_formats)
      for i, v in ipairs(V) do
        c_formats[i-1] = stringify(formats[i])
      end
    end
    --=======================
    local status = qc[func_name](c_opfile, is_html, cfld, c_data, nn_c_data,
      ffi.new("int", nC),
      ffi.new("uint64_t", chnk_lb),
      ffi.new("uint64_t", chnk_ub), 
      c_qtypes, c_widths, c_formats)
    assert(status == 0)
    ffi.C.free(c_qtypes)
    ffi.C.free(c_widths)
    if ( c_formats ~= ffi.NULL ) then 
      for i, v in ipairs(V) do
        ffi.C.free(c_formats[i-1])
      end
      ffi.C.free(c_formats) 
    end 
    ffi.C.free(c_data)
    -- release chunks 
    if ( where ) then 
      where:unget_chunk(chunk_num)
    end
    for i, v in ipairs(V) do
      v:unget_chunk(chunk_num)
    end
    for i, v in ipairs(V) do
      assert(pre_num_readers[i] == v:num_readers(chunk_num))
    end
    chunk_num = chunk_num + 1 
  end
  -- print("===================== CPRINT ================")
  return true
end
return cprint
