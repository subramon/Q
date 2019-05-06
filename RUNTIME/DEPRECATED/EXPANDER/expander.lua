-- Work in Progress
get subs and tmpl from xxx_specialize
Look for $TEMPLATES/<dataflow>_${tmpl} file
Look for Q_FUNCTIONS['subs.fn']
If it exists, then all is well.
  T = dofile(
fn_prototype= gen_doth(subs.fn, T)
Else ffi.cdef(fn_prototype)
