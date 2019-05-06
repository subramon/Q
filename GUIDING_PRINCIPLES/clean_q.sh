#!/bin/bash
set -e
bash my_print.sh "STARTING: Cleaning Q"
cd ../UTILS/build
make clean
cd -
bash my_print.sh "COMPLETED: Cleaning Q"