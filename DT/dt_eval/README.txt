This directory contains a micro-benchmark for evaluating decision trees

main.c is used to create run_dt_eval

mt_main.c is used to create run_mt_dt_eval

Configuration parameters are hard-coded in the main().
At some point, they should be moved into a config file.

The difference is that in the second case, we evaluate several decision 
trees in parallel against the same input data. This is useful for random 
forests.
