#/bin/bash
set -e 
wget https://curl.haxx.se/download/curl-7.88.1.tar.gz
tar xvfz curl-7.88.1.tar.gz
cd curl-7.88.1
./configure --with-openssl
make
sudo make install
sudo ldconfig 
echo "Installed curl"
# ldconfig was solution to error message
# curl: symbol lookup error: curl: undefined symbol: curl_url_cleanup
