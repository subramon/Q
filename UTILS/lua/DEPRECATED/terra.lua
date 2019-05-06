-- try to load with simple require
local succ = pcall(require, 'terra')
if succ then return end
local lib_path = nil
-- check if $Q_ROOT is set, if yes, see if it has terra.so
local Q_ROOT = os.getenv("Q_ROOT")
if Q_ROOT then 
    lib_path = Q_ROOT .. "/terra.so"
end

-- check if $TERRA_HOME is set, if yes, then try to load up lib/terra.so under it
local TERRA_HOME = os.getenv("TERRA_HOME")
if TERRA_HOME then 
    lib_path = TERRA_HOME .. "/lib/terra.so"
end

if (lib_path) then
    local lib = package.loadlib(lib_path, "luaopen_terra")
    if (lib) then
        -- if I found a terra.so, it better open up, else I'll kill myself
        lib()
        return
    end
end
-- can't do anything else, so error out
error("Could not find terra.so!")