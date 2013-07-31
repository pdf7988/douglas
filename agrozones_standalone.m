[FileName,PathName,FilterIndex] = uigetfile('/Volumes/data2/moore/downscaled_scenarios/*.nc','Select netCDF file to read:');

% Determine file identifier.
uscr        = findstr(FileName,'_');
fileID      = FileName(1:uscr(length(uscr)-2));

% Reads in lat and lon
ncid        = netcdf.open([PathName FileName],'NOWRITE');
lt          = netcdf.getVar(ncid,0,'double');
ln          = netcdf.getVar(ncid,1,'double');
[lonc,latc] = meshgrid(ln,lt);


%ncid = netcdf.open([PathName FileName],'NOWRITE');
%[ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
%if(nvars ~= 4)
%    sprintf('Number of netCDF variables is incorrect.  Try reading another file.')
%    return;
%end

month = ['jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec'];
% Computes the Cumulative Growing Degree Days (cgdd) and Mean Annual Precip (map)
%for y = 1:200
cgdd = zeros(621,435);
%for y = 0:199                   % 0 = 1900, 1 = 1901, ... 
for y = 0:0

    % CRUDE ESTIMATE of the Cumulative Growing Degree Days
    cgdd  = zeros(621,435);
    for m = 1:5
        ncid_Tmax = netcdf.open([PathName fileID month(m,:) '_tmax_run1.nc'],'NOWRITE');
        ncid_Tmin = netcdf.open([PathName fileID month(m,:) '_tmin_run1.nc'],'NOWRITE');
%        Tmax      = netcdf.getVar(ncid,3,[0 0 0],[lat_dimlen lon_dimlen 1],'double');
        Tmax      = netcdf.getVar(ncid_Tmax,3,[0 0 y],[621 435 1],'double');
        Tmin      = netcdf.getVar(ncid_Tmin,3,[0 0 y],[621 435 1],'double');
        Tavg      = (Tmax+Tmin)/2;
        Tavg(find(Tavg < 0)) = 0;
        
        cgdd      = cgdd + 30*Tavg;
        
        netcdf.close(ncid_Tmax); netcdf.close(ncid_Tmin); 
    end
    
    % Determine the Mean Annual Precip (map)
    map   = zeros(621,435);
    for m = 1:12
        ncid_prec = netcdf.open([PathName fileID month(m,:) '_prec_run1.nc'],'NOWRITE');
        prec      = netcdf.getVar(ncid_prec,3,[0 0 y],[621 435 1],'double');

        map       = map + prec;

        netcdf.close(ncid_prec);
    end
end

figure
surf(lonc,latc,cgdd)
view(2)
axis([-125 -107 30 50])
shading flat
colorbar
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title('Cumulative Growing Degree Days')

figure
surf(lonc,latc,map)
view(2)
axis([-125 -107 30 50])
shading flat
colorbar
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title('Mean Annual Precip')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads in water holding capacity data.
load /Users/vonw/Work/Projects/agroclimateZones/soil_AWHC.mat
lons  = double(x(:,1:435));
lats  = double(y(:,1:435));
datas = double(s1(:,1:435));

%figure
%mesh(lons,lats,datas);
%view(2)
%axis([-125 -107 30 50])

% Binary "soil depth" map (using water holding capacity as a proxy)
soilDepth = zeros(621,435);
soilDepth(find(datas > 6.5)) = 1;

figure
surf(lons,lats,soilDepth)
view(2)
axis([-125 -107 30 50])
colormap([ [1 1 1]; [0 0 0] ])
colorbar
shading flat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Determine Agro-Climate Zones based on classification by Douglas et al,
% 1996: Agroclimatic Zones for Dryland Winter Wheat Producing Areas of
% ldaho, Washington and, Oregon, Northwest Science, 66, 26-34.

agz  = ones(621,435) * 6;   % Irrigated !
agz( find(map>400             &                  cgdd<700             ) ) = 1;
agz( find(map>400             &                 (cgdd>700 & cgdd<1000)) ) = 2;
agz( find((map>350 & map<400) & soilDepth ==1 & (cgdd>700 & cgdd<1000)) ) = 3;
agz( find((map>250 & map<400) & soilDepth ==0 & cgdd<1000             ) ) = 4;
agz( find(map<350             & soilDepth ==1                         ) ) = 5;

figure
surf(lonc,latc,agz)
view(2)
axis([-125 -107 30 50])
shading flat
colorbar
