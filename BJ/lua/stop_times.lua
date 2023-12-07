-- TODO FIXX
local stop_times = { 1698451200, } -- 10-28
local stop_times = { 1697846400, 1698451200, 1699056000, }
local stop_times = { 1699056000, } -- 11-04
return stop_times
-- 2023-10-21 = 1697846400 -- Saturday 
-- 2023-10-28 = 1698451200 -- Saturday 
-- 2023-11-04 = 1699056000 -- Saturday 
-- TODO Why does date give time one hour off?
-- $ date -d "2023-10-21" +%s
-- 1697842800
