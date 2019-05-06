local Q       = require 'Q'
local qconsts = require 'Q/UTILS//lua/q_consts'
local eigen   = require 'Q/OPERATORS/PCA/lua/eigen'
local Scalar  = require 'libsclr'

local function pca(X)
  assert(type(X) == "table", "input needs to be a table of lVector")
  assert(#X > 0)
  local n = X[1]:length() -- number of rows of matrix 
  assert(n > 0)
  local p = #X            -- number of columns of marix 
  -- Step 1: standardize the input
  local std_X = {}
  for i, X_i in ipairs(X) do
    assert(type(X_i) == "lVector", "need to pass in a table of column")
    local mean = Q.sum(X_i):eval():to_num() / n
    local diff = Q.vssub(X_i, mean)
    local sum_sqr = Q.sum_sqr(diff):eval():to_num()
    local sigma = math.sqrt( sum_sqr / (n - 1) )
    std_X[i] = Q.vsdiv(diff, sigma):eval()
    print("eval'd x ")
  end
  print("standardization complete")
  print(std_X)
  print(#std_X)

  -- Step 2: compute the variance covariance matrix

  Q.print_csv(std_X)
  local CM = Q.corr_mat(std_X)
  print("corr mat complete")
  
  for i=1,p do
    CM[i]:eval()
    print("Printing CM ", i)
    Q.print_csv(CM[i])
  end

  -- Step 3: find the eigenvectors of the variance covariance matrix
  local eigen_info = eigen(CM)
  print("eigenvectors complete")
  return eigen_info.eigenvectors
  
end
return pca
--return require('Q/q_export').export('pca', pca)
