for i, X_i in ipairs(X) do
  for j, X_j in ipairs(X) do
    A[i][j]=Q.sum(Q.vvmul(X_i,Q.vvmul(w, X_j))):eval()
  end
end
