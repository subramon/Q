#!/bin/bash
set -e
if [ $# != 3 ]; then echo "Usage is <infile> <tmpl> <outfile>"; exit 1; fi
infile=$1
tmpl=$2
outfile=$3

test -f $infile
cat $infile | sed s"/rs_hmap_t/${tmpl}_rs_hmap_t/"g > _tempf1
cat _tempf1 | sed s"/rs_hmap_bkt_t/${tmpl}_rs_hmap_bkt_t/"g > _tempf2
cat _tempf2 | sed s"/rs_hmap_key_t/${tmpl}_rs_hmap_key_t/"g > _tempf1
cat _tempf1 | sed s"/rs_hmap_val_t/${tmpl}_rs_hmap_val_t/"g > _tempf2
cat _tempf2 | sed s"/rs_hmap_kv_t/${tmpl}_rs_hmap_kv_t/"g > _tempf1
cat _tempf1 | sed s"/rs_hmap_struct/${tmpl}_rs_hmap_struct/"g > _tempf2
mv _tempf2 $outfile
