local Q = require 'Q'
local plpath = require 'pl.path'
local Scalar = require 'libsclr'
local Vector = require 'libvec'
local lVector = require 'Q/RUNTIME/lua/lVector'
local voting_C   = require 'Q/ML/KNN/lua/voting_custom_code'
local voting_Lua = require 'Q/ML/KNN/lua/voting_n'
local voting_Lua_basic = require 'Q/ML/KNN/lua/voting_n_basic'
local prediction_from_votes = require 'Q/ML/KNN/lua/prediction_from_votes'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'
local split_train_test = require 'Q/ML/UTILS/lua/split_train_test'
local qc = require 'Q/UTILS/lua/q_core'

local function run_voting(args)
  meta_data_file = assert(args.meta_data_file)
  data_file      = assert(args.data_file)
  split_ratio    = assert(args.split_ratio)
  goal           = assert(args.goal)
  implementation = assert(args.implementation)
  
  -- load the data
  local T = Q.load_csv(data_file, dofile(meta_data_file))
  -- break into a training set and a testing set 
  local Train, Test = split_train_test(T, split_ratio)
  local train, g_train, m_train, n_train = extract_goal(Train, goal)
  local test,  g_test,  m_test,  n_test  = extract_goal(Test,  goal)
  -- Current implementation assumes 2 values of goal as 0, 1
  local min_g, _ = Q.min(g_train):eval()
  assert(min_g:to_num() == 0)
  local max_g, _ = Q.max(g_train):eval()
  assert(max_g:to_num() == 1)
  --====================================================
  local vote  = {}
  local num_g = {} 
  -- Vector.reset_timers()
  -- num_g[g] == number of elements in training data where goal == g
  local x
  local time = 0
  for g = 0, 1 do
    local gval = Scalar.new(g, "I4")
    -- x selects all training elements where goal == g
    x = Q.vseq(g_train, gval)
    -- create train_g which has training data for goal == g
    local train_g = {}
    local n_train_g -- number of data points which have goal == g
    for attr, vec in pairs(train) do
      train_g[attr] = Q.where(vec, x):eval()
      n_train_g = train_g[attr]:length()
    end
    
    local t_start = qc.get_time_usec()
    if ( implementation == "C" ) then 
      vote[g] = Q.const({ val = 0, len = n_test, qtype = "F4"}):eval()
      voting_C(train_g, m_train, n_train_g, test, n_test, vote[g], true)
    elseif ( implementation == "Lua" ) then 
      vote[g] = lVector({gen = true, qtype = "F4", has_nulls = false})
      voting_Lua(train_g, m_train, n_train_g, test, n_test, vote[g], true)
    elseif ( implementation == "Lua_basic" ) then 
      vote[g] = 
      voting_Lua_basic(train_g, m_train, n_train_g, test, n_test, true)
    else
      assert(nil, "Unknown implementation" .. implementation)
    end
    -- Q.print_csv(vote[g])
  end
  local g_predicted = prediction_from_votes(vote) 
  local n1, n2 = Q.sum(Q.vveq(g_predicted, g_test)):eval()
  local accuracy = Scalar.new(100, "F8") * n1:conv("F8") / n2:conv("F8")
  local ret_vals = {}
  ret_vals.time = time
  ret_vals.num_correct = n1
  ret_vals.num_total   = n2
  ret_vals.accuracy    = accuracy

  Vector.print_timers()
  if _G['g_time'] then
    for k, v in pairs(_G['g_time']) do
      local niters  = _G['g_ctr'][k] or "unknown"
      local ncycles = tonumber(v)
      print("0," .. k .. "," .. niters .. "," .. ncycles)
    end
  end

  return ret_vals
  -- Q.print_csv({vote[0], vote[1], g_predicted, g_test}, { opfile = "_x" })
 
end
return run_voting
