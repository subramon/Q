return {
  add = "vvadd_specialize",
  sub = "vvsub_specialize",
  mul = "vvmul_specialize",
  div = "vvdiv_specialize",
  rem = "vvrem_specialize",

  b_and  = "vvand_specialize",
  b_or   = "vvor_specialize",
  xor    = "vvxor_specialize",
  andnot = "vvandnot_specialize",

  eq  = "vveq_specialize",
  neq = "vvneq_specialize",
  geq = "vvgeq_specialize",
  leq = "vvleq_specialize",
  gt  = "vvgt_specialize",
  lt  = "vvlt_specialize",

  concat = "vvconcat_specialize",
}
