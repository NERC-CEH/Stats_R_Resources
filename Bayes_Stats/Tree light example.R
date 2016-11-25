setwd("C:XXX")
library(lattice)
library(rjags)
rm(list=ls(all=TRUE)) # clear the R slate!

tree.data<-read.csv("Hemlock-light-data.csv")

attach(tree.data)

plot(Light,Observed.growth.rate)
start<-list(a=40, b=2, c=6)
m1<-nls(Observed.growth.rate~a*(Light-c)/((a/b)+(Light-c)), start=start)
summary(m1)
a<-coef(m1)["a"]
b<-coef(m1)["b"]
c<-coef(m1)["c"]

x<-Light
curve(a*(x-c)/((a/b)+(x-c)), add=TRUE, col="blue")

# Or using maximum likelihood

detach(tree.data)

# Plot priors, using 'hist' or 'curve'
# EG
par(mfrow=c(1,2))
curve(dgamma(x, shape=0.001, rate=0.001), xlab="p",
     ylab="Probability Density",xlim=c(0,0.5), lwd=2, col="green")
curve(dgamma(x, shape=0.01, rate=0.01), xlab="p",
     ylab="Probability Density",xlim=c(0,0.5), lwd=2, col="red")

# Initialize the chains. This needs to be a list.
# Easiest thing is to define a function that calls the list.
mod.inits<-function(){
	list(a=runif(1,35,40), b=runif(1,1,3), c=runif(1,-5,5),tau=0.001)#small tau makes variance big
	}

# Specify data; must be a list. 
data=list(
	n=nrow(tree.data),
	x=as.numeric(tree.data$Light),
	y=as.numeric(tree.data$Observed.growth.rate )
	)

# call to JAGS
# Set run conditions: number of iterations for adaptation & runs, number of chains, etc.

n.adapt=500 #plays with algorithm for first 500 samples
n.update = 1000 #burnin
n.iter = 5000 #no. of iterations

# and run JAGS model
jm=jags.model("jags_light_example.R",data=data,mod.inits,n.chains=3,n.adapt = n.adapt)

# Burnin the chain
update(jm, n.iter=n.update)

# generate coda object for parameters and deviance.
load.module("dic") # allows reporting of deviance (useful for model comparison)
zm<-coda.samples(jm,variable.names=c("a", "b", "c","tau","deviance"),n.iter=n.iter, thin=1)

zj<-jags.samples(jm,variable.names=c("a", "b","c", "mu"), n.iter=n.iter, thin=1)

summary(zm)

# Extract elements from the matrix, for example:
summary(zm)$stat[2,1:2]
summary(zm)$quantile[1,c(1,5)]

# Plot parameters, using various plotting options
plot(zm,ask = TRUE)
plot(zm[,c("a", "b")], ask=TRUE) # subset of parameters
xyplot(zm,ask = TRUE)
densityplot(zm,ask = TRUE)

# Plot predictions
bu=summary(zj$mu,quantile,c(.025,.5,.976))$stat
pl<-cbind(tree.data$Light,t(bu))
dat<-pl[order(pl[,1]),]

plot(tree.data$Light, tree.data$Observed.growth.rate, xlab="Light", ylab="Growth Rate", pch=16, col="blue")
lines(dat[,1], dat[,3])
lines(dat[,1], dat[,2], lty="dashed")
lines(dat[,1], dat[,4],lty="dashed")


# Convergence diagnostics
rejectionRate(zm) # sampling conjugate
gelman.diag(zm) # var in chains, stable=1
heidel.diag(zm) # requires convergence
raftery.diag(zm) # how many iter you need for convergence

dic.ex<-dic.samples(jm,n.iter, type="pD")

# autocorrelation with chains
autocorr.plot(zm)
crosscorr(zm)
crosscorr.plot(zm)




