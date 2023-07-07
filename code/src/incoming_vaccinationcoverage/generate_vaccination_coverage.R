generate_vaccination_coverage <- function(start_cov=0, end_cov=0.8, nsteps=100){

  x <- start_cov
  for(i in 2:nsteps){
    x[i] <- x[i-1] + rnorm(1, mean = (end_cov-start_cov)/nsteps, sd = 1/nsteps)
  }
  x
}
