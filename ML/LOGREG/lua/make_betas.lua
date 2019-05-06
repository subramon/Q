local plpath  = require 'pl.path'
local Q       = require 'Q'
local log_reg = require 'Q/ML/LOGREG/lua/logistic_regression'
local extract_goal = require 'Q/ML/UTILS/lua/extract_goal'

local function make_betas(
  train_file, 
  meta_data,
  optargs,
  goal,
  num_iters
  )
  --== Check input parameters
  assert(plpath.isfile(train_file))
  if ( not num_iters ) then  num_iters = 10 end
  assert(type(num_iters) == "number") 
  assert(num_iters >= 1 )
  --==========================================
  local T = Q.load_csv(train_file, meta_data, optargs)
  local T_train, g_train, m_train, n_train = extract_goal(T, goal)
  local beta = log_reg.lr_setup(T_train, g_train)
  for i = 1, num_iters do
    beta = assert(log_reg.beta_step(T_train, g_train, beta))
  end
  return beta
end
return make_betas
