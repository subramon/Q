#TODO: need to test it on new VM
bash my_print.sh "STARTING: Installing Q-ML dependencies"
  sudo apt-get install python3-pip -y
  sudo pip3 install numpy
  sudo pip3 install pandas
  sudo apt-get install build-essential  -y
  sudo apt-get install python3-dev  -y
  sudo apt-get install python3-setuptools -y 
  sudo apt-get install python3-numpy -y 
  sudo apt-get install python3-scipy -y 
  sudo apt-get install python3-pip -y 
  sudo apt-get install libatlas-dev -y 
  sudo apt-get install libatlas3gf-base -y 
  sudo pip3 install scikit-learn
bash my_print.sh "COMPLETED: Installing Q-ML dependencies"
