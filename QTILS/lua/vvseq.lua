-- local Q = require 'Q'
local sub = (require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3").vvsub
local div = (require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3").vvdiv
local abs = (require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2").abs
local max = (require "Q/OPERATORS/F_TO_S/lua/_f_to_s").max
local vsgt = (require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2").vsgt
local sum = (require "Q/OPERATORS/F_TO_S/lua/_f_to_s").sum
local prcsv = (require "Q/OPERATORS/PRINT/lua/print_csv")
local vvmax = (require "Q/QTILS/lua/vvmax").vvmax
local Scalar = require 'libsclr'

local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

local T = {} 
local function vvseq(x, y, s, optargs)

  local mode = "difference"
  if  optargs  and optargs.mode then
    assert(type(optargs.mode) == "string")
    mode = optargs.mode
  end
  assert(x and type(x) == "lVector")
  assert(y and type(y) == "lVector")
-- NOT a valid check  assert(x:fldtype() == y:fldtype())
  assert(is_base_qtype(x:fldtype()))
  assert(is_base_qtype(y:fldtype()))
  assert(s)
  if ( ( type(s) == "number" ) or ( type(s) == "string") ) then 
    s = assert(Scalar.new(s, x:fldtype()))
  elseif ( type(s) == "Scalar" ) then 
    -- NOT a valid check assert(s:fldtype() == x:fldtype())
  else
    assert(nil, "bad type for scalar")
  end
 -- TODO Ramesh Check scalar directly
  local sval = assert(tonumber(Scalar.to_str(s)))
  assert(sval >= 0)
  
  if ( mode == "difference" ) then 
    local xsub = sub(x, y):memo(false):set_name("xsub")
    local xabs = abs(xsub):memo(false):set_name("xabs")
    local xgt  = vsgt(xabs, s):memo(false):set_name("xgt")
    local numgt = sum(xgt):eval():to_num()
    return(numgt == 0)
  elseif ( mode == "ratio" ) then
    return (sum(vsgt(div(abs(sub(x, y)), vvmax(x, y)), s)):eval():to_num() == 0 )
  else
    assert(nil, "Invalid mode = ", mode)
  end
  --================================================
end
T.vvseq = vvseq
require('Q/q_export').export('vvseq', vvseq)
return T
