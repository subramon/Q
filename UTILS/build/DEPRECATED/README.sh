#!/bin/bash
set -e
touch .meta
paper=doc_build
eval `../../DOC/latex/tools/setenv`
make -f  ../../DOC/latex/tools/docdir.mk ${paper}.pdf
cp ${paper}.pdf /tmp/
echo "Created $paper.pdf"
