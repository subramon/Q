
local copy_gen_files     = require 'Q/UTILS/build/copy_gen_files'
local mk_q_core_h     = require 'Q/UTILS/build/mk_q_core_h'
local o_from_c       = require 'Q/UTILS/build/o_from_c'
local qconsts        = require 'Q/UTILS/lua/q_consts'
local so_from_o      = require 'Q/UTILS/build/so_from_o'

--=== Copy gen files 
-- from .../gen_src/*.c to /tmp/q/src/
-- from .../gen_inc/*.h to /tmp/q/include/
local numc, numh = copy_gen_files()
print(" num C files gen/ num .h files = ", numc, numh)
----------Create tgt_h = q_core.h
assert(mk_q_core_h())
--======= Create .o files from .c files
assert(o_from_c(true))
--===== Combine .o files into single .so file
assert(so_from_o(true))

