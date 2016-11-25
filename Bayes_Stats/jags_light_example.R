# JAGS model

model{
# process model and probability model
# likelihood
for (i in 1:n)
	{
	mu[i]<-a*(x[i]+c)/((a/b)+(x[i]+c))
	y[i]~ dnorm(mu[i],tau)
	y.new[i]~dnorm(mu[i],tau) # posterior predictive distribution for each unobserved y
	}


sigma<-1/sqrt(tau) # calculate SD from precision, tau

# priors
tau~dgamma(0.001,.001)
a~dgamma(0.01,.01)
c~dunif(-10,10)
b~dgamma(.01,.01)


  } # end of model



