#!/bin/bash
set -e
touch .meta
paper=janus
eval `../../DOC/latex/tools/setenv`
make -f  ../../DOC/latex/tools/docdir.mk ${paper}.pdf
cp janus.pdf /tmp/
echo "Created $paper.pdf"
