local lgutils = require 'liblgutils'
local qc      = require 'Q/UTILS/lua/qcore'

require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/UTILS/lua/save"

require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_TM"
require "Q/OPERATORS/LOAD_CSV/lua/TM_to_SC"
require "Q/OPERATORS/LOAD_CSV/lua/TM_to_I2"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_XX"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_lkp"


require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/MK_COL/lua/mk_tbl"
require "Q/OPERATORS/S_TO_F/lua/s_to_f"
require "Q/OPERATORS/F_TO_S/lua/f_to_s"
require "Q/UTILS/lua/tbl_to_vec" 
require "Q/UTILS/lua/vec_to_tbl" 
require "Q/UTILS/lua/set_memo"

require 'Q/OPERATORS/WHERE/lua/where'
require "Q/OPERATORS/WHERE/lua/select_ranges"
require "Q/OPERATORS/F1SnOPF2/lua/f1snopf2"
require "Q/OPERATORS/F1S1OPF2/lua/is_prev"
require "Q/OPERATORS/F1S1OPF2/lua/prefix_sums"
require "Q/OPERATORS/F1S1OPF2/lua/vshift"
require "Q/OPERATORS/F1S1OPF2/lua/vstrcmp"
require "Q/OPERATORS/F1S1OPF2/lua/f1s1opf2"
require "Q/OPERATORS/F1F2OPF3/lua/f1f2opf3"
require "Q/OPERATORS/F1F2OPF3/lua/repeater"
require "Q/OPERATORS/GROUPBY/lua/isby"
require "Q/OPERATORS/GROUPBY/lua/groupby"
require "Q/OPERATORS/F1OPF2F3/lua/f1opf2f3"
require "Q/OPERATORS/F1OPF2/lua/f1opf2"

require "Q/OPERATORS/FIND/lua/find"
require "Q/OPERATORS/SORT1/lua/sort1"
require "Q/OPERATORS/PERMUTE/lua/permute_to"
require "Q/OPERATORS/PERMUTE/lua/permute_from"
require 'Q/OPERATORS/UNIQUE/lua/unique'
require 'Q/OPERATORS/JOIN/lua/join'
require "Q/OPERATORS/DRG_SORT/lua/drg_sort"
require "Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez"
require "Q/OPERATORS/AINB/lua/get_idx_by_val"
require "Q/OPERATORS/GET/lua/get_val_by_idx"

require "Q/OPERATORS/COUNT/lua/count"
require "Q/OPERATORS/BIN_COUNT/lua/bin_count"
require "Q/OPERATORS/BIN_PLACE/lua/bin_place"

require "Q/UTILS/lua/import"
require "Q/UTILS/lua/register_qop" 

require "Q/OPERATORS/VSPLIT/lua/vsplit" 
require "Q/OPERATORS/LOAD_BIN/lua/load_bin" 
require "Q/OPERATORS/PAR_SORT/lua/par_sort"
require "Q/OPERATORS/PAR_IDX_SORT/lua/par_idx_sort"

require "Q/OPERATORS/PACK/lua/pack"
require "Q/OPERATORS/UNPACK/lua/unpack"

--== These are from QTILS 
require 'Q/QTILS/lua/fold'
require 'Q/QTILS/lua/head'
--[[
require "Q/OPERATORS/F_IN_PLACE/lua/f_in_place"
require "Q/OPERATORS/F1F2_IN_PLACE/lua/f1f2_in_place"


--== These are from QTILS 
require 'Q/QTILS/lua/nop'
require 'Q/QTILS/lua/avg'


-- TODO P2 REWRITE require "Q/OPERATORS/AINB/lua/ainb"
-- TODO P3 require "Q/OPERATORS/APPROX/FREQUENT/lua/approx_frequent"
-- TODO P3 require "Q/OPERATORS/APPROX/QUANTILE/lua/approx_quantile"
require "Q/OPERATORS/AX_EQUALS_B/lua/linear_solver"

require "Q/OPERATORS/CAST/lua/cast"
require "Q/OPERATORS/CAT/lua/cat"
require "Q/OPERATORS/CLONE/lua/clone"

require "Q/OPERATORS/DROP_NULLS/lua/drop_nulls"


require "Q/OPERATORS/GET/lua/set_sclr_val_by_idx"
require "Q/OPERATORS/GET/lua/add_vec_val_by_idx"
require 'Q/OPERATORS/GETK/lua/getk'
require 'Q/OPERATORS/GROUPBY/lua/groupby'

require 'Q/OPERATORS/HASH/lua/hash'

require 'Q/OPERATORS/INDEX/lua/indexing'



require "Q/OPERATORS/MM/lua/mv_mul"
require "Q/OPERATORS/MDB/lua/mk_comp_key_val"

require "Q/OPERATORS/PCA/lua/corr_mat"



-- alias wrappers
require 'Q/ALIAS/lua/add'
require 'Q/ALIAS/lua/count'
require 'Q/ALIAS/lua/maxk'
require 'Q/ALIAS/lua/mink'
require 'Q/ALIAS/lua/mul'
require 'Q/ALIAS/lua/sub'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
require 'Q/QTILS/lua/is_sorted'
require 'Q/QTILS/lua/vvmax'
require 'Q/QTILS/lua/vvpromote'
require 'Q/QTILS/lua/vvseq'
--============= TODO P4 Document usage of  these routines
require "Q/UTILS/lua/view_meta"
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
--]]
_G['g_time'] = {}
_G['g_ctr']  = {}

if ( lgutils.is_restore_session() ) then
  print("Restoring session")
  -- OLD require "q_meta"
  local meta_file =  lgutils.meta_dir() .. "/q_meta.lua"
  print("Loading file " .. meta_file)
  local x = loadfile(meta_file)
  assert(type(x) == "function")
  x()
else
  print("NOT restoring session")
end
--======================
return require 'Q/q_export'
