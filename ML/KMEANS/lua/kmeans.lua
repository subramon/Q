-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
local Scalar = require 'libsclr'
local check = require 'check'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

--================================
local kmeans = {}
local function assignment_step(
  D, -- D is a table of J Vectors of length nI
  nI,
  nJ,
  nK,
  means, -- means is a table of J vectors of length K
  num_in_class
  )
  if debug then 
    local nI, nJ = assert(check.data(D))
    assert(check.means, nJ, nK)
  end
  local dist = {}
  -- dist[k][i] is distance of ith instance from kth mean
  os.execute(" rm -f _temp1 _output1" )
  for k = 1, nK do 
    dist[k] = Q.const({val = 0, qtype = "F4", len = nI})
    for j, Dj in  pairs(D) do
      -- mu_j_k = value of jth feature for kth mean
      local mu_j_k = means[k][j]
      -- print("Cluster/Feature/Mean ", k, j, mu_j_k)
      dist[k] = Q.add(dist[k], Q.sqr(Q.vssub(Dj, mu_j_k)))
      --[[
      local temp = Q.vssub(Dj, mu_j_k):eval()
      Q.print_csv(temp, { opfile = "_temp1" })
      os.execute(" cat _temp1 >> _output1")
      dist[k] = Q.add(dist[k], temp)
      --]]
    end
  end
  --[[
  Q.print_csv(D['feature_7'], { opfile = "_feature_7" })
  os.execute(" rm -f _temp1" )
  assert(nil, "PREMATURE")
  --]]
  for k = 1, nK do 
    dist[k]:eval()
  end
  --[[
  Q.print_csv(dist, { opfile = "_1.csv" })
  assert(nil, "PREMATURE")
  --]]
  -- start by assigning everything to class 1
  local best_clss = Q.const({val = 1, len = nI, qtype = "I4"})
  local best_dist = dist[1]
  -- Q.print_csv(dist[1], { filter = { lb = 0, ub = 15 }})
  -- print("===============")
  -- Q.print_csv(dist[2], { filter = { lb = 0, ub = 15 }})
  
  for k = 2, nK do
    local x = Q.vvleq(best_dist, dist[k])
    best_dist = Q.ifxthenyelsez(x, best_dist, dist[k])
    best_clss = Q.ifxthenyelsez(x, best_clss, Scalar.new(k, "I4"))
  end
  -- verify that no cluster is empty
  local num_in_class = Q.numby(best_clss, nK+1):eval()
  -- We have the "== 1" in check below because clusters are indexed
  -- from 1, 2, ... and hence nothing assigned to cluster 0
  assert(Q.sum(Q.vseq(num_in_class, 0)):eval():to_num() == 1 )
  --[[
  Q.print_csv({best_clss, best_dist}, { opfile = "_1.csv" } )
  assert(nil, "PREMATURE")
  --]]
  return best_clss, num_in_class 
end
--================================
local function update_step(
  D, -- D is a table of nJ Vectors of length nI
  nI,
  nJ,
  nK,
  class, -- Vector of length nI
  num_in_class
  )
  if ( debug ) then 
    assert(type(num_in_class) == "lVector")
    assert(num_in_class:length() == nK+1)
    assert(check.class(class, nK))
    local nI, nJ = assert(check.data(D))
    assert(class:length() == nI)
  end
  local means = {}
  for k = 1, nK do
    local x = Q.vseq(class, k):eval()
    means[k] = {}
    for j, Dj in pairs(D) do
      local numer = Q.sum(Q.where(Dj, x)):eval():to_num() 
      local denom = num_in_class:get_one(k):to_num()
      if ( denom > 0 ) then means[k][j] = numer / denom end
      -- print(numer, denom, " means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end
  return means -- a table of nJ vectors of length nK
end
--================================
local function check_termination(
  old, new, nI, nJ, nK, max_perc_diff, n_iter, max_iter)

  if ( n_iter > max_iter ) then 
    print("Exceeded limit of iterations", max_iter) 
    return true, 0
  end
  n_iter = n_iter + 1 
  if ( debug ) then 
    assert(check.class(old, nK)) 
    assert(check.class(new, nK)) 
  end
  local num_diff = Q.sum(Q.vvneq(old, new)):eval():to_num()
  local this_perc_diff = 100.0*num_diff/nI
  print("n_iter, num_diff, this_perc_diff = ", 
    n_iter, num_diff, this_perc_diff)
  if ( this_perc_diff < max_perc_diff ) then
    return true
  else 
    return false, n_iter
  end 
end
--================================
local function init(seed, nI, nJ, nK)
  local class = Q.rand({seed = seed, len = nI, lb = 1, ub = nK, qtype = "I4"}):eval()
  local num_in_class = Q.numby(class, nK+1):eval()
  -- Q.print_csv(class)
  return class, num_in_class
end
--================================
kmeans.assignment_step = assignment_step
kmeans.update_step = update_step
kmeans.init = init
kmeans.check_termination = check_termination

return kmeans
