#!/bib/bash
set -e
if [ $# != 1 ]; then echo "Usage is bash $0 <latex file prefix>"; exit 1; fi
file=$1
pdflatex $file.tex
bibtex $file
pdflatex $file.tex
pdflatex $file.tex
# dvips $file.dvi -o $file.ps
# ps2pdf $file.ps
test -f $file.pdf
echo "Created $file.pdf"
cp $file.pdf /tmp/

