Results of tests run using variations in testgc.lua.

*_table1: mem-usage on creating a simple lua table. Stable, fixed, reproducible mem-usage with both terra and luajit

*_mkCol1: mem-usage on creating a Column using mk_col. Mem-usage fluctuates. Overall terra vs luajit seems to maintain same baseline difference, but terra has some unusual spikes (600K once) and greater variations observed during some runs.
