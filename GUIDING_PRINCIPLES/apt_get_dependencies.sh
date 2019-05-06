#!/bin/bash
set -e
bash my_print.sh "STARTING: Installing dependencies from apt-get"

sudo apt-get update -y || true

sudo apt-get install bc -y
sudo apt-get install cmake -y
sudo apt-get install gcc -y
sudo apt-get install libncurses5-dev -y # for lua-5.1.5
sudo apt-get install libreadline-dev -y
sudo apt-get install libssl-dev -y # for QLI
sudo apt-get install luarocks -y
sudo apt-get install m4 -y         # for QLI
sudo apt-get install make -y
sudo apt-get install unzip -y # for luarocks
#installing LAPACK stuff
sudo apt-get install liblapacke-dev liblapack-dev -y
#-----

bash my_print.sh "COMPLETED: Installing dependencies from apt-get"
