#!/bin/bash
rm -r -f src; mkdir src
rm -r -f inc; mkdir inc
lua conv.lua tmpl_f_to_s.json
lua conv.lua tmpl_s_to_f_const.json
lua conv.lua tmpl_s_to_f_seq.json
lua conv.lua tmpl_s_to_f_period.json
lua conv.lua tmpl_pr_fld.json
lua conv.lua tmpl_nn_pr_fld.json
test -d src
test -d inc
