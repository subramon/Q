local qconsts = require 'Q/UTILS/lua/q_consts'
local qc      = require 'Q/UTILS/lua/q_core'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

  -- This operator produces 2 vectors 
local function expander_getk(a, fval, k, optargs, fopt )
  assert(a)
  assert(type(a) == "string")
  assert( ( a == "min" ) or ( a == "max" ) )
  local sp_fn_name = "Q/OPERATORS/GETK/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))

  assert(fval)
  assert(type(fval) == "lVector", "f1 must be a lVector")
  assert(fval:has_nulls() == false)
  local fval_qtype = fval:fldtype()
  local fval_ctype = qconsts.qtypes[fval_qtype].ctype 
  local fval_width = qconsts.qtypes[fval_qtype].width

  assert(k)
  assert(type(k) == "number")
  assert( (k > 0 ) and ( k < qconsts.chunk_size ) )

  local fopt_qtype, fopt_ctype, fopt_width
  if ( fopt ) then 
    assert(fropt)
    assert(type(fopt) == "lVector", "f1 must be a lVector")
    fopt_qtype = fopt:fldtype()
    fopt_ctype = qconsts.qtypes[fopt_qtype].ctype 
    fopt_width = qconsts.qtypes[fval_qtype].width
    assert(fopt:has_nulls() == false)
  end

  local is_ephemeral = false
  if ( optargs ) then 
    assert(type(optargs) == "table") 
    if ( optargs.is_ephemeral == true ) then 
      is_ephemeral = true
    end
  end
  local status, subs, tmpl = pcall(spfn, f1in_qytpe, fopt_qtype, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not available" .. func_name)
  --=================================================
  -- create a buffer to sort each chunk as you get it 
  local n = qconsts.chunk_size
  local sort_buf_val = cmem.new(n * fval_width, fval_qtype)
  local sort_buf_opt 
  if ( fopt ) then 
    local sort_buf_opt = cmem.new(n * fopt_width, fopt_qtype)
  end
  --=== create buffers for keeping topk from each chunk
  local vbuf1 = cmem.new(k * fval_width, fval_qtype)
  local obuf1 
  if ( fopt ) then 
    local obuf1 = cmem.new(k * fopt_width, fopt_qtype)
  end
  local vbuf2 = cmem.new(k * fval_width, fval_qtype)
  local obuf2 
  if ( fopt ) then 
    local obuf2 = cmem.new(k * fopt_width, fopt_qtype)
  end
  --============================================
  -- create vectors to return 
  local opt_vec 
  local val_vec = lVector{nn= false, gen = true, qtype = fval_qtype, has_nulls = false}
  if ( fopt ) then 
    opt_vec = lVector{nn= false, gen = true, qtype = fopt_qtype, has_nulls = false}
  end
  -- TODO Consider case where there are less than k elements to return

  local chunk_idx = 0
  while ( true ) do
    local fval_len, fval_chunk
    local fopt_len, fopt_chunk
    fval_len, fval_chunk = fval:chunk(chunk_idx)
    if ( fopt ) then 
      fopt_len, fopt_chunk = fopt:chunk(chunk_idx)
      assert(fopt_len == fval_len)
    end
    if ( fval_len == 0 ) then break end 
    local fval_chunk, fopt_chunk
    local fval_chunk = ffi.cast(fval_ctype .. "*",  get_ptr(fval_chunk))
    if ( fopt ) then 
      local fopt_chunk = ffi.cast(fopt_ctype .. "*",  get_ptr(fopt_chunk))
    end
    if ( fopt ) then 
      sort_fn = "sort_asc_" .. fval_ctype .. "_drag_" .. fopt_ctype
    else
      sort_fn = "sort_asc_" .. fval_ctype 
    end
    assert(qc[sort_fn], "function not found " .. sort_fn)
    if ( fopt ) then 
      qc[sort_fn](fval_chunk, fval_len)
    else
      qc[sort_fn](fval_chunk, fopt_chunk, fval_len)
    end
    chunk_idx = chunk_idx + 1
  end
  val_vec:put_chunk(vbuf1, k)
  opt_vec:put_chunk(obuf1, k)
  return val_vec, opt_vec
end
return expander_getk
