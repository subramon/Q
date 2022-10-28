#!/bin/bash
set -e
if [ $# != 5 ]; then 
  echo "Usage is <workdir> [src|inc] <infile> <tmpl> <outfile>"; 
  exit 1; 
fi
workdir=$1
corh=$2 # c or h 
list_of_files=$3
tmpl=$4
outdir=$5

test -f $list_of_files
while IFS= read -r line
do
  echo "$line"
  infile=$workdir/$corh/$line
  test -f $infile
  outfile=$outdir/$corh/$line
  bash specialize_one.sh $infile $tmpl $outfile
done < $list_of_files
echo "Succesfully completed $0 in $PWD"
