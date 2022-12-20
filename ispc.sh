# https://github.com/dbabokin/llvm-project/releases/tag/llvm-10.0-ispc-dev

#----------------------
wget https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz
tar -zxvf Python-3.8.5.tgz
cd Python-3.8.5/
./configure --enable-optimizations
make
make install 
#--------------------
apt-get install --yes bison libbison-dev
apt-get install --yes flex libfl-dev
apt-get install --yes build-essential g++ m4 
apt-get install --yes zlib1g-dev ncurses-dev libtinfo-dev

#--- llvm 
cd $HOME/
wget https://github.com/dbabokin/llvm-project/releases/download/llvm-10.0-ispc-dev/llvm-10.0.1-ubuntu16.04aarch64-Release+Asserts-x86.arm.wasm.tar.xz
tar -xf llvm-10.0.1-ubuntu16.04aarch64-Release+Asserts-x86.arm.wasm.tar.xz
export PATH="$HOME/bin-10.0/bin:$PATH"
#-------------------------------
#---- cmake
# -- Could NOT find OpenSSL, try to set the path to OpenSSL root folder in 
# the system variable OPENSSL_ROOT_DIR (missing: OPENSSL_CRYPTO_LIBRARY
# OPENSSL_INCLUDE_DIR)
# CMake Error at Utilities/cmcurl/CMakeLists.txt:485 (message):
#   Could not find OpenSSL.  Install an OpenSSL development package or
#     configure CMake with -DCMAKE_USE_OPENSSL=OFF to build without OpenSSL.

sudo apt-get install libssl-dev
wget https://github.com/Kitware/CMake/releases/download/v3.18.2/cmake-3.18.2.tar.gz
tar -zxvf cmake-3.18.2.tar.gz
cd cmake-3.18.2/
./configure
make
sudo make install
#-------------------------------
