#!/bin/bash
set env -e
luajit build.lua gen_core.lua
luajit mk_core.lua /tmp/
luajit build.lua gen.lua
luajit mk_so.lua /tmp/

