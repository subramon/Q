This directory contains files reqquired for performance comparison between "C call using luajit ffi" Vs "C call using lua-C api"

Following are the steps to run the test

-- Run the test from 'performance_test' directory
$ cd Q/experimental/performance_test

- Create library file
$ bash build.sh
This will create 'libadd.so' (used in case of luajit ffi) & 'add.so' (used in case of lua-C api)

- Run luajit ffi C test
$ time luajit ffi_add.lua

- Run lua-C api C test
$ time luajit c_api_add.lua


Results that I got on my VM are as below
Average timing:
luajit ffi C test = 5.398 sec
lua-C api C test = 5.393 sec

Almost same time
