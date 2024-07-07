Virtual environment steps

> Create virtual environment
    # install virtualenv package
        $ pip3 install virtualenv
    # create a directory
        $ mkdir ~/virtual_env
        $ cd ~/virtual_env
    # create virtualenv named dnn
        $ virtualenv dnn
    # activate the virtual env (always run below command from '~/virtual_env' directory)
        $ source dnn/bin/activate

> Install below packages in virtual environment
    (dnn) $ pip install h5py
    (dnn) $ pip install numpy
    (dnn) $ pip install pandas
    (dnn) $ pip install sklearn
    (dnn) $ pip install image

> Deactivate the virtualenv
    (dnn) $ deactivate

==================================

Commands to run dnn.py

> Run dnn.py
    # start virtual environment (refer above guide)
        $ source dnn/bin/activate
    # run python command
        (dnn) $ cd Q/RUNTIME/DNN/python
        (dnn) $ python dnn.py

> This will produce the following 5 lua files (in current directory)
    _Xin.lua
    _Xout.lua
    _npl.lua
    _dpl.lua
    _afns.lua

 and the following 4 C files (in current directory)
    _set_W.c
    _set_B.c
    _set_Z.c
    _set_A.c

==================================
