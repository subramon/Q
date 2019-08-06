local Q       = require 'Q'
local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem    = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

return function(func_name, A, b)
  -- TODO change positive_solver to to general_linear_solver
  assert( ( func_name == "positive_solver") or 
          ( func_name == "full_posdef_positive_solver") )
  assert(type(A) == "table", "A should be a table of columns")
  assert(type(b) == "lVector", "b should be a column")
  local b_qtype = b:fldtype()
  local b_ctype = assert(qconsts.qtypes[b_qtype].ctype)

  assert( (b_qtype == "F4") or (b_qtype == "F8"), 
  "b should be a column of doubles/floats")
  -- Check the vector b for eval(), if not then call eval()
  if not b:is_eov() then
    b:eval()
  end

  for i, a in ipairs(A) do
    assert(type(a) == "lVector", "A["..i.."] should be a column")
    -- Check the vector a for eval(), if not then call eval()
    if not a:is_eov() then
      a:eval()
    end    
    assert(a:fldtype() == b_qtype, 
      "A["..i.."] should be a column of same type as b")
  end

  local n, bptr, nn_bptr = b:get_all()
  assert(n > 0)
  assert(nn_bptr == nil, "b should have no nil elements")

  assert(#A == n, "A should have same width as b")
  local Aptr = assert(get_ptr(cmem.new(n * ffi.sizeof(b_ctype .. " *"))))
  local xptr = assert(cmem.new(n * ffi.sizeof(b_ctype)))
  Aptr = ffi.cast(b_ctype .. " **", Aptr)
  -- Creating separate pointer copy 'copy_xptr' because if we 
  -- modify 'xptr' as below
  -- xptr = ffi.cast('double *', xptr)
  -- then vec:put_chunk() operation fails saying 
  -- "NOT CMEM" type, Line 329 of File vector.c
  local copy_xptr = ffi.cast(b_ctype .. " *", get_ptr(xptr))
  for i = 1, n do
    local Ai_len, Ai_chunk, nn_Ai_chunk = A[i]:get_all()
    assert(Ai_len == n, "A["..i.."] should have same height as b")
    assert(nn_Ai_chunk == nil, "A["..i.."] should have no nil elements")
    Aptr[i-1] = ffi.cast(qconsts.qtypes[b_qtype].ctype .. "*",get_ptr(Ai_chunk))
  end

  assert(qc[func_name], "Symbol not found " .. func_name)
  local casted_bptr = ffi.cast(qconsts.qtypes[b_qtype].ctype .. "*", get_ptr(bptr))
  local status = qc[func_name](Aptr, copy_xptr, casted_bptr, n)
  assert(status == 0, "solver failed")
  assert(qc["full_positive_solver_check"](Aptr, copy_xptr, casted_bptr, n, 0),
         "solution returned by solver "..func_name.." is invalid")

  local x_col = lVector({qtype = b_qtype, gen = true, has_nulls=false})
  x_col:put_chunk(xptr, nil, n)
  x_col:eov()
  return x_col
end
