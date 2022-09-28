library(torch)

batch_size <- as.numeric(Sys.getenv("BATCH_SIZE", unset = "1000"))

f <- function() {
  w <- torch_randn(784, 512, requires_grad = TRUE)
  x <- torch_randn(batch_size, 784)
  opt <- optim_sgd(w, lr = 0.01)

  for (i in 1:iter) {
    loss <- torch_sum(torch_mm(x, w))
    loss$backward()
    opt$step()
    opt$zero_grad()
  }

  invisible(NULL)
}

iter <- 1
f()
iter <- as.numeric(Sys.getenv("ITER", unset = "1000"))

cat(system.time(f())[["elapsed"]])