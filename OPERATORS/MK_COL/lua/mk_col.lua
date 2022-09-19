local lVector   = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar    = require 'libsclr'
local cmem      = require 'libcmem'
local cutils    = require 'libcutils'
local qcfg      = require 'Q/UTILS/lua/qcfg'
local to_scalar = require 'Q/UTILS/lua/to_scalar'
local rev_lkp   =  require 'Q/UTILS/lua/rev_lkp'

local good_qtypes = rev_lkp({ "I1",  "I2",  "I4", "I8",  "F4", "F8", "B1", "SC"})

local mk_col = function (
  input, 
  qtype, 
  nn_input
  )
  local doc_string = [[ Signature: Q.mk_col(input, qtype, opt_nn_input)
-- creates a column of input table values of input qtype
1) input: array of values
2) qtype: desired qtype of column
3) nn_input: array of nn values
-- returns: column of input values of qtype"
]]
  if input and input == "help" then
    return doc_string
  end

  assert(type(input) == "table")
  local n = #input
  assert(n > 0, "Input table has no entries")
  local has_nulls = false
  if ( nn_input ) then 
    assert(type(nn_input) == "table")
    assert(#nn_input == n)
    has_nulls = true
    for i = 1, n do
      assert(type(nn_input[i] == "boolean")) 
    end
  end
  
  assert(good_qtypes[qtype], qtype)
  local width = cutils.get_width_qtype(qtype)
  local ctype =  cutils.str_qtype_to_str_ctype(qtype)
  local table_length = table.getn(input)
  local length_in_bytes = nil
  local chunk = nil
  
  if ( qtype == "SC" ) then 
    assert(not nn_input) -- no nulls for SC
    --== Figure out width
    width = 0
    for k, v in pairs(input) do 
      assert(type(v) == "string")
      if ( #v > width ) then width = #v end
    end
    width = width + 1 -- add space for nullc
  end
  --=====================
  local col, nn_col, sclr, nn_sclr
  col = lVector({ qtype = qtype, width = width, has_nulls = has_nulls})
  nn_col = lVector({ qtype = "BL", has_nulls = false})
  for k, v in ipairs(input) do
    local val = input[k]
    sclr = Scalar.new(val, qtype)
    --===================
    if ( nn_input ) then 
      local nn_val = nn_input[k]
      assert(type(nn_val) == "boolean")
      nn_sclr = Scalar.new(nn_val, "BL")
      nn_col:put1(nn_sclr)
    end
    --===================
    col:put1(sclr)
  end
  col:eov()
  if ( nn_input ) then 
    nn_col:eov()
    col:set_nulls(nn_col)
  end
  return col
end
return require('Q/q_export').export('mk_col', mk_col)
