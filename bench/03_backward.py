import torch
import time
import os

batch_size = int(os.environ.get('BATCH_SIZE', "1000"))
device = os.environ.get("DEVICE", "cpu")

def mm ():
  x = torch.randn(batch_size, 784, device = device)
  w = torch.randn(784, 512, requires_grad = True, device = device)
  for i in range(ir):
    loss = torch.sum(torch.mm(x, w))
    loss.backward()
    w.grad.cpu()
    w.grad.zero_()

ir = 1
mm()
ir = int(os.environ.get('ITER', "500"))

start_time = time.time()
mm()
print((time.time() - start_time))
