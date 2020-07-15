require "Q/OPERATORS/F_TO_S/lua/f_to_s"
require "Q/OPERATORS/MK_COL/lua/mk_col"
require "Q/OPERATORS/PRINT/lua/print_csv"
require "Q/OPERATORS/S_TO_F/lua/s_to_f"
require "Q/OPERATORS/F_IN_PLACE/lua/f_in_place"
require "Q/OPERATORS/F1F2OPF3/lua/f1f2opf3"
require "Q/OPERATORS/F1F2_IN_PLACE/lua/f1f2_in_place"

require "Q/OPERATORS/LOAD_CSV/lua/load_csv"
-- require "Q/OPERATORS/LOAD_CSV/lua/SC_to_I4"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_XX"
require "Q/OPERATORS/LOAD_CSV/lua/SC_to_TM"
require "Q/OPERATORS/LOAD_CSV/lua/TM_to_SC"
require "Q/OPERATORS/LOAD_CSV/lua/TM_to_I2"
-- TODO require "Q/OPERATORS/LOAD_CSV/lua/TM_to_I8"
--[[
require "Q/OPERATORS/F1S1OPF2/lua/f1s1opf2"

-- TODO P2 REWRITE require "Q/OPERATORS/AINB/lua/ainb"
-- TODO P2 REWRITE require "Q/OPERATORS/AINB/lua/get_idx_by_val"
-- TODO P3 require "Q/OPERATORS/APPROX/FREQUENT/lua/approx_frequent"
-- TODO P3 require "Q/OPERATORS/APPROX/QUANTILE/lua/approx_quantile"
require "Q/OPERATORS/AX_EQUALS_B/lua/linear_solver"

require "Q/OPERATORS/CAST/lua/cast"
require "Q/OPERATORS/CAT/lua/cat"
require "Q/OPERATORS/CLONE/lua/clone"
-- TODO P1 NEED TO DO MEM_INITIALIZE require "Q/OPERATORS/COUNT/lua/counts"

require "Q/OPERATORS/DROP_NULLS/lua/drop_nulls"

require "Q/OPERATORS/F1OPF2F3/lua/f1opf2f3"
require "Q/OPERATORS/F1S1OPF2/lua/is_prev"

require "Q/OPERATORS/GET/lua/get_val_by_idx"
require "Q/OPERATORS/GET/lua/set_sclr_val_by_idx"
require "Q/OPERATORS/GET/lua/add_vec_val_by_idx"
require 'Q/OPERATORS/GETK/lua/getk'
require 'Q/OPERATORS/GROUPBY/lua/groupby'

require 'Q/OPERATORS/HASH/lua/hash'

require "Q/OPERATORS/IDX_SORT/lua/idx_sort"
require "Q/OPERATORS/IFXTHENYELSEZ/lua/ifxthenyelsez"
require 'Q/OPERATORS/INDEX/lua/indexing'



require "Q/OPERATORS/MM/lua/mv_mul"
require "Q/OPERATORS/MDB/lua/mk_comp_key_val"

require "Q/OPERATORS/PCA/lua/corr_mat"


require 'Q/OPERATORS/UNIQUE/lua/unique'

require 'Q/OPERATORS/WHERE/lua/where'
-- alias wrappers
require 'Q/ALIAS/lua/add'
require 'Q/ALIAS/lua/count'
require 'Q/ALIAS/lua/maxk'
require 'Q/ALIAS/lua/mink'
require 'Q/ALIAS/lua/mul'
require 'Q/ALIAS/lua/sub'
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
require 'Q/QTILS/lua/average'
require 'Q/QTILS/lua/fold'
require 'Q/QTILS/lua/is_sorted'
require 'Q/QTILS/lua/vvmax'
require 'Q/QTILS/lua/vvpromote'
require 'Q/QTILS/lua/vvseq'
--============= TODO P4 Document usage of  these routines
require "Q/UTILS/lua/pack"
require "Q/UTILS/lua/restore"
require "Q/UTILS/lua/save" 
require "Q/UTILS/lua/set_memo"
require "Q/UTILS/lua/unpack"
require "Q/UTILS/lua/view_meta"
--============== UTILITY FUNCTIONS FOR Q PROGRAMMER
--]]
_G['g_time'] = {}
_G['g_ctr']  = {}

--=== Stuff to do at first load time 
local cVector = require 'libvctr'
cVector.init_globals({})
local reset = os.getenv("Q_RESET")
local reset_fn = require 'Q/UTILS/lua/reset'
local restore_fn = require 'Q/UTILS/lua/restore'
if ( reset == "true" ) then 
  reset_fn()
else
  status, msg = pcall(restore_fn)
  if ( not status ) then 
    print("WARNING!!! Restore failed. Wiping things out...")
    reset_fn()
  else
    print("Restored data")
  end
end
--======================
return require 'Q/q_export'
