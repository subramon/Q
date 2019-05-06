--[[
export Q_METADATA_FILE=$HOME/local/Q/meta/kmeans/kmeans.lua
export Q_METADATA_DIR=$HOME/local/Q/meta/kmeans
--]]
local Q = require 'Q'
local run_kmeans = require 'run_kmeans'

debug = true -- set to false once code stabilizes
local args = {}
args.k = 3
args.max_iter = 100
args.seed     = 123456789
args.perc_diff = 0.1
args.data_file = "../data/ds1.csv"
args.meta_file = "../data/ds1.meta.lua"
args.load_optargs = { is_hdr = true, use_accelerator = true }
args.is_rough = true

Q.restore()
run_kmeans(args)
Q.save()


 
-- Q.vvmul(c, Q.vvadd(a, b):set_memo(false):set_ephemeral(true))
-- Q.fold({min,max, sum}Q.vvadd(a, b):set_memo(false))
