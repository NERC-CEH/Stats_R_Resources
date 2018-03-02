# Set up parameter space for modelling

kMaxLookAroundSteps <- seq(10, 50, 10)
seeding.opt <- 1:4
settling.option <- 1:3
kNumSettlers <- seq(100, 500, 100)

params <- expand.grid(kMaxLookAroundSteps = kMaxLookAroundSteps,
                      seeding.opt = seeding.opt,
                      settling.option = settling.option,
                      kNumSettlers = kNumSettlers)

write.csv(params, file = 'data/parameters.csv', row.names = FALSE)
