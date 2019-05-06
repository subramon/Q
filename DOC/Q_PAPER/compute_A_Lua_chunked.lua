repeat 
  for i, X_i in ipairs(X) do
    for j, X_j in ipairs(X) do
      status = A[i][j]:next()
    end
  end
until not status
