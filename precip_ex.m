myFile='/cyclone/CMIP5/DAILY/DOWNSCALED_DATA/maca_1var_100pat_WUSA_CSIRO-Mk3-6-0_historical_pr.mat'

matobj =matfile(myFile);
%matobj.data;
lat_target = [42 49];
lon_target = [249 238];


lat = matobj.lat;
lon = matobj.lon;

f_lat =find(lat>=min(lat_target)&lat<=max(lat_target));
f_lon =find(lon>=min(lon_target)&lon<=max(lon_target));

%get data in inches
% in dimensions  days,years,lat,lon
prec = matobj.data(:,:,f_lat,f_lon);
annualsum=squeeze(nansum(prec,1));