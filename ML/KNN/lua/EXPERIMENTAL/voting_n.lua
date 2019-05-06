local Q        = require 'Q'
local Scalar   = require 'libsclr'
local voting_1 = require 'Q/ML/KNN/lua/voting_1'

local function voting_n(
  T_train, -- table of m lVectors of length n_train
  m,
  n_train,
  T_test, -- table of m lVectors of length n_test
  n_test,
  output,
  chk_params
  )
  --==============================================
  if ( chk_params ) then --[[ TODO P3 --]] end 

  local qtype = T_train[1]:fldtype()
  for i = 1, n_test do
    x = {}
    for k = 1, m do 
      x[k] = T_test[k]:get_one(i-1) -- Note the -1 diff between Lua and C
    end
    vote = Q.sum(voting_1(T_train, m, n_train, x, false)):eval()
    vote = vote:conv(qtype)
    output:put1(vote)
  end
  output:eov()
end
return voting_n
