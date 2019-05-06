#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $SCRIPT_DIR

LUA_DEBUG=0
LUA_PROD=0
LUA_DEV=0

#q_install script's usage function
usage(){
  echo "------------------------------"
  echo "Manual/Usage of q_install.sh:"
  echo "bash q_install.sh prod|dev|dbg"
  echo "------------------------------"
  exit 0
}

#---------- Main program starts ----------
# installing apt get dependencies
bash apt_get_dependencies.sh
# first checking version of system packages required for Q
bash system_requirements.sh

# setting Q source env variables
# TODO: absolute path can be supported
# for now not exiting from setup.sh if any cmd fails i.e. nullifying the set -e effect
# failing cmd: lscpu | grep "Architecture" | grep "arm"
source ../setup.sh -f || true

#Usage: bash q_install.sh "prod|dev|dbg"
#Performs installations of all the required packages, libraries, dependencies required
#for running Q, it works in 3 modes.
#Modes/Options:
#prod : Production mode have just the bare bones of Q to run the Q scripts.
#dev  : Developer mode have everything else: testing, documentation, qli.
#dbg  : Debug mode will be useful for debugging.

# checking mode for q_install.sh
ARG_MODE=$1
case $ARG_MODE in
  help)
    usage
    ;;
  prod)
    export QC_FLAGS="$QC_FLAGS -O4"
    ##LUA_PROD=1
    ;;
  dev)
    export QC_FLAGS="$QC_FLAGS -g"
    LUA_DEV=1
    ;;
  dbg)
    export QC_FLAGS="$QC_FLAGS -g"
    LUA_DEBUG=1
    ;;
  *)
   #default case
   usage
   exit 0
   ;;
esac

## Note: Debugger & Developer mode: building Q with -g flag


if [[ $LUA_DEBUG -eq 1 ]] ; then
  # installing lua with debug mode(set -g flag) if debug mode
  bash lua_installation.sh LUA_DEBUG
else
  # installing lua and luajit normal mode(prod and dev mode)
  bash lua_installation.sh
  bash luajit_installation.sh
fi

# This modifies (increases dramatically) the number of files the particular user can have
# open (concurrently). The user for whom we are increasing the limits is the current user.
# The understanding is that Q will be run by this user.
echo "`whoami` hard nofile 102400" | sudo tee --append /etc/security/limits.conf
echo "`whoami` soft nofile 102400" | sudo tee --append /etc/security/limits.conf

# Installing Luarocks
bash luarocks_installation.sh

# installing basic required packages using luarocks
bash q_required_packages.sh

###if "dbg" mode then
if [[ $LUA_DEBUG -eq 1 ]] ; then
  #TODO: do we require doc in debug mode?
  bash luaffi_installation.sh
  #qli installation
  bash q_qli_dependencies.sh
  #test installation
  bash q_test_dependencies.sh
fi

###if "dev" mode then
if [[ $LUA_DEV -eq 1 ]] ; then
  #doc installation
  bash q_doc_dependencies.sh
  #qli installation
  bash q_qli_dependencies.sh
  #test installation
  bash q_test_dependencies.sh
  #Q-Machine Learning installation
  bash q_ml_dependencies.sh
  #python-Q wrapper installation
  bash q_python_wrapper_dependencies.sh
fi

# Build Q
bash my_print.sh "Building Q"

# cleaning up all files
bash clean_up.sh ../

# make clean
bash clean_q.sh

if [[ $LUA_DEBUG -eq 1 ]] ; then
  cp /tmp/ffi.so ${Q_ROOT}/lib
fi

# make
bash build_q.sh

# execute run_q_tests to check whether Q is properly build
L -e "require 'run_q_tests'()"

bash my_print.sh "Successfully completed q_install.sh"
