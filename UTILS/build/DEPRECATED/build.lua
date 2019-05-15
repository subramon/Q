-- execute as build.lua gen.lua
-- execute as build.lua tests.lua

local qconsts = require 'Q/UTILS/lua/q_consts'

local rootdir = qconsts.Q_SRC_ROOT
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local nargs = assert(#arg == 1, "Arguments are <infile>")
local infile = arg[1]
assert(plpath.isfile(infile), "File not found: " .. infile)

local function foo (T)
    for i, v in ipairs(T) do
        plpath.chdir(rootdir .. "/" .. v.dir)
        local cwd = assert(plpath.currentdir())
        print("Currently in ", cwd)
        local F = pldir.getfiles(cwd, "*.sh")
        for i, script in ipairs(v.scripts) do
            print(" Executing ", script)
            if ( string.find(script, ".sh") ) then
                status = os.execute("bash " .. script)
            elseif ( string.find(script, ".lua") ) then
                status = os.execute("luajit " .. script)
            else
                status = os.execute(script)
            end
            assert ( status == 0, " failure at " .. script, " in ", cwd)
        end
    end
end

local log = require 'Q/UTILS/lua/log'
local T = dofile(infile)
foo (T)
