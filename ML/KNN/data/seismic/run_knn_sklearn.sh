virtualenv venv
source venv/bin/activate
pip install --upgrade pip
pip install numpy scipy sklearn pandas
python train_nn.py
deactivate