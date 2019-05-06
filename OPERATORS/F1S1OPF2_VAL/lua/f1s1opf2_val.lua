
local T = {}

local function vsgeq_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vsgeq_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vsgeq_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsgeq_val', vsgeq_val)

local function vsgt_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vsgt_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vsgt_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsgt_val', vsgt_val)

local function vsleq_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vsleq_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vsleq_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsleq_val', vsleq_val)

local function vslt_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vslt_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vslt_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vslt_val', vslt_val)

local function vseq_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vseq_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vseq_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vseq_val', vseq_val)

local function vsneq_val(a, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2_VAL/lua/expander_f1s1opf2_val'
  if type(a) == "lVector" then
    local status, col1, col2 = pcall(expander, "vsneq_val", a, y, optargs)
    if ( not status ) then print(col1) end
    assert(status, "Could not execute vsneq_val")
    return col1, col2
  end
  assert(nil, "Bad arguments to f1s1ofp2_val")
end
require('Q/q_export').export('vsneq_val', vsneq_val)


T.vsgeq_val = vsgeq_val
T.vsgt_val = vsgt_val
T.vsleq_val = vsleq_val
T.vslt_val = vslt_val
T.vseq_val = vseq_val
T.vsneq_val = vsneq_val

return T
