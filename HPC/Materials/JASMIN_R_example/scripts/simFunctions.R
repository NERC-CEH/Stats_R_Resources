# Original Code by Matt Asher for statisticsblog.com
# Feel free to modify and redistribute, but please keep this notice 

#Modifications by Ram Narasimhan
# @ramnarasimhan

rm(list=ls())
getwd()

library(ggplot2)
library(plyr)
library(reshape)

## utility functions
resetIteration <- function(){
  #This creates a dataframe full of zeros of size nrow and ncol
  area_df <- data.frame( matrix(0, nrow=areaH, ncol=areaW))
  names(area_df) <- c(1:areaW)  
  return(area_df)
}

getAdjacentCellsDataFrame<- function(){
  # adjacells is a two column (x,y) dataframe of the nearby cell offsets
  #  X X X   (-1,1)  (0,1)  (1,1) 
  #  X * X   (-1,0)  (*,*)  (1,0)
  #  X X X   (-1,-1) (0,-1) (1,-1)
  xoffset = c(-1,0,1,-1,1,-1,0,1) #top middle bottom
  yoffset = c(1,1,1,0,0,-1,-1,-1) #top middle bottom
  adjacells = data.frame(xoffset, yoffset)
}


outOfBounds <- function(xPos,yPos) {
  if( (xPos > areaW) | (xPos < 1) | (yPos > areaH) | (yPos < 1)) {
    # outOfBounds = TRUE
    return(TRUE)    
  }
  return(FALSE)
}


store_iteration_stats<- function(iter, kNumSettlers, found.home, max.look.around) {
  #how many settlers found homes
  perSet <- (found.home/kNumSettlers) * 100
  cat(paste(found.home,"settled out of", kNumSettlers, paste0(round(perSet), "%"), '\n'))   
  #avg # of steps per new settler
  cat(paste("Number of Settlers who hit max look around:", max.look.around, '\n\n'))  
  return(c(iter, found.home, kNumSettlers, perSet))
}


#get a random CELL inside the area
tryLoc = getRandomLocation <- function() {
  xNew = sample(1:areaW, 1)
  yNew = sample(1:areaH, 1)  
  return( c(xNew,yNew))
}

#get a Random Neighboring Cell
getRandomAdjacentNeighboringLocation <- function(location){
  xval=1
  yval=2
  xPos = location[xval] #unpack to get x coord
  yPos = location[yval]  
  movedir = sample(1:8,1)  #move in a random direction
  xNew = xPos + adjacells[movedir,xval]
  yNew = yPos + adjacells[movedir,yval]  
  return( c(xNew,yNew))  
  
}

# ONE ITERATION OF THE MAIN SIMULATION
########################################

# This is where the Simulation of Population Growth occurs
# Settling in Area according to establish rules
accommodateSettlers <- function(kNumSettlers, settling.option){  
  found.home <- 0 
  max.look.around <- 0
  
  for(i in 1:kNumSettlers) {
    done <- FALSE      
    steps <- 1
    
    #try Settling in a random cell in the Area
    tryLoc <- getRandomLocation()
    done <- checkLocationValidity(tryLoc, area_df, steps, settling.option)  
    
    #if random cell not valid, SCOUT in its vicinity
    while(!done) {        
      steps <- steps + 1
      # Get an adjacent location in one of the 8 adjacent cells, while still in area
      adjLoc <- getRandomAdjacentNeighboringLocation(tryLoc)
      done <- checkLocationValidity(adjLoc, area_df, steps, settling.option)
      if (steps > kMaxLookAroundSteps) {
        max.look.around <- max.look.around + 1  
        break
      }
    } #end while
    
    if(done) found.home <- found.home + 1      
  }    
  return(c(found.home,max.look.around))
}




# SETTLING RULES
########################################
## TRY different settling rules
checkLocationValidity <- function(location, area_df, steps, settling.option=1) {
  
  valid = FALSE
  xPos = location[1]
  yPos = location[2]  
  
  if(outOfBounds(xPos,yPos)) {
    return (FALSE)    
  }
  
  if(area_df[xPos,yPos] >0) {
    return(FALSE)
  }
  
  #x,y is an empty cell. Is settling there allowed per the rules?
  if(isSettlingInCellAllowed(xPos,yPos, settling.option) ) {
    area_df[xPos,yPos] <<- steps + 1
    return (TRUE)    
  }
  
  return (FALSE)    
  
}


isSettlingInCellAllowed<- function(xPos,yPos, settling.option=1)  {
  canOccupy <- FALSE
  
  if (settling.option == 2) {
    #  Settling Allowed if any of the 4 NEWS adj cells are occupied  
    if(isAnyOfNEWSCellsOccupied(xPos,yPos) )   canOccupy <- TRUE  
  }
  else if (settling.option == 3) {
    #  Settling Allowed if any of the 4 NEWS adj cells are occupied  
    if(isAnyDiagNeighboringCellOccupied(xPos,yPos) )   canOccupy <- TRUE             
  }
  else {
    # Default: Settling Allowed if any of the 8 adj cells are occupied  
    if(isAnyOf8AdjCellsOccupied(xPos,yPos) )   canOccupy <- TRUE
  }
  
  return(canOccupy)
}


# Are any of the 8 adjacent cells occupied?
isAnyOf8AdjCellsOccupied <- function(m,n) {
  canOccupy <- FALSE
  for(k in 1:8) {
    xCheck = m + adjacells[k,1]
    yCheck = n + adjacells[k,2]
    if(!(outOfBounds(xCheck, yCheck))) {
      if(area_df[xCheck, yCheck] >0) {
        canOccupy <- TRUE
      }
    }    
  } #end of looping through k
  
  return(canOccupy)
}


# Are any of the 4 direct N E W S adjacent cells occupied?
isAnyOfNEWSCellsOccupied <- function(m,n) {
  canOccupy <- FALSE
  NEWSdir = c(2,4,5,7)
  #traverse the vector of 4 elements
  for(k in 1:4) {
    xCheck = m + adjacells[NEWSdir[k],1]
    yCheck = n + adjacells[NEWSdir[k],2]
    if(!(outOfBounds(xCheck, yCheck))) {      
      if(area_df[xCheck, yCheck] > 0) {
        cat(paste("area df of", xCheck, yCheck, area_df[xCheck, yCheck]), '\n')
        cat(paste("(",m,",",n,")" ,"NEWS neighbor of (", yCheck, "-", xCheck, '\n'))
        canOccupy <- TRUE
      }
    }    
  } #end of looping through k
  
  return(canOccupy)
}

# Are any of the 4 diagonally adjacent cells occupied?
isAnyDiagNeighboringCellOccupied <- function(m,n) {
  canOccupy <- FALSE
  diag.dir = c(1,3,6,8)
  #traverse the vector of 4 elements
  for(k in 1:4) {
    xCheck = m + adjacells[diag.dir[k],1]
    yCheck = n + adjacells[diag.dir[k],2]
    if(!(outOfBounds(xCheck, yCheck))) {
      if(area_df[xCheck, yCheck] >0 ) {
        canOccupy <- TRUE
      }
    }    
  } #end of looping through k
  
  return(canOccupy)
}

########################################
## Start of seeding rules

#Random seeding
seedAreaWithPioneers<- function(numPioneers, seeding.opt=1) {
  
  if(seeding.opt==2)  {
    #Seed a central area and let it grow
    seedAreaCenter(7,7)    
  }  
  if(seeding.opt==3)  {
    #Seed a central rectangular Ring
    seedCenterRing(10,10,2)    
  }
  
  if(seeding.opt==4)  {
    #seed two vertical columns of width w  
    seedColumns(12,2)    
  }
  
  #default
  if(seeding.opt==1)  {
    #Random seeding
    RandomSeeding(numPioneers)     
  } 
  
}



#Seed the Area with Pioneers Randomly across the area
RandomSeeding <- function(numPioneers){
  for(i in 1:numPioneers) {
    # Seed it with homesteaders
    xPos = sample(1:areaH, 1)
    yPos = sample(1:areaW, 1)
    area_df[xPos,yPos] <<- 1   
  }  
}


# R-Rows C-cols in the center
seedAreaCenter <- function(r, c){
  for(x in as.integer((areaW-c)/2): as.integer((areaW + c)/2)){
    for(y in as.integer((areaH-r)/2): as.integer((areaH + r)/2)){
      area_df[x,y] <<- 1         
    }
  }
}

# w-cols to the R and L of center column
seedColumns <- function(c, w){
  startLCol = as.integer( (areaW-c) / 2 )
  startRCol = as.integer( (areaW+c) / 2 )
  
  for(y in 1:areaH) {
    clist = c((startLCol-w):startLCol, startRCol:(startRCol+w))
    lapply(clist, function(x) area_df[x,y] <<- 1)
  }
}

# RING of R-Rows C-cols in the center of width w cells
seedCenterRing <- function(r, c, wide){
  for(x in as.integer((areaW-c)/2): as.integer((areaW + c)/2)){
    for(y in as.integer((areaH-r)/2): as.integer((areaH + r)/2)){
      area_df[x,y] <<- 1         
    }
  }
  #scoop out the inner ring
  for(x in as.integer((areaW-c)/2 + wide): as.integer((areaW + c)/2 - wide)){
    for(y in as.integer((areaH-r)/2+wide): as.integer((areaH + r)/2- wide )){
      area_df[x,y] <<- 0         
    }
  }  
}

## End of seeding rules
########################################


########################################
## PLOTTING

###plotting function
drawArea <- function(area_df){  
  df <- melt(as.matrix(area_df, nrow=30))  
  #Bin the values of the data frame, using the "cut" funtion
  brk = c(-1, 0, 1, 2, 24, 1000)
  #brk = c(-1, 0, 1000)
  df$valBucket =cut(df$value, breaks=brk) #creating a new column with aggregated values based on look around value
  
  square=15
  p <-NULL
  p <- ggplot(df, aes(X1,X2, color=valBucket)) + geom_point(shape=square, size=6)
  #Use a manual (discrete) coloring scheme
  p <- p + scale_colour_manual(values = c("black","blue","orange","yellow","red", "white"))
  return(p)
}