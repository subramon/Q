#!/bin/bash
set -e
tmp_src_dir=$Q_BUILD_DIR/src
tmp_obj_dir=$Q_BUILD_DIR/obj
tmp_include_dir=$Q_BUILD_DIR/include

pre_check(){
  # Check src file in tmp dir
  if [ ! -d $tmp_src_dir ] ; then
    echo "Error: source dir $tmp_src_dir not exists"
    exit -1
  fi

  # Check C file count in $tmp_src_dir dir
  num_files=$(ls $tmp_src_dir | wc -l)
  if [ ! $num_files -gt 0 ] ; then
    echo "Error: C files are not present in source dir $tmp_src_dir"
    exit -1
  fi
}

prepare_obj_dir(){
  # Create $tmp_obj_dir dir if not present
  mkdir -p $tmp_obj_dir

  # Check obj file count in $tmp_obj_dir
  num_files=$(ls $tmp_obj_dir | wc -l)
  if [ "$num_files" -eq 0 ] || [ $1 == true ] ; then
    echo "Creating object files for all C files from $tmp_src_dir"
    cd $tmp_obj_dir
    gcc -c $QC_FLAGS $tmp_src_dir/*.c -I $tmp_include_dir
    echo "gcc -c $QC_FLAGS $tmp_src_dir/*.c -I $tmp_include_dir"
    cd ..
  fi
}

if [ $# -lt 1 ]
then
  echo "Provide appropriate argument"
  echo "Usage: bash create_so.sh <updated_c_file> [-f]"
  echo "-f : override object files"
  exit -1
fi

# File to replace
file_name=$1
override_opt=$2
override_obj=false

if [ ! -f $file_name ] ; then
  echo "Error: $file_name doesn't exist"
  exit -1
fi

if [ ! -z $override_opt ] && [ $override_opt == "-f" ] ; then
  override_obj=true
fi

pre_check
prepare_obj_dir $override_obj

base_file_name=$(basename $file_name)

# Copy files to tmp location
cp $file_name $tmp_src_dir

# Create object file using input file
echo "Creating object file for input"
cd $tmp_obj_dir
echo "gcc -c $QC_FLAGS $tmp_src_dir/$base_file_name -I $tmp_include_dir"
gcc -c $QC_FLAGS $tmp_src_dir/$base_file_name -I $tmp_include_dir
cd ..

# Create libq_core.so
echo "Creating libq_core.so"
echo "gcc $tmp_obj_dir/*.o $Q_LINK_FLAGS -o $Q_ROOT/lib/libq_core.so"
gcc $tmp_obj_dir/*.o $Q_LINK_FLAGS -o $Q_ROOT/lib/libq_core.so

exit 0
echo "DONE !!"
