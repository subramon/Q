local function dummy(
  X,
  Y,
  N,
  Z
  )
  status = qc.add_I4_I4_I4(X, Y, n, Z)
  assert(status == 0)
end
return dummy
