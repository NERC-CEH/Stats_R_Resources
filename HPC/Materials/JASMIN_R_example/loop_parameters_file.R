# I need a sricpt that runs about 100 models which take about 10 minutes total


# This does some poplulation simulation
# Original Code by Matt Asher for statisticsblog.com
# Feel free to modify and redistribute, but please keep this notice 
# Modifications by Ram Narasimhan

source("scripts/simFunctions.R")
library(ggplot2)
library(plyr)

kNumReplications <- 5

# Size of the area
areaW <- 30
areaH <- 30

# Homesteaders, they don't care about finding a neighbor
# only used in random seeding
numPioneers <- 30

parameters <- read.csv('data/parameters.csv')

# Record the time so we know how long it takes
start <- Sys.time()

for(i in (1:nrow(parameters))){
    
  cat('\n\nStarting parameter set', i, '\n')
  
  #These are the people who follow the pioneers
  kNumSettlers <- parameters[i, 'kNumSettlers']
  # How many scouting attempts will settlers make, before abandoning 
  kMaxLookAroundSteps <- parameters[i, 'kMaxLookAroundSteps']
  
  #Try out different seeding rules
  # (1:Random) (2: Central Square) (3:Central Ring) ( 4: Two Columns)
  seeding.opt <- parameters[i, 'seeding.opt']
  # (1: Random) (2:NEWS only) (3:Diagonal settling only)
  settling.option <- parameters[i, 'settling.option']
  
  adjacells <- getAdjacentCellsDataFrame()
  
  # Make multiple runs (Replication of simulation) and take the average of stats
  st <- data.frame()
  st_row <- vector()
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
  
  # Render plot
  plotname <- paste0('Pop_map_',
                     paste(kNumSettlers, kMaxLookAroundSteps, seeding.opt, settling.option, sep = '_'),
                     '.png')
  png(filename = file.path('output_figures', plotname),
      width = 6, height = 4, units = 'in', res = 300)
    print(drawArea(area_df))
  dev.off()
  names(st) <- c("Iter", "FoundHome", "NumSettlers", "Percent")
  tablename <- paste0('Pop_table_',
                      paste(kNumSettlers, kMaxLookAroundSteps, seeding.opt, settling.option, sep = '_'),
                     '.csv')
  write.csv(st, file = file.path('output_tables', tablename), row.names = FALSE)
}

# How long did it take
Sys.time() - start

# Time difference of 28.34115 mins