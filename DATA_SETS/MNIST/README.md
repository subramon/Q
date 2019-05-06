MNIST Dataset
=============

This is a dataset of labeled handwritten digits. The goal is to identify the digit.

The dataset is taken from a torch demo, which you can run for simple benchmarking.

Running Torch Against This Dataset
----------------------------------

Torch installation instuctions are here: http://torch.ch/docs/getting-started.html

Note that as of writing Torch hacks luarocks in a way which is incompatible with Q,
so you should install it in a different VBox.

After Torch is installed, you can do
```bash
git clone https://github.com/torch/demos
cd demos/train-a-digit-classifier
# this will download the data in Torch's format and run on a small subset to make sure everything is working
th train-on-mnist.lua --model=linear
# this is a full run to be benchmarked against
th train-on-mnist.lua --model=linear -full 
```
