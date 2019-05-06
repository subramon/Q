-- require all the root operator files
-- TODO Krushnakant local qc = require 'libq_core'
-- TODO assert(qc["chk_env_var"]())

require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_I4"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_TM"
require "Q/OPERATORS/LOAD_CSV/lua/TM_to_SC"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/SORT/lua/sort"
require "Q/OPERATORS/SORT2/lua/sort2"
require "Q/OPERATORS/GET/lua/get_val_by_idx"
require "Q/OPERATORS/GET/lua/set_sclr_val_by_idx"
require "Q/OPERATORS/GET/lua/add_vec_val_by_idx"
require "Q/OPERATORS/CLONE/lua/clone"
require "Q/OPERATORS/CAT/lua/cat"
require "Q/OPERATORS/IDX_SORT/lua/idx_sort"
require "Q/OPERATORS/MM/lua/mv_mul"
require "Q/UTILS/lua/save"
require "Q/UTILS/lua/restore"
require "Q/UTILS/lua/set_memo"
require "Q/UTILS/lua/q_shutdown"
require "Q/UTILS/lua/view_meta"
require "Q/UTILS/lua/pack"
require "Q/UTILS/lua/unpack"
require "Q/OPERATORS/F1OPF2F3/lua/f1opf2f3"
require "Q/OPERATORS/F1F2OPF3/lua/_f1f2opf3"
require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2"
require "Q/OPERATORS/F1S1OPF2_VAL/lua/f1s1opf2_val"
require "Q/OPERATORS/F1S1OPF2/lua/is_prev"
require "Q/OPERATORS/S_TO_F/lua/_s_to_f"
require "Q/OPERATORS/F_TO_S/lua/_f_to_s"
require "Q/OPERATORS/COUNT/lua/counts"
require "Q/OPERATORS/AINB/lua/ainb"
require "Q/OPERATORS/AINB/lua/get_idx_by_val"
require "Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez"
require "Q/OPERATORS/DROP_NULLS/lua/drop_nulls"
require "Q/OPERATORS/CAST/lua/cast"
require "Q/OPERATORS/AX_EQUALS_B/lua/linear_solver"
require "Q/OPERATORS/APPROX/QUANTILE/lua/approx_quantile"
require "Q/OPERATORS/APPROX/FREQUENT/lua/approx_frequent"
require "Q/OPERATORS/PCA/lua/corr_mat"
require 'libsclr' -- TODO P2 Do we need this here? If so, why not libcmem
require 'Q/OPERATORS/WHERE/lua/where'
require 'Q/OPERATORS/GROUPBY/lua/groupby'
require 'Q/OPERATORS/INDEX/lua/indexing'
require 'Q/OPERATORS/UNIQUE/lua/unique'
require 'Q/OPERATORS/GETK/lua/getk'
require 'Q/OPERATORS/HASH/lua/hash'
require 'Q/OPERATORS/JOIN/lua/join'
-- alias wrappers
require 'Q/ALIAS/lua/add'
require 'Q/ALIAS/lua/sub'
require 'Q/ALIAS/lua/mul'
require 'Q/ALIAS/lua/count'
require 'Q/ALIAS/lua/mink'
require 'Q/ALIAS/lua/maxk'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
require 'Q/QTILS/lua/vvmax'
require 'Q/QTILS/lua/vvseq'
require 'Q/QTILS/lua/vvpromote'
require 'Q/QTILS/lua/fold'
require 'Q/QTILS/lua/average'
require 'Q/QTILS/lua/is_sorted'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
_G['g_time'] = {}
_G['g_ctr']  = {}

return require 'Q/q_export'
