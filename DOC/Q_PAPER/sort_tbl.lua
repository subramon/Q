-- g is f sorted in ascending order
-- idx is the permutation implied by the sort
g, idx = Q.sort(T.f, "ascending")
-- permute all other vectors in the Lua table, other than f
for k, v in pairs(T) do 
  if ( v ~= f ) then 
    Q.permute(v, idx)
  end
end
