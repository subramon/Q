#!/bin/bash
set -e
touch .meta
rm -f dt.pdf
eval ` ../../../DOC/latex/tools/setenv`
make -f ../../../DOC/latex/tools/docdir.mk dt.pdf
cp dt.pdf /tmp/
