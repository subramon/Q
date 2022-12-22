local T = {}

-- TODO P4 consider auto-generating following

local function numby(g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  assert(g, "no arg g to numby")
  local status, col = pcall(expander, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute NUMBY")
  return col
end
T.numby = numby
require('Q/q_export').export('numby', numby)

--[[
local function sumby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_sumby'
  assert(x, "no arg x to sumby")
  assert(g, "no arg g to sumby")
  assert(type(ng) == "number")
  local status, col = pcall(expander, x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute SUMBY")
  return col
end
T.sumby = sumby
require('Q/q_export').export('sumby', sumby)


local function raw_maxby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_maxby_minby'
  assert(x, "no arg x to maxby")
  assert(g, "no arg g to maxby")
  local status, col = pcall(expander, "maxby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute MAXBY")
  return col
end
T.raw_maxby = raw_maxby
require('Q/q_export').export('raw_maxby', raw_maxby)


local function raw_minby(x, g, ng, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_maxby_minby'
  assert(x, "no arg x to minby")
  assert(g, "no arg g to minby")
  local status, col = pcall(expander, "minby", x, g, ng, optargs)
  if not status then print(col) end
  assert(status, "Could not execute MINBY")
  return col
end
T.raw_minby = raw_minby
require('Q/q_export').export('raw_minby', raw_minby)


local function minby(x, g, ng, optargs)
  local Scalar    = require 'libsclr'
  local Q         = require 'Q'

  -- call raw_minby
  local minby_col = T.raw_minby(x, g, ng, optargs)
  minby_col:eval()
  -- call numby to get goal value occurance count
  local numby_col = T.numby(g, ng, optargs)
  -- get B1 vector according to occurance count
  local szero = Scalar.new(0, "I8")
  local vsgt_res = Q.vsgt(numby_col, szero):eval()
  -- Set null vector for raw_minby result i.e minby_col
  -- Set null vector if any goal value occurance count is 0
  local vsgt_res_sum = Q.sum(vsgt_res):eval():to_num()
  if vsgt_res_sum ~= vsgt_res:length() then 
    minby_col:make_nulls(vsgt_res)
  end
  return minby_col
end
T.minby = minby
require('Q/q_export').export('minby', minby)


local function maxby(x, g, ng, optargs)
  local Scalar    = require 'libsclr'
  local Q         = require 'Q'

  -- call raw_maxby
  local maxby_col = T.raw_maxby(x, g, ng, optargs)
  maxby_col:eval()
  -- call numby to get goal value occurance count
  local numby_col = T.numby(g, ng, optargs)
  -- get B1 vector according to occurance count
  local szero = Scalar.new(0, "I8")
  local vsgt_res = Q.vsgt(numby_col, szero):eval()
  -- Set null vector for raw_maxby result i.e maxby_col
  -- Set null vector if any goal value occurance count is 0
  local vsgt_res_sum = Q.sum(vsgt_res):eval():to_num()
  if vsgt_res_sum ~= vsgt_res:length() then 
    maxby_col:make_nulls(vsgt_res)
  end
  return maxby_col
end
T.maxby = maxby
require('Q/q_export').export('maxby', maxby)

--]]

return T
