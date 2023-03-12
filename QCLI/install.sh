#/bin/bash
wget https://curl.haxx.se/download/curl-7.88.1.tar.gz
tar xvfz curl-7.88.1.tar.gz
cd curl-7.88.1
./configure --prefix=/usr/local/curl/7_88.1
make
make install

