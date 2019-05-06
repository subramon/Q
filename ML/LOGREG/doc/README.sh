#!/bin/bash
# sudo apt-get install texlive-full
set -e 
if [ $# != 1 ]; then echo "Error. Usage is $0 file_name_prefix "; fi
# as an example, bash README.sh log_reg
filename=$1
test -f $filename.tex
# How to compile documentation
# Sample usage if bash README.sh log_reg
# Assume that $1 is prefix of filename
touch .meta
eval `../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk ${filename}.pdf
echo "Created ${filename}.pdf"
