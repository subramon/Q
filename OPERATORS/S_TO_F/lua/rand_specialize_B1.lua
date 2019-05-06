return function (
  args
  )
  assert(type(args) == "table")
  local qtype = assert(args.qtype)
  assert(qtype == "B1") 
  local probability   = args.probability
  assert(type(probability) == "number")
  assert( ((probability >= 0.0) and (probability <= 1.0)) )
  local seed = args.seed

  if ( seed ) then 
    assert(type(seed) == "number")
  else
    seed = 0 
  end
  local len = args.len
  assert(type(len) == "number")
  assert(len > 0, "vector length must be positive")

  local subs = {};
  --==============================
  subs.fn = "rand_B1"
  subs.len = len
  subs.out_qtype = qtype
  subs.seed = seed
  subs.probability = probability
  return subs
end
