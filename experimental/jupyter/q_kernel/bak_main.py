from ipykernel.kernelapp import IPKernelApp
from . import QKernel

IPKernelApp.launch_instance(kernel_class=QKernel)
