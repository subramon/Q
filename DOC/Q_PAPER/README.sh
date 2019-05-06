#!/bin/bash
# sudo apt-get install texlive-full
set -e 
paper=cidr2019
touch .meta
eval `../latex/tools/setenv`
rm -f ${paper}.pdf
rm -f TEMP.*
make -f  ../latex/tools/docdir.mk ${paper}.pdf
echo "Created ${paper}.pdf"

# For final paper submission
# git clone git@github.com:bardsoftware/template-acm-2017.git
