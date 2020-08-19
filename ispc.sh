apt-get -y update 
apt-get install -y repo subversion clang-8 build-essential libnuma1 opencl-headers ocl-icd-libopencl1 clinfo vim gcc g++ git python3 imagemagick m4 bison flex zlib1g-dev ncurses-dev libtinfo-dev libc6-dev-i386 cpio lsb-core wget netcat-openbsd libtbb-dev libglfw3-dev pkgconf gdb gcc-multilib g++-multilib curl libomp-dev 
rm -rf /var/lib/apt/lists/*

wget https://cmake.org/files/v3.15/cmake-3.15.0-Linux-x86_64.sh 
mkdir -p /opt/cmake 
sh cmake-3.15.0-Linux-x86_64.sh --prefix=/opt/cmake --skip-license 
ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake 
ln -s /opt/cmake/bin/cmake /usr/bin/cmake 
ln -s /opt/cmake/bin/ctest /usr/local/bin/ctest 
ln -s /opt/cmake/bin/ctest /usr/bin/ctest 
rm cmake-3.15.0-Linux-x86_64.sh
echo "All done"

# TODO P1 Fix HOMEDIR below
HOMEDIR=/home/ubuntu/
SHA=master
REPO=ispc/ispc
mkdir -p $HOMEDIR/src/
cd $HOMEDIR/src/
git clone https://github.com/$REPO.git ispc
cd ispc 
git checkout $SHA 
cd ..

cd $HOMEDIR/ispc/
ISPC_HOME=`pwd`
export ISPC_HOME=$ISPC_HOME
#---- for LLVM

LLVM_VERSION=10.0
mkdir -p $HOMEDIR/tools/
mkdir -p $HOMEDIR/tools/llvm/
mkdir -p $HOMEDIR/tools/llvm/$LLVM_VERSION
LLVM_HOME=$HOMEDIR/tools/llvm/$LLVM_VERSION
export LLVM_HOME=$LLVM_HOME
python3 ./alloy.py -b --version=$LLVM_VERSION --selfbuild 
rm -rf $LLVM_HOME/build-$LLVM_VERSION $LLVM_HOME/llvm-$LLVM_VERSION $LLVM_HOME/bin-"$LLVM_VERSION"_temp $LLVM_HOME/build-"$LLVM_VERSION"_temp

