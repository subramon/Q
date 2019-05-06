local ffi     = require 'Q/UTILS/lua/q_ffi'
local lVector  = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local Scalar    = require 'libsclr'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local to_scalar = require 'Q/UTILS/lua/to_scalar'

local function expander_index(op, a, b)
  -- Verification
  assert(op == "index")
  assert(type(a) == "lVector", "a must be a lVector ")
  assert(b, "input y should be a scalar or a number")
  -- expecting y of type scalar, if not convert to scalar
  b = assert(to_scalar(b, a:fldtype()), "y should be a Scalar or number")
  assert(a:fldtype() == b:fldtype(), "Vector and Scalar should have same type")
  -- TODO Relax above assumption about same fieldtypes later
  
  local sp_fn_name = "Q/OPERATORS/INDEX/lua/index_specialize"
  local spfn = assert(require(sp_fn_name))

  local status, subs, tmpl = pcall(spfn, a:fldtype())
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic Compilation
  assert(qc[func_name], "Symbol not defined " .. func_name)

  local ctype = qconsts.qtypes[a:fldtype()].ctype
  local chunk_index = 0
  
  local function index_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_index)
    -- rslt is a int64_t which will contain first index (if any)
    -- where specified value, b, occurs
    local rslt = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
    rslt = ffi.cast("int64_t *", rslt)
    rslt[0] = -1 -- initialize to some invalid value
    -- TODO local bval = get b value from Sclar b
    local bval = b:to_num()
    while ( true ) do
      local a_len, a_chunk, nn_a_chunk = a:chunk(chunk_index)
      -- vec_pos indicates how many elements of vector we have consumed
      local vec_pos = chunk_index * qconsts.chunk_size
      if ( not a_len ) or ( a_len == 0 ) then 
        -- end of data
        break
      end
      local cst_a_chunk = ffi.cast(ctype .. " *",  get_ptr(a_chunk))
      local status = qc[func_name](cst_a_chunk, a_len, bval, rslt, vec_pos)
      assert(status == 0, "C error in INDEX")
      if tonumber(rslt[0]) ~= -1 then -- search is over
        break
      end
      chunk_index = chunk_index + 1
    end
    if tonumber(rslt[0]) ~= -1  then
      return tonumber(rslt[0])
    else
      return nil
    end
  end
  return index_gen(chunk_index)
end

return expander_index
