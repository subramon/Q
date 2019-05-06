#!/bin/bash
set -e
bash my_print.sh "STARTING: Building Q"
pwd
cd ../UTILS/build
pwd
make
cd -
bash my_print.sh "COMPLETED: Building Q"