local T = {} 
local function vsadd(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsadd", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsadd")
  return col
end
T.vsadd = vsadd
require('Q/q_export').export('vsadd', vsadd)
    
local function vssub(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vssub", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vssub")
  return col
end
T.vssub = vssub
require('Q/q_export').export('vssub', vssub)
    
local function vsmul(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsmul", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsmul")
  return col
end
T.vsmul = vsmul
require('Q/q_export').export('vsmul', vsmul)
    
local function vsdiv(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsdiv", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsdiv")
  return col
end
T.vsdiv = vsdiv
require('Q/q_export').export('vsdiv', vsdiv)
    
local function vsrem(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsrem", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsrem")
  return col
end
T.vsrem = vsrem
require('Q/q_export').export('vsrem', vsrem)
    
local function vseq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vseq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vseq")
  return col
end
T.vseq = vseq
require('Q/q_export').export('vseq', vseq)
    
local function vsneq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsneq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsneq")
  return col
end
T.vsneq = vsneq
require('Q/q_export').export('vsneq', vsneq)
    
local function vsgt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsgt", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsgt")
  return col
end
T.vsgt = vsgt
require('Q/q_export').export('vsgt', vsgt)
    
local function vslt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vslt", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vslt")
  return col
end
T.vslt = vslt
require('Q/q_export').export('vslt', vslt)
    
local function vsgeq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsgeq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsgeq")
  return col
end
T.vsgeq = vsgeq
require('Q/q_export').export('vsgeq', vsgeq)
    
local function vsleq(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vsleq", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vsleq")
  return col
end
T.vsleq = vsleq
require('Q/q_export').export('vsleq', vsleq)
    
local function shift_left(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "shift_left", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute shift_left")
  return col
end
T.shift_left = shift_left
require('Q/q_export').export('shift_left', shift_left)
    
local function shift_right(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "shift_right", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute shift_right")
  return col
end
T.shift_right = shift_right
require('Q/q_export').export('shift_right', shift_right)
    
local function decr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "decr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute decr")
  return col
end
T.decr = decr
require('Q/q_export').export('decr', decr)
    
local function incr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "incr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute incr")
  return col
end
T.incr = incr
require('Q/q_export').export('incr', incr)
    
local function exp(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "exp", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute exp")
  return col
end
T.exp = exp
require('Q/q_export').export('exp', exp)
    
local function log(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "log", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute log")
  return col
end
T.log = log
require('Q/q_export').export('log', log)
    
local function logit(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "logit", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit")
  return col
end
T.logit = logit
require('Q/q_export').export('logit', logit)
    
local function logit2(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "logit2", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit2")
  return col
end
T.logit2 = logit2
require('Q/q_export').export('logit2', logit2)
    
local function reciprocal(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "reciprocal", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute reciprocal")
  return col
end
T.reciprocal = reciprocal
require('Q/q_export').export('reciprocal', reciprocal)
    
local function sqr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "sqr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqr")
  return col
end
T.sqr = sqr
require('Q/q_export').export('sqr', sqr)
    
local function sqrt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "sqrt", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqrt")
  return col
end
T.sqrt = sqrt
require('Q/q_export').export('sqrt', sqrt)
    
local function vabs(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vabs", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vabs")
  return col
end
T.vabs = vabs
require('Q/q_export').export('vabs', vabs)
    
local function vnot(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vnot", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnot")
  return col
end
T.vnot = vnot
require('Q/q_export').export('vnot', vnot)
    
local function vnegate(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "vnegate", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnegate")
  return col
end
T.vnegate = vnegate
require('Q/q_export').export('vnegate', vnegate)
    
local function convert(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1S1OPF2/lua/expander_f1s1opf2'
  local status, col = pcall(expander, "convert", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute convert")
  return col
end
T.convert = convert
require('Q/q_export').export('convert', convert)
    
return T
