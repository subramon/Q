#!/bin/bash
# sudo apt-get install texlive-full
set -e 
rm -f *.aux *.log *.dvi *.ps *.pdf *.bbl *.blg
latex sigconf.tex
latex sigconf.tex
bibtex sigconf
pdflatex sigconf.tex
echo "Created sigconf.pdf"
# For final paper submission
# git clone git@github.com:bardsoftware/template-acm-2017.git
