# The script has been tested in R x64 3.3.2
# I recommend to run in RGui rather than RStudio, as RStudio can become a bit unstable 

# First you will need to install the required R packages.
# By asking for dependencies, this should be all the code you need...
install.packages("sp", dep=TRUE)
install.packages("raster", dep=TRUE)
install.packages("ncf", dep=TRUE)
install.packages("ape", dep=TRUE)

# Load the required libraries...
library(sp)
library(raster)
library(rgdal)
library(rgeos)
library(nlme)
library(gstat)
library(ncf)
library(ape)

# Set random number seed to a fixed value so that 
# your results should be exactly the same as the worksheet
set.seed(1234) 

# Make the raster package print a progress bar to the console...
rasterOptions(progress="text")

# Remove any objects already in the workspace...
#rm(list=ls()) #only run this if you have saved everything you want from your existing workspace!
gc()

# Set working directory to where the script and GIS files folder are saved...
# You will need to modify the directory to your own system
setwd("C:/Users/dcha/Google Drive/R_as_a_GIS")


##############################################################################
### STEP 1 - produce random sampling locations across the UK, stratified by
###		administrative area

# List GIS layers that can be read from the folder 'GIS_files'
ogrListLayers(dsn="GIS_files")

# read in UK administrative polygons shapefile as a SpatialPolygonsDataFrame object
UK_wgs84 = readOGR(dsn="GIS_files", layer="GBR_adm2")
UK_wgs84 # print a summary of the object
plot(UK_wgs84)

# Convert coordinate system from WGS84 (long/lat) to OSGB 1936 (British National Grid)
# You can find the Proj.4 string for OSGB1936 from www.spatialreference.org
UK = spTransform(UK_wgs84, CRSobj="+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +datum=OSGB36 +units=m +no_defs")
UK # note that the coord. ref has changed
plot(UK)

# examine the data.frame (attribute table)
summary(UK@data)

# Add polygon area in km2 as a field to the data.frame.
# gArea calculates the area in m2 as this are the units of the coord. ref, 
# so we convert to km2
UK$area = gArea(UK, byid=TRUE) / (1000*1000)
summary(UK@data) # note that area is a new field of the data.frame

# access the field of the data.frame for plotting a histogram
hist(UK$area, br=100, col="grey")

# Make chloropleth map of UK, shaded by area
spplot(UK, "area")

# Dissolve the UK multi-part polygons to a single UK outline (takes ~10 seconds on my machine)
UK_out = gUnaryUnion(UK)
plot(UK_out)

# Simplify the outline polygon to make plotting cleaner
UK_out_simple = gSimplify(UK_out, tol=5000, topologyPreserve=FALSE)
plot(UK_out_simple)

# compare sizes of the polygon objects to show the effects of dissolving and simplifying...
format(object.size(UK), units="Mb")
format(object.size(UK_out), units="Mb")
format(object.size(UK_out_simple), units="Mb")

# Use sapply and indexing to create a stratified sample of random 
# locations in the UK, with 4 points per administrative area...
rndPtsList = sapply(1:length(UK), function(idx){
	P = UK[idx,] # select the polygon of interest
	PT = spsample(P, n=4, type="random") # random sample 4 points in the polygon
	return(PT) # return the SpatialPoints object
}) # returns a list of SpatialPoints 
class(rndPtsList)

# 'Bind' the list of SpatialPoints into a single SpatialPoints object...
rndPts = do.call(bind, rndPtsList)
rndPts
plot(UK_out_simple)
points(rndPts, pch=16, cex=0.5, col="red")




##############################################################################
### STEP 2 - calculate the distance from the random sampling points to major
###		waterbodies


# Read in the UK major waterbodies polygons
water_wgs84 = readOGR(dsn="GIS_files", layer="GBR_water_areas_dcw")
water_wgs84

# Re-project OSGB 1936.
# This time we can use the projection of the UK polygons in the code
water = spTransform(water_wgs84, CRSobj=UK@proj4string)
water

# plot the waterbodies...
plot(UK_out_simple)
plot(water, col="blue", border="blue", add=TRUE)

# Estimate distances from sample points to water by rasterisation method

# First, create a bounding box for the UK as an extent object
myExtent = extent(c(0,66,0,122)*10000) 
plot(myExtent, add=TRUE, col="green4")

# Create an empty raster in OSGB1936, with the desired extent and 
# 1x1 km resolution
rTemplate = raster(ext=myExtent, res=1000, crs=projection(UK)) 
rTemplate # print summary to screen

# Convert the water polygons to a raster, using the template.
# Setting 'field=1' means the resulting raster has value of 1 where the 
# cell contains water
rWater = rasterize(x=water, y=rTemplate, getCover=TRUE)
rWater
plot(rWater)

# Convert to binary (contains water or does not)
rWater = (rWater > 0)

# Convert 0 values to NA
rWater[rWater == 0] = NA

# Display the final raster...
plot(rWater, col="blue")
plot(UK_out_simple, add=TRUE)

# Interactively zoom into a region of your choice.
# After running this line, click 2 points on the screen to zoom in...
raster::zoom(rWater, col="lightblue", new=FALSE) # note we need to specify the raster library as ape also has a zoom function
plot(UK, add=TRUE, border="grey") # add the UK administrative areas
plot(water, add=TRUE, border="blue4") # add the original polygons

# Aggregate the raster to 10 km resolution to show the cover of major water bodies
plot(aggregate(rWater, fact=10, fun="sum", na.rm=TRUE),
	col=bpy.colors(100))
plot(UK_out_simple, add=TRUE)

# Calculate raster of closest distance to the waterbodies in km
waterDist = distance(rWater) / 1000
plot(waterDist)
plot(UK_out_simple, add=TRUE)

# Mask the distance to water by the UK outline
waterDist_masked = mask(waterDist, UK_out)
plot(waterDist_masked, col=bpy.colors(100))
plot(UK_out_simple, add=TRUE)

# Display a histogram of the distances to water...
hist(waterDist_masked)
hist(log1p(waterDist_masked)) # a ln(x+1) transform might look nicer
plot(log1p(waterDist_masked), col=bpy.colors(100))
plot(UK_out_simple, add=TRUE)

# extract the distance values at the random points
ptDist1 = extract(waterDist, rndPts)


# Alternatively, we can calculate the distance to the water polygons 
# more accurately and more simply using vectors
allDists = gDistance(spgeom1=water, spgeom2=rndPts, byid=TRUE) / 1000
dim(allDists) # returns a matrix of the distance from all points to all polygons
ptDist2 = apply(allDists, 1, min) # find the minimum distance for each point

plot(ptDist1, ptDist2, xlab="Distance estimate by rasterisation (km)",
	ylab="Distance estimate by direct calculation (km)") # the results are very similar


##############################################################################
### STEP 3 - estimate the human population density at each random 
###		sampling point

# Read in the population density raster in 'grd' format...
rPop_wgs84 = raster("GIS_files/gbr_msk_pop.grd")
rPop_wgs84
plot(log(rPop_wgs84), col=bpy.colors(100)) # plot on the log scale
plot(UK_wgs84, add=TRUE)

# Because some sampling points are close to the coast and not on the population raster
# coverage, we will replace the NAs with lowest value in the raster
minVal = min(getValues(rPop_wgs84), na.rm=TRUE) # find the minimum value
rPop_wgs84[is.na(rPop_wgs84)] = minVal # assign the minimum value where the raster has an NA
plot(log(rPop_wgs84), col=bpy.colors(100)) # plot on the log scale
plot(UK_wgs84, add=TRUE)

# Extract population density values at the random points by bilinear interpolation.
# Note the warning that they are not in the same projection, 
# so the points were re-projected on the fly
ptPop = extract(rPop_wgs84, rndPts, method="bilinear")
summary(ptPop)


##############################################################################
### STEP 4 - model the effect of distance to water on human population density
###		at each random, accounting for spatial autocorrelation

# Display the relationship between distance and human population
# at the random sampling points
plot(ptDist2, ptPop, xlab="Distance to water", ylab="Human population density")
# Is there a significant negative correlation?

# Examine the distribution of the variables - suggests log transformations
hist(ptDist2)
hist(log1p(ptDist2))
hist(ptPop)
hist(log(ptPop))

# Combine the required variables in a data.frame for input to the models
X = data.frame(
	x = coordinates(rndPts)[,1]/(1000*100), # easting in 100s of km
	y = coordinates(rndPts)[,2]/(1000*100), # northing in 100s of km
	lnPopDens = log(ptPop), # log-transformed population density
	lnWaterDist = log1p(ptDist2) # log(x+1) transformed distance to water
)
# Note we use coordinates in 100s of km so their variance is similar to that 
# of the predictors. This aids model fitting.
summary(X)
apply(X, 2, sd)

# Test whether the the predictor variables spatially autocorrelated
# using a global Moran's I test

# First, create pairwise distance weights...
ptDM = spDists(rndPts) # creates a pairwise distance matrix between all points
ptWM = 1/ptDM # convert to an inverse distance weight matrix
diag(ptWM) = 0 # set 0 weights for the diagonal (i.e. pairs of the same points)

# Now, run the tests...
Moran.I(x=X$lnPopDens, weight=ptWM)
Moran.I(x=X$lnWaterDist, weight=ptWM)
# Is there significant, positive autocorrelation?


# fit a basic linear regression (ordinary least squares, OLS)
L = lm(lnPopDens ~ lnWaterDist, data = X)
summary(L)
# Appears to be a significant negative trend (more people further from water)

# re-fit using generalised least squares (GLS), with no spatial autocorrelation
G1 = gls(lnPopDens ~ lnWaterDist, data = X, method="ML")
summary(G1)
# Same as OLS

# Are residuals of the model autocorrelated?
# If so, the P-values from OLS/basic GLS can't be trusted and will be 
# too significant.
# We can evaluate the autocorrelation with 3 approaches...
 
# 1. Semivariogram - is variance lower at shorter distances?
plot(Variogram(G1, form=~x+y, resType="pearson", maxDist=5), smooth=FALSE)

# 2. Global Moran's I test - is there significant positive autocorrelation?
Moran.I(x=residuals(G1), weight=ptWM)

# 3. Spline correlogram up to 150 km, with bootstrap confidence intervals - 
# at what distance does the autocorrelation reach 0? 
plot(spline.correlog(x=coordinates(rndPts)[,1]/1000, 
	y=coordinates(rndPts)[,2]/1000, 
	z=residuals(G1), resamp = 100, xmax=150))

# Re-fit the GLS model with spatial autocorrelation in residuals.
# We will fit a 'spherical' semivariogram function with a 
# nugget parameter (variance at 0 distance)
G2 = gls(lnPopDens ~ lnWaterDist, 
	correlation = corSpher(form=~x+y, nugget=TRUE), 
	data = X, method="ML")
summary(G2)
# Accounting for the autocorrelation, the relationship is not statistically significant
# Note the estimated range of autocorrelation is ~211 km

# Is the model with spatial autocorrelation a better fit?
anova(G1, G2)

# The choice of starting parameter for the range of autocorrelation
# can be very important, as the optimisation algorithm is not always great
# and can get stuck in local optima.
# We can find a good starting value by fitting the model with different fixed 
# ranges of autocorrelation and finding the one with the highest fit...
rangeTest = sapply(seq(0.3,5,0.1), function(r){
	message(r*100, " km") # print the fixed range parameter to screen
	G = gls(lnPopDens ~ lnWaterDist, 
		correlation = corSpher(form=~x+y, nugget=TRUE, value=c(r,0.01), fixed=TRUE), 
		data = X, method="ML") # fit the GLS with fixed autocorrelation
	c(r, logLik(G)) # return the range and the model log-likelihood
})
plot(t(rangeTest), type="b", pch=16, 
	xlab="Range of autocorrelation", ylab="Log-likelihood")
bestRange = rangeTest[1, which.max(rangeTest[2,])]

# re-fit the model starting at the best range we found...
G3 = gls(lnPopDens ~ lnWaterDist, 
	correlation = corSpher(form=~x+y, nugget=TRUE, value=c(bestRange,0.01)), 
	data = X, method="ML")
summary(G3)
anova(G1, G3)
anova(G2, G3)
# G3 finds the same result as G2!

# What autocorrelation function is fitted
plot(Variogram(G3, form=~x+y, resType="pearson", maxDist=5), ylim=c(0,1.1))

# What residual autocorrelation remains...
plot(Variogram(G3, form=~x+y, resType="normalized", maxDist=5))
# Not as bad as the original model

# Check the reduction in residual autocorrelation, compared to the first model
Moran.I(x=residuals(G1, type="pearson"), weight=ptWM)
Moran.I(x=residuals(G3, type="normalized"), weight=ptWM)
# Significant autocorrelation remains, but it is very weak and unlikely to affect the conclusion.

# Spline correlogram on residuals...
plot(spline.correlog(x=coordinates(rndPts)[,1]/1000, 
	y=coordinates(rndPts)[,2]/1000, 
	z=residuals(G3, type="normalized"), resamp = 100, xmax=150))









