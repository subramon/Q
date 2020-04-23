#!/bin/bash
set -e
if [ $# != 2 ]; then echo "Error. Usage is $0 <indir> <outdir>"; exit 1; fi
indir=$1
outdir=$2
ls $indir > _x
while read infile
do
  outfile=`echo $infile | sed s'/^_//'g`
  cp $indir/$infile $outdir/$outfile
done < _x

