Prerequisites for Python Q wrapper:

$ sudo apt-get install python-dev
$ sudo pip install lupa

===========================================================================

Before running any test, either update PYTHONPATH variable or install python_Q_wrapper on your system

Update PYTHONPATH
$ source python_q_wrapper/to_source

OR

Install python_Q_wrapper
$ cd python_q_wrapper
$ python setup.py install

===========================================================================

To run tests:
$ python python_q_wrapper/test/test_print_csv.py


Note:
>> If you face error while loading any module, please check whether __init__.py is present at below location
python_q_wrapper/Q/__init__.py

if not, please check it out
