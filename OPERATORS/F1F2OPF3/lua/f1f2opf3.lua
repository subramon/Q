local T = {} 
local function vvsub(x, y, optargs)
  local doc_string = [[ Signature: Q.vvsub(x, y, opt_optargs)
  -- This operator performs vvsub of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvsub", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvsub")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvsub = vvsub
require('Q/q_export').export('vvsub', vvsub)
--[===[ TODO P1 Need to add all the rest of these back after testing 
local function vvadd(x, y, optargs)
  local doc_string = [[ Signature: Q.vvadd(x, y, opt_optargs)
  -- This operator performs vvadd of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvadd", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvadd")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvadd = vvadd
require('Q/q_export').export('vvadd', vvadd)
    
    
local function vvmul(x, y, optargs)
  local doc_string = [[ Signature: Q.vvmul(x, y, opt_optargs)
  -- This operator performs vvmul of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvmul", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvmul")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvmul = vvmul
require('Q/q_export').export('vvmul', vvmul)
    
local function vvdiv(x, y, optargs)
  local doc_string = [[ Signature: Q.vvdiv(x, y, opt_optargs)
  -- This operator performs vvdiv of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvdiv", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvdiv")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvdiv = vvdiv
require('Q/q_export').export('vvdiv', vvdiv)
    
local function vvrem(x, y, optargs)
  local doc_string = [[ Signature: Q.vvrem(x, y, opt_optargs)
  -- This operator performs vvrem of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvrem", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvrem")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvrem = vvrem
require('Q/q_export').export('vvrem', vvrem)
    
local function vvgeq(x, y, optargs)
  local doc_string = [[ Signature: Q.vvgeq(x, y, opt_optargs)
  -- This operator performs vvgeq of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvgeq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvgeq")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvgeq = vvgeq
require('Q/q_export').export('vvgeq', vvgeq)
    
local function vvleq(x, y, optargs)
  local doc_string = [[ Signature: Q.vvleq(x, y, opt_optargs)
  -- This operator performs vvleq of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvleq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvleq")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvleq = vvleq
require('Q/q_export').export('vvleq', vvleq)
    
local function vvgt(x, y, optargs)
  local doc_string = [[ Signature: Q.vvgt(x, y, opt_optargs)
  -- This operator performs vvgt of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvgt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvgt")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvgt = vvgt
require('Q/q_export').export('vvgt', vvgt)
    
local function vvlt(x, y, optargs)
  local doc_string = [[ Signature: Q.vvlt(x, y, opt_optargs)
  -- This operator performs vvlt of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvlt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvlt")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvlt = vvlt
require('Q/q_export').export('vvlt', vvlt)
    
local function vveq(x, y, optargs)
  local doc_string = [[ Signature: Q.vveq(x, y, opt_optargs)
  -- This operator performs vveq of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vveq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vveq")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vveq = vveq
require('Q/q_export').export('vveq', vveq)
    
local function vvneq(x, y, optargs)
  local doc_string = [[ Signature: Q.vvneq(x, y, opt_optargs)
  -- This operator performs vvneq of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvneq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvneq")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvneq = vvneq
require('Q/q_export').export('vvneq', vvneq)
    
local function vvand(x, y, optargs)
  local doc_string = [[ Signature: Q.vvand(x, y, opt_optargs)
  -- This operator performs vvand of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvand", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvand")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvand = vvand
require('Q/q_export').export('vvand', vvand)
    
local function vvor(x, y, optargs)
  local doc_string = [[ Signature: Q.vvor(x, y, opt_optargs)
  -- This operator performs vvor of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvor")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvor = vvor
require('Q/q_export').export('vvor', vvor)
    
local function vvxor(x, y, optargs)
  local doc_string = [[ Signature: Q.vvxor(x, y, opt_optargs)
  -- This operator performs vvxor of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvxor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvxor")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvxor = vvxor
require('Q/q_export').export('vvxor', vvxor)
    
local function vvandnot(x, y, optargs)
  local doc_string = [[ Signature: Q.vvandnot(x, y, opt_optargs)
  -- This operator performs vvandnot of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvandnot", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvandnot")
    return col
  end
  assert(nil, "Bad arguments to f1f2opf3")
end
T.vvandnot = vvandnot
require('Q/q_export').export('vvandnot', vvandnot)
    
--]===]
local function concat(x, y, optargs)
  local doc_string = [[ Signature: Q.concat(x, y, opt_optargs)
  -- This operator performs concat of x and y
  ]]
  -- this call has been just done for docstring
  if x and x == "help" then
    return doc_string
  end

  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  local status, col = pcall(expander, "concat", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute concat")
  return col
end
T.concat = concat
require('Q/q_export').export('concat', concat)
    
return T
