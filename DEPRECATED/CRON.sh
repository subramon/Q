#!/bin/bash

TEMP_LOCATION="/tmp"
set +e
export Q_SRC_ROOT="`pwd`"
cd $Q_SRC_ROOT
git pull

pre_build_cleanup(){
   rm -f $TEMP_LOCATION/libq*
   rm -f $TEMP_LOCATION/q_core.h
   rm -rf $TEMP_LOCATION/LUA*
   rm -rf $Q_ROOT/include/*
   rm -rf $Q_ROOT/lib/*
}

report_files_cleanup(){
   rm -f $Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/data_load.report.txt
   rm -f $Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/data_load.stats.txt
   rm -f $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/load_csv.report.txt
   rm -f $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/load_csv.stats.txt
   rm -f $Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/mk_col.report.txt
   rm -f $Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/mk_col.stats.txt
   rm -f $Q_SRC_ROOT/OPERATORS/PRINT/test/print_csv.report.txt
   rm -f $Q_SRC_ROOT/OPERATORS/PRINT/test/print_csv.stats.txt
   rm -f $Q_SRC_ROOT/RUNTIME/COLUMN/code/test_cases/vector.report.txt
   rm -f $Q_SRC_ROOT/RUNTIME/COLUMN/code/test_cases/vector.stats.txt
   rm -f $Q_SRC_ROOT/UTILS/test/dictionary.report.txt
   rm -f $Q_SRC_ROOT/UTILS/test/dictionary.stats.txt
}

cd $Q_SRC_ROOT/UTILS/build

source $Q_SRC_ROOT/setup.sh -f

build_cleanup_heading="------------OUTPUT of build cleanup--------------------------------------"
build_cleanup_output=$(make clean 2>&1)
build_output_heading="------------OUTPUT of build scripts--------------------------------------"
build_output=$(make 2>&1)

cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/
bash test_meta_data.sh
cd $Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/
bash test_load_csv.sh
cd $Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/
bash test_load_csv.sh
cd $Q_SRC_ROOT/OPERATORS/PRINT/test/
bash test_print_csv.sh
cd $Q_SRC_ROOT/UTILS/test/
bash test_dictionary.sh
cd $Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/
bash test_mkcol.sh
cd $Q_SRC_ROOT/RUNTIME/COLUMN/code/test_cases/
bash test_vector.sh

#check whether night build txt file for metadata is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/nightly_build_metadata.txt
if [ -f $nightly_file ] 
then
 load_csv_metadata_out=$(cat $nightly_file)
else
 load_csv_metadata_out="Error in Creating METADATA TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for load is present in LOAD_CSV/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/nightly_build_load.txt
if [ -f $nightly_file ] 
then
 load_csv_out=$(cat $nightly_file)
else
 load_csv_out="Error in Creating LOAD_CSV TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for load is present in DATA_LOAD/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/nightly_build_load.txt
if [ -f $nightly_file ] 
then
 data_load_out=$(cat $nightly_file)
else
 data_load_out="Error in Creating DATA_LOAD TEST CASES"
fi
rm $nightly_file



#check whether night build txt file for PRINT is present in PRINT/test folder
nightly_file=$Q_SRC_ROOT/OPERATORS/PRINT/test/nightly_build_print.txt
if [ -f $nightly_file ] 
then
 print_out=$(cat $nightly_file)
else
 print_out="Error in Creating PRINT TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for PRINT is present in PRINT/test folder
nightly_file=$Q_SRC_ROOT/UTILS/test/nightly_build_dictionary.txt
if [ -f $nightly_file ] 
then
 utils_out=$(cat $nightly_file)
else
 utils_out="Error in Creating DICTIONARY TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for MK_COL is present in MK_COL/test/testcases folder
nightly_file=$Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/nightly_build_mkcol.txt
if [ -f $nightly_file ] 
then
 mk_col_out=$(cat $nightly_file)
else
 mk_col_out="Error in Creating MK_COL TEST CASES"
fi
rm $nightly_file

#check whether night build txt file for Vector is present in MK_COL/test/testcases folder
nightly_file=$Q_SRC_ROOT/RUNTIME/COLUMN/code/test_cases/nightly_build_vector.txt
if [ -f $nightly_file ] 
then
 vector_out=$(cat $nightly_file)
else
 vector_out="Error in Creating Vector TEST CASES"
fi
rm $nightly_file


final_out="${load_csv_metadata_out}"$'\n\n'"${load_csv_out}"$'\n\n'"${data_load_out}"$'\n\n'"${print_out}"$'\n\n'"${utils_out}"$'\n\n'"${mk_col_out}"$'\n\n'"${vector_out}"

final_out="${final_out}"$'\n\n'"${build_output_heading}"$'\n\n'"${build_output}"$'\n\n'"${build_cleanup_heading}"$'\n\n'"${build_cleanup_output}"
#echo "$final_out" 

attach_file=$Q_SRC_ROOT/RUNTIME/COLUMN/code/test_cases/vector.report.txt
if [ -f $attach_file ] 
then
 varattach="-A "$attach_file
fi


attach_file=$Q_SRC_ROOT/UTILS/test/dictionary.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/LOAD_CSV/test/testcases/load_csv.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/DATA_LOAD/test/testcases/data_load.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi


attach_file=$Q_SRC_ROOT/OPERATORS/PRINT/test/print_csv.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi

attach_file=$Q_SRC_ROOT/OPERATORS/MK_COL/test/testcases/mk_col.report.txt
if [ -f $attach_file ] 
then
 varattach=$varattach" -A "$attach_file
fi

# echo $varattach
# echo "$final_out" > /tmp/output.txt
echo "$final_out" | /usr/bin/mail -s "Q Unit Tests" projectq@gslab.com,isingh@nerdwallet.com,rsubramonian@nerdwallet.com $varattach

report_files_cleanup
