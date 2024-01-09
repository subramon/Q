local T = {} 
    
local function popcount(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "popcount", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute popcount")
  return col
end
T.popcount = popcount
require('Q/q_export').export('popcount', popcount)
    
local function decr(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "decr", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute decr")
  return col
end
T.decr = decr
require('Q/q_export').export('decr', decr)
    
local function incr(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "incr", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute incr")
  return col
end
T.incr = incr
require('Q/q_export').export('incr', incr)
    
local function exp(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "exp", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute exp")
  return col
end
T.exp = exp
require('Q/q_export').export('exp', exp)
    
local function log(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "log", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute log")
  return col
end
T.log = log
require('Q/q_export').export('log', log)
    
local function logit(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "logit", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit")
  return col
end
T.logit = logit
require('Q/q_export').export('logit', logit)
    
local function logit2(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "logit2", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute logit2")
  return col
end
T.logit2 = logit2
require('Q/q_export').export('logit2', logit2)
    
local function reciprocal(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "reciprocal", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute reciprocal")
  return col
end
T.reciprocal = reciprocal
require('Q/q_export').export('reciprocal', reciprocal)
    
local function sqr(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "sqr", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqr")
  return col
end
T.sqr = sqr
require('Q/q_export').export('sqr', sqr)
    
local function sqrt(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "sqrt", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute sqrt")
  return col
end
T.sqrt = sqrt
require('Q/q_export').export('sqrt', sqrt)
    
local function vabs(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vabs", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vabs")
  return col
end
T.vabs = vabs
require('Q/q_export').export('vabs', vabs)
    
local function vabs(x,  optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vabs", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vabs")
  return col
end
T.vabs = vabs
require('Q/q_export').export('vabs', vabs)

local function vnot(x,  optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vnot", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnot")
  return col
end
T.vnot = vnot
require('Q/q_export').export('vnot', vnot)

local function tm_to_epoch(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "tm_to_epoch", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute tm_to_epoch")
  return col
end
T.tm_to_epoch = tm_to_epoch
require('Q/q_export').export('tm_to_epoch', tm_to_epoch)
    
    
local function vnegate(x, optargs)
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  local status, col = pcall(expander, "vnegate", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vnegate")
  return col
end
T.vnegate = vnegate
require('Q/q_export').export('vnegate', vnegate)
    
local function vconvert(x, y, optargs) -- NOTE THE DIFFERENCE
  local expander = require 'Q/OPERATORS/F1OPF2/lua/expander_f1opf2'
  if ( not optargs ) then 
    optargs = {}
  end
  assert(type(optargs) == "table")
  assert(type(y) == "string")
  optargs.newtype = y
  local status, col = pcall(expander, "vconvert", x, optargs)
  if ( not status ) then print(col) end
  assert(status, "Could not execute vconvert")
  return col
end
T.vconvert = vconvert
require('Q/q_export').export('vconvert', vconvert)
    
return T
