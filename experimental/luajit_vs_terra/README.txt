==============================================
Pre-requisite
==============================================
1. luajit (LuaJIT 2.0.4) and terra (terra-Linux-x86_64-332a506.zip) needs to be installed & should be included in PATH env variable
2. Penlight needs to be installed
    $ sudo luarocks install penlight 1.4.1-1




==============================================
Generate Input File
==============================================

1. Go to the extracted directory
    $ cd terra_vs_luajit_performance

2. Run the input file generation script as below
    $ bash generate_input.sh <terra/luajit> <output_csv_path> <row_count>

Example
    $ bash generate_input.sh luajit input_files/10000_rows.csv 10000
    $ bash generate_input.sh terra input_files/10000_rows.csv 10000

Note:
row_count and generated file size proportion is as below

row_count	file_size
10000		~17M
50000		~83M
100000		~166M




==============================================
Run Performance Test 
==============================================

1. Copy terra.so from your terra installed location to extracted directory
    $ cp terra-Linux-x86_64-332a506/lib/terra.so terra_vs_luajit_performance/

2. Go to the extracted directory
    $ cd terra_vs_luajit_performance

3. Run the performance script as below
    $ bash run_performance_test.sh <terra/luajit/luaterra> <input_csv_path>
    Following is the description about first argument
    - terra : run performance test with 'terra' interpreter
    - luajit : run performance test with 'luajit' interpreter
    - luaterra : run performance test with 'luajit' interpreter and terra library (i.e with "require 'terra'" statement in lua file)

Example
    $ bash run_performance_test.sh terra input_files/10000_rows.csv
    $ bash run_performance_test.sh luajit input_files/10000_rows.csv
    $ bash run_performance_test.sh luaterra input_files/10000_rows.csv

3. After completion of the test, load operation time will be printed on the console

Note: 
This performance test program loads the csv file into binary files one per each column.
