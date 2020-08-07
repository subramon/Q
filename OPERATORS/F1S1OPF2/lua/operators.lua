return { 
  -- following need a scalar
  "vsadd",
  "vssub",
  "vsmul",
  "vsdiv",
  "vsrem",
  ------
  "vseq",
  "vsneq",
  "vsgt",
  "vslt",
  "vsgeq",
  "vsleq",
  ------
  "shift_left"
  "shift_right"
  -- unary, do not need a scalar
  "decr", 
  "incr", 
  ---
  "exp", 
  "log", 
  ----
  "logit", 
  "logit2",
  ----
  "reciprocal",
  "sqr",
  "sqrt",
  ---
  "vabs"
  "vnot"
  "vnegate" -- different from vnot 
  ----
  "convert"
}
-- TODO cum_cnt 
