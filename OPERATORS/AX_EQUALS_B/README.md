Compiling
---------

To compile test_driver, LAPACK is required. On Ubuntu, this can be installed via 
    apt-get install libblas-dev liblapack-dev liblapacke-dev
Then `make` can handle the rest.
    
Running
-------

Usage is `./test_driver <n>`, where n is any positive integer.

Add the `-v` for more verbose output.

Use the `-b` option for benchmarking: the program will run each function 15 times, and take the average
of the last 12 runs as the number of cycles used.

The `Makefile` has some useful shortcuts: `make test` will run a small example with `valgrind`, 
`make debug` will compile with the `-g` option, and `make bench` will run a decent sized example with the `-b` option set.

Documentation
-------------

To build the documentation, any LaTeX installation with the `pdflatex` command should be sufficient, then:
    pdflatex linear_solver.tex

Notes
-----

It seems that OpenMP does not play nicely with Valgrind. Unless Valgrind reports
that memory is definitely lost, there is probably no issue. You can make sure by running Valgrind
with the options `--leak-check=full --show-leak-kinds=all`, and confirming that each individual
item reported by Valgrind is related to OpenMP.
