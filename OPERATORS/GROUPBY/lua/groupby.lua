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
--=========================================
local function sumby(val, grp, n_grp, cnd, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_sumby'
  local status, col = pcall(expander, "sumby", val, grp, n_grp, cnd, optargs)
  if not status then print(col) end
  assert(status, "Could not execute SUMBY")
  return col
end
T.sumby = sumby
require('Q/q_export').export('sumby', sumby)

--=========================================
local function minby(val, grp, n_grp, cnd, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_sumby'
  local status, col = pcall(expander, "minby", val, grp, n_grp, cnd, optargs)
  if not status then print(col) end
  assert(status, "Could not execute minBY")
  return col
end
T.minby = minby
require('Q/q_export').export('minby', minby)
--=========================================
local function maxby(val, grp, n_grp, cnd, optargs)
  local expander = require 'Q/OPERATORS/GROUPBY/lua/expander_sumby'
  local status, col = pcall(expander, "maxby", val, grp, n_grp, cnd, optargs)
  if not status then print(col) end
  assert(status, "Could not execute maxby")
  return col
end
T.maxby = maxby
require('Q/q_export').export('maxby', maxby)


return T
