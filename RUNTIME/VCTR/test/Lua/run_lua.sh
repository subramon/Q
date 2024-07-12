#!/bin/bash
set -e 
qjit test1.lua
qjit test_clone.lua
qjit test_freeable.lua
qjit test_gc.lua
qjit test_import.lua
qjit test_killable.lua
qjit test_lma.lua
qjit test_make_drop_mem.lua
qjit test_memo.lua
qjit test_prefetch.lua
qjit test_ref_count.lua
qjit test_restore.lua
qjit test_save2.lua
qjit test_save3.lua
qjit test_save.lua
echo "Successfully completed $0 in $PWD"
