local qconsts = require 'Q/UTILS/lua/q_consts'
local err     = require 'Q/UTILS/lua/error_code'
local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi = require 'ffi'
require 'Q/OPERATORS/PERMUTE/terra/terra_globals'

local t_permute = function(elemtyp, idxtyp)
    return terra(src: &elemtyp, idx: &idxtyp, dest: &elemtyp, n: int, idx_in_src: bool)
      if (idx_in_src) then
        for i = 0,n do
          dest[i]=src[idx[i]]
        end
      else
        for i = 0,n do
          dest[idx[i]] = src[i]
        end
      end
    end
end

t_permute = terralib.memoize(t_permute)

-- TODO can move to lVector/globals? (nn may be issue)
function create_col_with_meta(c)
  return lVector{
    qtype=c:fldtype(),
    gen=true, has_nulls=false}
    -- TODO NULLS, nn_vector
end

return function(val_col, idx_col, idx_in_src)
  assert(type(idx_col) == "lVector", err.INPUT_NOT_COLUMN) 
  assert(type(val_col) == "lVector", err.INPUT_NOT_COLUMN) 
  assert(not idx_col:has_nulls(), "Index column cannot have nulls")
  assert(not val_col:has_nulls(), "As of now, Value column cannot have nulls")
  -- Check the vector val_col for eval(), if not then call eval()
  if not val_col:is_eov() then
    val_col:eval()
  end  

  local val_qtype = assert(val_col:fldtype())
  -- TODO Any asserts  on c_qtype
  --
  local idx_qtype = assert(idx_col:fldtype())
  assert( ( ( idx_qtype == "I1" ) or ( idx_qtype == "I2" ) or 
            ( idx_qtype == "I4" ) or ( idx_qtype == "I8" ) ), 
            "idx column must be integer type")

  local tertyp = terra_types[val_qtype]
  local val_n = val_col:length()
  local idx_n = idx_col:length()
  assert(idx_n == val_n, 
  "index array-length should equal column-length in permute")
  if ( idx_n > 127 ) then assert(idx_qtype ~= "I1") end
  if ( idx_n > 32767 ) then assert(idx_qtype ~= "I2") end
  if ( idx_n > 2147483647 ) then assert(idx_qtype ~= "I4") end
  
  -- get one chunk with everything in it
  local chk_val_n, val_vec, nn_val_vec = val_col:get_all()
  assert (chk_val_n == val_n, "Didn't get full input array in permute()")

  local chk_idx_n, idx_vec, nn_idx_vec = idx_col:get_all()
  assert (chk_idx_n == idx_n, "Didn't get full input array in permute()")

  -- TODO setting size as (val_n - 1) also passes test-cases. WHY ??!!!
  -- local out_arr = t_Array(val_qtype, val_n)
  local out_arr = ffi.malloc(qconsts.qtypes[val_qtype].width * val_n)
  
  -- Below also works, but GC unclear
  --local out_arr = terralib.new(tertyp[val_n])
  if idx_in_src == nil then 
    idx_in_src = true 
  end
  
  t_permute(tertyp, terra_types[idx_qtype])(val_vec, idx_vec, out_arr, val_n, idx_in_src)
  local out_col = create_col_with_meta(val_col)
  out_col:put_chunk(out_arr, nil, val_n) 
  out_col:eov()
  return out_col
end
