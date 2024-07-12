#!/bin/bash
set -e 
qjit test1.lua
# TODO qjit test_clone.lua
qjit test_freeable.lua
qjit test_gc.lua
# TODO qjit test_import.lua
qjit test_killable.lua
qjit test_lma.lua
qjit test_make_drop_mem.lua
qjit test_memo.lua
# TODO qjit test_prefetch.lua
# qjit test_ref_count.lua
# TODO qjit test_restore.lua
# TODO qjit test_save2.lua
# TODO qjit test_save3.lua
# TODO qjit test_save.lua
echo "Successfully completed $0 in $PWD"
