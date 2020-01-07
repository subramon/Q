local ffi     = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local utils   = require 'Q/UTILS/lua/utils'
local qc      = require 'Q/UTILS/lua/q_core'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local sort_utility = require 'Q/OPERATORS/JOIN/lua/join_sort_utility'

local function chk_params(op, src_lnk, src_fld, dst_lnk, join_type, optargs)
  assert(op == "join")
  assert(type(join_type) == "string", "Join type must be a string")
  assert( ( join_type == "min" ) or ( join_type == "max" ) or
          ( join_type == "sum" ) or ( join_type == "exists" ) or
          ( join_type == "min_idx" ) or ( join_type == "max_idx" ) or
          ( join_type == "and" ) or ( join_type == "or" ) or
          ( join_type == "count" ) or ( join_type == "any" ),
          "Invalid join type " .. join_type)

  assert(type(src_lnk) == "lVector", "src_lnk must be a lVector")
  assert(type(src_fld) == "lVector", "src_fld must be a lVector")
  assert(type(dst_lnk) == "lVector", "dst_lnk must be a lVector")

  assert(src_lnk:length() == src_fld:length(),
  "src_lnk and src_fld must have same number of rows")
  assert(src_lnk:fldtype() == dst_lnk:fldtype(),
  "src_lnk and dst_lnk must have same qtype")

  -- TODO : are we supporting nulls in src_lnk and dst_lnk?
  assert(src_lnk:has_nulls() == false)
  assert(dst_lnk:has_nulls() == false)

  assert(is_base_qtype(src_lnk:fldtype()),
  "join not supported for fldtype " .. src_lnk:fldtype())
  assert(is_base_qtype(src_fld:fldtype()),
  "join not supported for fldtype " .. src_fld:fldtype())
  assert(is_base_qtype(dst_lnk:fldtype()),
  "join not supported for fldtype " .. dst_lnk:fldtype())

  if optargs then
    assert(type(optargs) == "table")
  end
end


local function expander_join(op, src_lnk, src_fld, dst_lnk, join_type, optargs)
  -- validate parameters
  chk_params(op, src_lnk, src_fld, dst_lnk, join_type, optargs)

  local sp_fn_name = "Q/OPERATORS/JOIN/lua/join_specialize"
  local spfn = assert(require(sp_fn_name))
  -- calling specializer
  local status, subs = pcall(spfn, src_lnk:fldtype(), src_fld:fldtype(), src_lnk:fldtype(), join_type)
  if not status then print(subs) end
  assert(status, "Specializer failed " .. sp_fn_name)
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not defined " .. func_name)
  local sz_out = qconsts.chunk_size
  local sz_dst = sz_out * qconsts.qtypes[subs.dst_fld_qtype].width
  local dst_fld = nil
  local first_call = true
  local aidx  = nil
  local didx  = nil
  local a_chunk_idx = 0  -- chunk idx for src_lnk & src_fld
  local nn_dst_fld
  local is_first
  local c_chunk_idx = 0  -- chunk idx for dst_lnk

  -- sorting the src_lnk and dst_lnk if not sorted
  src_lnk, src_fld = sort_utility(src_lnk, src_fld)
  dst_lnk = sort_utility(dst_lnk)

  local function join_gen(chunk_num)
    -- Adding assert on chunk_idx to have sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == c_chunk_idx)
    if ( first_call ) then 
      -- allocate buffer for output
      dst_fld = assert(cmem.new(sz_dst, subs.dst_fld_qtype))
      aidx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      aidx = ffi.cast("uint64_t *", aidx)
      aidx[0] = 0
      nn_dst_fld = assert(cmem.new(sz_out))
      didx = assert(get_ptr(cmem.new(ffi.sizeof("uint64_t"))))
      didx = ffi.cast("uint64_t *", didx)
      
      is_first = assert(get_ptr(cmem.new(ffi.sizeof("bool"))))
      is_first = ffi.cast("bool *", is_first)
      is_first[0] = true

      first_call = false
    end

    didx[0] = 0
    
    -- Initialize to its value
    if optargs and optargs.default_val then
      assert(type(optargs.default_val) == "number" or type(optargs.default_val) == "Scalar",
        "optargs.default_val must be of type number or Scalar")
      if type(optargs.default_val) ==  "Scalar" then
        assert(optargs.default_val:fldtype() == subs.dst_fld_qtype,
          "optargs.default_val Scalar value and src_fld must be same of same qtype")
        -- converting scalar to number
        optargs.default_val = optargs.default_val:to_num()
      end
      dst_fld:set_default(optargs.default_val)
    elseif join_type == "max" or join_type == "any" then
      dst_fld:set_min()
    elseif join_type == "min" then
      dst_fld:set_max()
    elseif join_type == "max_idx" or join_type == "min_idx" then
      -- initialize dst_fld to -1
      dst_fld:set_min()
    else
      dst_fld:zero()
    end
    nn_dst_fld:zero()
    
    repeat
      local a_len, a_chunk, a_nn_chunk = src_lnk:chunk(a_chunk_idx)
      local b_len, b_chunk, b_nn_chunk = src_fld:chunk(a_chunk_idx)
      local c_len, c_chunk, c_nn_chunk = dst_lnk:chunk(c_chunk_idx)
      if c_len == 0 then
        break
      end
      local casted_c_buf   = ffi.cast( subs.dst_lnk_ctype .. "*",  get_ptr(c_chunk))
      local casted_out_buf = ffi.cast( subs.dst_fld_ctype .. "*",  get_ptr(dst_fld))
      local casted_out_nn_buf = ffi.cast( "uint64_t *",  get_ptr(nn_dst_fld))
      if a_len == 0 then
        -- there is no src chunk to process but dst is not yet processed
        -- process dst_lnk
        local lb = tonumber(didx[0]) + 1
        local ub = c_len-1
        for i = lb, ub do
          if i > 0 and casted_c_buf[i] == casted_c_buf[i-1] then
            casted_out_buf[i] = casted_out_buf[i-1]
            -- TODO: update respective nn buf
          else
            didx[0] = ub
            break
          end
        end
        assert(tonumber(didx[0])+1 == c_len)
        break
      end
      assert(a_len == b_len)
      --TODO: null to be supported?
      assert(a_nn_chunk == nil, "Null is not supported")
      assert(b_nn_chunk == nil, "join vector cannot have nulls")
      -- vec_pos indicates how many elements of vector we have consumed
      local vec_pos = a_chunk_idx * qconsts.chunk_size

      local casted_a_chunk = ffi.cast( subs.src_lnk_ctype .. "*",  get_ptr(a_chunk))
      local casted_b_chunk = ffi.cast( subs.src_fld_ctype .. "*",  get_ptr(b_chunk))
      local status = qc[func_name](join_type, casted_a_chunk, casted_b_chunk, aidx, a_len, casted_c_buf, casted_out_buf, casted_out_nn_buf, c_len, didx, sz_out, vec_pos, is_first)
      assert(status == 0, "C error in JOIN")
      if ( tonumber(aidx[0]) == a_len ) then
        a_chunk_idx = a_chunk_idx + 1
        aidx[0] = 0
      end
    until ( tonumber(didx[0]) + 1 == c_len and is_first[0] == true )
    c_chunk_idx = c_chunk_idx + 1
    return tonumber(didx[0]) + 1, dst_fld, nil
  end
  return lVector( { gen = join_gen, has_nulls = false, qtype = subs.dst_fld_qtype } )
end

return expander_join
