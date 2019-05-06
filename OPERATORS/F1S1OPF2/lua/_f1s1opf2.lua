local T = {} 
local function vsadd(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsadd", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsadd")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsadd = vsadd
require('Q/q_export').export('vsadd', vsadd)
    
local function vssub(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vssub", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vssub")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vssub = vssub
require('Q/q_export').export('vssub', vssub)
    
local function vsmul(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsmul", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsmul")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsmul = vsmul
require('Q/q_export').export('vsmul', vsmul)
    
local function vsdiv(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsdiv", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsdiv")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsdiv = vsdiv
require('Q/q_export').export('vsdiv', vsdiv)
    
local function vsrem(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsrem", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsrem")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsrem = vsrem
require('Q/q_export').export('vsrem', vsrem)
    
local function vsand(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsand", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsand")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsand = vsand
require('Q/q_export').export('vsand', vsand)
    
local function vsor(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsor")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsor = vsor
require('Q/q_export').export('vsor', vsor)
    
local function vsxor(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsxor", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsxor")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsxor = vsxor
require('Q/q_export').export('vsxor', vsxor)
    
local function pow(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then
    local op
    assert(y)
    if type(y) == "Scalar" then
      y = y:to_num()
    end
    if y == 2 then
      op = "sqr"
    else
      op = "pow"
    end
    local status, col = pcall(expander, op, x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute pow")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.pow = pow
require('Q/q_export').export('pow', pow)
    
local function shift_left(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "shift_left", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute shift_left")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.shift_left = shift_left
require('Q/q_export').export('shift_left', shift_left)
    
local function vseq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vseq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vseq")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vseq = vseq
require('Q/q_export').export('vseq', vseq)
    
local function vsneq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsneq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsneq")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsneq = vsneq
require('Q/q_export').export('vsneq', vsneq)
    
local function vsgt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsgt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgt")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsgt = vsgt
require('Q/q_export').export('vsgt', vsgt)
    
local function vslt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vslt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vslt")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vslt = vslt
require('Q/q_export').export('vslt', vslt)
    
local function vsgeq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsgeq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsgeq")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsgeq = vsgeq
require('Q/q_export').export('vsgeq', vsgeq)
    
local function vsleq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vsleq", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vsleq")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vsleq = vsleq
require('Q/q_export').export('vsleq', vsleq)
    
local function exp(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "exp", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute exp")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.exp = exp
require('Q/q_export').export('exp', exp)
    
local function sqrt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "sqrt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute sqrt")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.sqrt = sqrt
require('Q/q_export').export('sqrt', sqrt)
    
local function log(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "log", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute log")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.log = log
require('Q/q_export').export('log', log)
    
local function incr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "incr", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute incr")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.incr = incr
require('Q/q_export').export('incr', incr)
    
local function decr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "decr", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute decr")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.decr = decr
require('Q/q_export').export('decr', decr)
    
local function logit(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "logit", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute logit")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.logit = logit
require('Q/q_export').export('logit', logit)
    
local function logit2(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "logit2", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute logit2")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.logit2 = logit2
require('Q/q_export').export('logit2', logit2)
    
local function reciprocal(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "reciprocal", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute reciprocal")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.reciprocal = reciprocal
require('Q/q_export').export('reciprocal', reciprocal)
    
local function abs(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "abs", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute abs")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.abs = abs
require('Q/q_export').export('abs', abs)
    
local function sqr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "sqr", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute sqr")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.sqr = sqr
require('Q/q_export').export('sqr', sqr)
    
local function convert(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "convert", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute convert")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.convert = convert
require('Q/q_export').export('convert', convert)
    
local function vnot(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "vnot", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute vnot")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.vnot = vnot
require('Q/q_export').export('vnot', vnot)
    
local function cum_cnt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "cum_cnt", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute cum_cnt")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.cum_cnt = cum_cnt
require('Q/q_export').export('cum_cnt', cum_cnt)
    
local function shift_left(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "shift_left", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute shift_left")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.shift_left = shift_left
require('Q/q_export').export('shift_left', shift_left)
    
local function shift_right(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  if type(x) == "lVector" then 
    local status, col = pcall(expander, "shift_right", x, y, optargs)
    if ( not status ) then print(col) end
    assert(status, "Could not execute shift_right")
    return col
  end
  assert(nil, "Bad arguments to f1s1ofp2")
end
T.shift_right = shift_right
require('Q/q_export').export('shift_right', shift_right)
    
return T
