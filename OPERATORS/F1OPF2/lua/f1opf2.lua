local T = {} 
    
local function decr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "decr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute decr")
  return col
end
T.decr = decr
require('Q/q_export').export('decr', decr)
    
local function incr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "incr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute incr")
  return col
end
T.incr = incr
require('Q/q_export').export('incr', incr)
    
local function exp(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "exp", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute exp")
  return col
end
T.exp = exp
require('Q/q_export').export('exp', exp)
    
local function log(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "log", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute log")
  return col
end
T.log = log
require('Q/q_export').export('log', log)
    
local function logit(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "logit", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit")
  return col
end
T.logit = logit
require('Q/q_export').export('logit', logit)
    
local function logit2(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "logit2", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit2")
  return col
end
T.logit2 = logit2
require('Q/q_export').export('logit2', logit2)
    
local function reciprocal(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "reciprocal", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute reciprocal")
  return col
end
T.reciprocal = reciprocal
require('Q/q_export').export('reciprocal', reciprocal)
    
local function sqr(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "sqr", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqr")
  return col
end
T.sqr = sqr
require('Q/q_export').export('sqr', sqr)
    
local function sqrt(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "sqrt", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqrt")
  return col
end
T.sqrt = sqrt
require('Q/q_export').export('sqrt', sqrt)
    
local function vabs(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vabs", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vabs")
  return col
end
T.vabs = vabs
require('Q/q_export').export('vabs', vabs)
    
local function vnot(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vnot", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnot")
  return col
end
T.vnot = vnot
require('Q/q_export').export('vnot', vnot)
    
local function vnegate(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vnegate", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnegate")
  return col
end
T.vnegate = vnegate
require('Q/q_export').export('vnegate', vnegate)
    
local function convert(x, y, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "convert", x, y, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute convert")
  return col
end
T.convert = convert
require('Q/q_export').export('convert', convert)
    
return T
