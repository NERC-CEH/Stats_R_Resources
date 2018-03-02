#!/bin/env python2.7


import numpy as np
import netCDF4 as nc
import sys, os
import matplotlib as mpl
mpl.use('Agg')    # This allows plotting from lotus
import matplotlib.pyplot as plt

import data_info

igcm = int(sys.argv[1])-1
data_dir = '/work/scratch/tomaug/BSUB_EXAMPLE_python/data/'
out_dir = 'output/'
FILETAG = 'DUMMYGCM/BL_DUMMYGCM.dump.DUMMYYEAR0101.0.nc'
variable = 't_soil'
z_layer = 0
nlayers = 5

GCMs = data_info.GCMs()
#print(GCMs)
nGCMs = len(GCMs)

START_YEAR=1850
END_YEAR=2100
nYEARS = END_YEAR-START_YEAR+1
plot_years = np.arange(START_YEAR, END_YEAR+1)

grid_file=data_dir+'ancillary/grid_info.nc'
print('Reading grid data from: '+grid_file)
grinf=nc.Dataset(grid_file,'r')
grid_index = grinf.variables['land_index'][:]
lats_2d = grinf.variables['latitude'][:]
lons_2d = grinf.variables['longitude'][:]
grinf.close()

gcm = GCMs[igcm]
    
data = []
for iyear in range(nYEARS):
    year = START_YEAR+iyear
    str_year = str(year)
    infile = data_dir+FILETAG.replace('DUMMYGCM',gcm).replace('DUMMYYEAR',str_year)
    os.system('gunzip '+infile+'.gz')
    print('Reading data from: '+infile)
    inf=nc.Dataset(infile,'r')
    indata = inf.variables[variable][z_layer:z_layer+nlayers,:]
    inf.close()
    os.system('gzip '+infile)

    data.append(np.mean(indata,axis=0))
    del indata

data = np.array(data)
mean_data = np.mean(data,axis=0)
mean_growth_rate = np.mean(data[1:,:]-data[:-1,:],axis=0)
TS_data   = np.mean(data,axis=1)

plot_data = np.ma.masked_array(mean_data[grid_index],mask=grid_index.mask)
plt.imshow(plot_data,origin='bottom')
plt.colorbar()
plt.title(variable+' Global Mean ('+str(START_YEAR)+'-'+str(END_YEAR)+')')
plt.savefig(out_dir+gcm+'_Global_Mean_'+variable+'_Map.png')
plt.close()

plot_data = np.ma.masked_array(mean_growth_rate[grid_index],mask=grid_index.mask)
plt.imshow(plot_data,origin='bottom')
plt.colorbar()
plt.title(variable+' Global Mean ('+str(START_YEAR)+'-'+str(END_YEAR)+')')
plt.savefig(out_dir+gcm+'_Global_MeanGrowth_'+variable+'_Map.png')
plt.close()

plt.plot(plot_years,TS_data)
plt.savefig(out_dir+gcm+'_Global_Mean_'+variable+'_Timeseries.png')
plt.close()








