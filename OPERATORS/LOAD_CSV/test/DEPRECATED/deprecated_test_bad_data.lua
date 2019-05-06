package.path = package.path .. ";../lua/?.lua"
require("load_csv")

_G["Q_DATA_DIR"] = "./"
_G["Q_META_DATA_DIR"] = "./"
_G["Q_DICTIONARIES"] = {}

T = dofile("bad_data.lua")
for i, v in ipairs(T) do
  M = dofile(v.meta)
  D = v.data
  status, err = pcall(load_csv, D, M)
  if ( status ) then 
    error( "Failed on M, D".. err)
  end
end
print("All is well")
