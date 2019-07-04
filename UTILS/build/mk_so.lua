local plpath         = require 'pl.path'
local pldir          = require 'pl.dir'
local plfile         = require 'pl.file'
local qconsts        = require 'Q/UTILS/lua/q_consts'
local o_from_c       = require 'Q/UTILS/build/o_from_c'
local so_from_o      = require 'Q/UTILS/build/so_from_o'
local mk_q_core_h     = require 'Q/UTILS/build/mk_q_core_h'
local copy_generated_files     = require 'Q/UTILS/build/copy_generated_files'

--=== Copy generated files 
-- from .../gen_src/*.c to /tmp/q/src/
-- from .../gen_inc/*.h to /tmp/q/include/
local numc, numh = copy_generated_files()
print(" num C files generated/ num .h files = ", numc, numh)
----------Create tgt_h = q_core.h
assert(mk_q_core_h())
--======= Create .o files from .c files
assert(o_from_c(true))
--===== Combine .o files into single .so file
assert(so_from_o(true))

