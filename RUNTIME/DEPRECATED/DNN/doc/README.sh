#!/bin/bash
set -e
touch .meta
eval `../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk dnn.pdf
cp dnn.pdf /tmp/
echo "COMPLETED"
