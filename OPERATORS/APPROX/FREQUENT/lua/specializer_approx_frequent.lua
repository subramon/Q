local qtypes = require 'Q/OPERATORS/APPROX/FREQUENT/lua/qtypes'

return function(elem_qtype)
  assert(qtypes[elem_qtype], "approx_frequent specializer called with invalid qtype")
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local subs = {}
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/APPROX/FREQUENT/lua/approx_frequent.tmpl"
  subs.elem_qtype = elem_qtype
  subs.elem_ctype = qconsts.qtypes[elem_qtype].ctype
  subs.freq_qtype = 'I8'
  subs.freq_ctype = 'uint64_t'
  subs.out_len_ctype = 'uint32_t'
  subs.fn = "approx_frequent_"..elem_qtype
  subs.data_ty = "struct frequent_persistent_data_"..elem_qtype
  subs.alloc_fn = "allocate_frequent_persistent_data_"..elem_qtype
  subs.free_fn = "free_frequent_persistent_data_"..elem_qtype
  subs.chunk_fn = "frequent_process_chunk_"..elem_qtype
  subs.out_fn = "frequent_process_output_"..elem_qtype
  return subs, tmpl
end
