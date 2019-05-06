#!?bin/bash
set -e
lua scenario_1.lua
lua test_f_to_s.lua
lua test_s_to_f.lua
lua test_print.lua
