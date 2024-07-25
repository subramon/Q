#!/bin/bash
set -e 
qjit test1.lua
qjit test_freeable.lua
qjit test_gc.lua
qjit test_memo.lua
qjit test_clone.lua
qjit test_lma.lua
qjit test_killable.lua
qjit test_make_drop_mem.lua
# TODO qjit test_import.lua
# TODO qjit test_restore.lua
# TODO qjit test_save2.lua
# TODO qjit test_save3.lua
# TODO qjit test_save.lua
echo "Successfully completed $0 in $PWD"
