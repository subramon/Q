Following are the sequential steps to try the Q integration with Jupyter

- Build Q
$ cd Q
$ source setup.sh -f
$ cd UTILS/build/
$ make clean
$ make

- Install Q
$ cd ../../ (i.e cd Q)
$ sudo bash q_install.sh

- Install Jupyter (Follow steps mentioned in "docs/jupyter_install.txt")

- Install lupa (Follow steps mentioned in "docs/lupa_build_install.txt")

- Install q_kernel (Follow steps mentioned in "docs/q_kernel_install.txt")

- Start Jupyter notebook
$ jupyter notebook --allow-root --no-browser --port 9999 --ip 192.168.85.149

- Try Q sample examples mentioned in "docs/examples.txt"
