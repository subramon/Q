local T = {} 
local function vvadd(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvadd", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvadd")
    return col
  end
end
T.vvadd = vvadd
require('Q/q_export').export('vvadd', vvadd)
    
local function vvsub(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvsub", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvsub")
    return col
  end
end
T.vvsub = vvsub
require('Q/q_export').export('vvsub', vvsub)
    
local function vvmul(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvmul", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvmul")
    return col
  end
end
T.vvmul = vvmul
require('Q/q_export').export('vvmul', vvmul)
    
local function vvdiv(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvdiv", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvdiv")
    return col
  end
end
T.vvdiv = vvdiv
require('Q/q_export').export('vvdiv', vvdiv)
    
local function vvrem(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvrem", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvrem")
    return col
  end
end
T.vvrem = vvrem
require('Q/q_export').export('vvrem', vvrem)
    
local function vvand(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvand", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvand")
    return col
  end
end
T.vvand = vvand
require('Q/q_export').export('vvand', vvand)
    
local function vvor(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvor")
    return col
  end
end
T.vvor = vvor
require('Q/q_export').export('vvor', vvor)
    
local function vvxor(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvxor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvxor")
    return col
  end
end
T.vvxor = vvxor
require('Q/q_export').export('vvxor', vvxor)
    
local function vvandnot(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvandnot", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvandnot")
    return col
  end
end
T.vvandnot = vvandnot
require('Q/q_export').export('vvandnot', vvandnot)
    
local function vvgeq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvgeq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvgeq")
    return col
  end
end
T.vvgeq = vvgeq
require('Q/q_export').export('vvgeq', vvgeq)
    
local function vvleq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvleq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvleq")
    return col
  end
end
T.vvleq = vvleq
require('Q/q_export').export('vvleq', vvleq)
    
local function vvgt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvgt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvgt")
    return col
  end
end
T.vvgt = vvgt
require('Q/q_export').export('vvgt', vvgt)
    
local function vvlt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvlt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvlt")
    return col
  end
end
T.vvlt = vvlt
require('Q/q_export').export('vvlt', vvlt)
    
local function vveq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vveq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vveq")
    return col
  end
end
T.vveq = vveq
require('Q/q_export').export('vveq', vveq)
    
local function vvneq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "vvneq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vvneq")
    return col
  end
end
T.vvneq = vvneq
require('Q/q_export').export('vvneq', vvneq)
    
local function concat(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3'
  if type(x) == "lVector" and type(y) == "lVector" then
    local status, col = pcall(expander, "concat", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute concat")
    return col
  end
end
T.concat = concat
require('Q/q_export').export('concat', concat)
    
return T
