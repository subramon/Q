-- https://en.wikipedia.org/wiki/K-means_clustering
local Q = require 'Q'
local Scalar = require 'libsclr'
local check = require 'check'
-- ===========================================
-- nI = number of instances
-- nJ = number of attributes/features
-- nK = number of classes 

--================================
local rough_kmeans = {}
local function assignment_step(
  D, -- D is a table of J Vectors of length nI
  nI,
  nJ,
  nK,
  means -- means is a table of J vectors of length K
  )
  if debug then 
    local nI, nJ = assert(check.data(D))
    assert(check.means, nJ, nK)
  end
  local dist = {}
  -- dist[k][i] is distance of ith instance from kth mean
  for k = 1, nK do 
    dist[k] = Q.const({val = 0, qtype = "F4", len = nI})
    for j, Dj in  pairs(D) do
      -- mu_j_k = value of jth feature for kth mean
      local mu_j_k = means[k][j]
      dist[k] = Q.add(dist[k], Q.sqr(Q.vssub(Dj, mu_j_k)))
    end
  end
  -- start by assigning everything to class 1
  local best_clss = Q.const({val = 1, len = nI, qtype = "I4"})
  local best_dist = dist[1]
  for k = 2, nK do
    local x = Q.vvleq(best_dist, dist[k])
    best_dist = Q.ifxthenyelsez(x, best_dist, dist[k])
    best_clss = Q.ifxthenyelsez(x, best_clss, Scalar.new(k, "I4"))
  end
  -- Evaluate best clss and best distance
  best_dist:eval()
  best_clss:eval()
  -- Compute membership in outer
  local in_outer = {} 
  local alpha = 1.2 -- TODO Input parameter
  for k = 1, nK do
    in_outer[k] = Q.vvleq(dist[k], Q.vsmul(best_dist, alpha))
  end
  num_claimants = Q.const({val = 0, qtype = "I1", len = nI})
  for k = 1, nK do
    num_claimants = Q.vvadd(num_claimants,
                              Q.convert(in_outer[k], "I1"))
  end
  num_claimants:eval()
  inner = Q.ifxthenyelsez(Q.vsgeq(num_claimants, 2), Scalar.new(0, "I4"), 
    best_clss)
  local num_in_outer = {}
  for k = 1, nK do 
    num_in_outer[k] = Q.sum(in_outer[k]):eval():to_num()
  end
  num_in_inner = Q.numby(inner, nK+1):eval()
  return inner, num_in_inner, in_outer, num_in_outer
end
--================================
local function update_step(
  D, -- D is a table of nJ Vectors of length nI
  nI,
  nJ,
  nK,
  inner, -- Vector of length nI
  num_in_inner,
  in_outer,
  num_in_outer
  )
  if ( debug ) then 
    assert(type(num_in_inner) == "lVector")
    assert(num_in_inner:length() == nK+1)
    assert(check.class(inner, nK))
    local nI, nJ = assert(check.data(D))
    assert(inner:length() == nI)
  end
  local wt_inner = 0.5 -- TODO pass as parameter
  local wt_outer = 0.5 -- TODO pass as parameter
  local means = {}
  -- accumulate stuff in "inner approximation"
  for k = 1, nK do 
    local x = Q.vseq(inner, k):eval()
    means[k] = {}
    for j, Dj in pairs(D) do
      means[k][j] = wt_inner * Q.sum(Q.where(Dj, x)):eval():to_num() / 
         num_in_inner:get_one(k):to_num()
    end
  end
  -- accumulate stuff in "outer approximation"
  for k = 1, nK do
    for j, Dj in pairs(D) do
      means[k][j] = means[k][j] + ( wt_outer *
        Q.sum(Q.where(Dj, in_outer[k])):eval():to_num() / 
         num_in_outer[k])
    end
  end
  return means -- a table of nK tables of length nJ
end
--================================
local function init(seed, D, nI, nJ, nK)
  -- TODO Need to pick centroids at random, not just first nK
  local means = {}
  for k = 1, nK do 
    means[k] = {}
    for j, Dj in pairs(D) do 
      means[k][j] = Dj:get_one(k-1):to_num()
    end
  end
  --[[
  for k = 1, nK do 
    for j, Dj in pairs(D) do
      print("means[" .. k .. "][" .. j .. "] = " .. means[k][j])
    end
  end
  --]]
  return means
end
--================================
local function check_termination(
        old_means, new_means, D, nJ, nK, perc_diff, n_iter, max_iter)
  if ( n_iter > max_iter ) then 
    return true, 0
  end
  local max_diff = 0.01 -- TODO pass as parameter
  for k = 1, nK do
    for j, Dj in pairs(D) do
      if ( (math.abs(old_means[k][j] - new_means[k][j]) /
           math.abs(old_means[k][j] + new_means[k][j]) ) > max_diff ) then
         -- print("old/new/k/j = ", old_means[k][j], new_means[k][j], k, j)
        return false, n_iter + 1 
      end
    end
  end
  print("Convergence...", n_iter, max_iter)
  return true, 0
end
--================================
rough_kmeans.assignment_step = assignment_step
rough_kmeans.update_step = update_step
rough_kmeans.init = init
rough_kmeans.check_termination = check_termination

return rough_kmeans
