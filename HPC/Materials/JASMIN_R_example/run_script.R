# I need a sricpt that runs about 100 models which take about 10 minutes total


# This does some poplulation simulation
# Original Code by Matt Asher for statisticsblog.com
# Feel free to modify and redistribute, but please keep this notice 
# Modifications by Ram Narasimhan

source("scripts/simFunctions.R")
library(ggplot2)
library(plyr)

kNumReplications <- 2

# Size of the area
areaW <- 30
areaH <- 30

# Homesteaders, they don't care about finding a neighbor
# only used in random seeding
numPioneers <- 30

#These are the people who follow the pioneers
kNumSettlers <- 350
# How many scouting attempts will settlers make, before abandoning 
kMaxLookAroundSteps <- 20

#Try out different seeding rules
# (1:Random) (2: Central Square) (3:Central Ring) ( 4: Two Columns)
seeding.opt <- 2
# (1: Random) (2:NEWS only) (3:Diagonal settling only)
settling.option <- 3

adjacells <- getAdjacentCellsDataFrame()

# Make multiple runs (Replication of simulation) and take the average of stats
st <- data.frame()
st_row<- vector()
for(i in 1:kNumReplications) {
  area_df <- resetIteration()
  
  seedAreaWithPioneers(numPioneers,seeding.opt)
  simstats <- accommodateSettlers(kNumSettlers, settling.option)
  
  found.home <- simstats[1]
  max.look.around <- simstats[2]
  #compute for this iterations
  st_row <- store_iteration_stats(i, kNumSettlers, found.home, max.look.around)
  st <- rbind(st,st_row)
}

#Render
p <- drawArea(area_df)
p
names(st) <- c("Iter", "FoundHome", "NumSettlers", "Percent")
st