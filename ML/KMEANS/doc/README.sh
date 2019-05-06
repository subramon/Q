#!/bin/bash
rm -f rough_kmeans.pdf
set -e
touch .meta
eval ` ../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk rough_kmeans.pdf
cp rough_kmeans.pdf /tmp/
