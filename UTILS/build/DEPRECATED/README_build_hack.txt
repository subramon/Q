created a script "build_hack.sh" and checked in to git at location "Q/UTILS/build/build_hack.sh" in dev branch.

This script will help you to build libq_core.so in a case where you have a modified C file and you want to include this change in 'libq_core.so' quickly.
 
Usage :
$ bash build_hack.sh <updated_C_file> [-f]

Pre-requisite:
- '/tmp/q/src' and '/tmp/q/include' directory needs to be present ( in-short our regular build process needs to be performed at-least once on this machine )
- Q/setup.sh needs to be executed ( i.e environment variables needs to be set )

Example:
Let's say you edited the "_vvadd_I4_I4_I4.c" and enabled the 'pragma omp parallel for' instruction, then run 'build_hack.sh' to create updated 'libq_core.so'

$ bash build_hack.sh /root/Q/OPERATORS/F1F2OPF3/gen_src/_vvadd_I4_I4_I4.c

For the first time, it will create ".o" files (object files) in '/tmp/q/obj' for all C files from '/tmp/q/src'. Next onwards it will create a object file only for the input C file (modified file).
Then it creates the libq_core.so at appropriate location.

'-f' option is introduced if you want to create all object files irrespective of whether they are already created or not.

Current Limitation:
- 'build_hack.sh' supports only one C file in command line argument, currently it is not supporting a case where you have multiple modified C files and you want to include those changes in 'libq_core.so'. Will modify the script to accommodate this change.
- file_path command line argument is a absolute or relative path to modified C file. With the current code, if you are using the '-f' option in command line then provide the absolute path to C file, with relative path facing issue.
if you are not using the '-f' option then relative path also works.
