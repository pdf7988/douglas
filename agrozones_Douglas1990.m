function [lonc,latc,cgdd,map,soilDepth,agz] = agrozones(PathName,fileID)

PathName
fileID

month = ['jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec'];

% Reads in lat and lon
ncid        = netcdf.open(char(strcat(PathName,fileID,month(4,:),'_tmax_run1.nc')),'NOWRITE');
lt          = netcdf.getVar(ncid,0,'double');
ln          = netcdf.getVar(ncid,1,'double');
[lonc,latc] = meshgrid(ln,lt);


% Computes the Cumulative Growing Degree Days (cgdd) and Mean Annual Precip (map)

cgdd = zeros(621,435);
%y    = year-1900;                   % 0 = 1900, 1 = 1901, ... 

    % CRUDE ESTIMATE of the Cumulative Growing Degree Days
    cgdd  = zeros(621,435);
    sprintf('Calculating Cumulative Growing Degree Days...')
    for m = 1:5
        sprintf('Month: %s',month(m,:))
        ncid_Tmax = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_tmax_run1.nc')),'NOWRITE');
        ncid_Tmin = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_tmin_run1.nc')),'NOWRITE');
%        Tmax      = netcdf.getVar(ncid,3,[0 0 0],[lat_dimlen lon_dimlen 1],'double');
        Tmax      = netcdf.getVar(ncid_Tmax,3,[0 0 61],[621 435 30],'double');
        Tmax      = reshape(mean(shiftdim(Tmax,2)),621,435);
        Tmin      = netcdf.getVar(ncid_Tmin,3,[0 0 61],[621 435 30],'double');
        Tmin      = reshape(mean(shiftdim(Tmin,2)),621,435);
        Tavg      = (Tmax+Tmin)/2;
        Tavg(find(Tavg < 0)) = 0;
        
        cgdd      = cgdd + 30*Tavg;
        
        netcdf.close(ncid_Tmax); netcdf.close(ncid_Tmin); 
    end
    
    % Determine the Mean Annual Precip (map) as 30-year normal from 1961-1990.
    map   = zeros(621,435);
    sprintf('Calculating Mean Annual Precipitation...')
    for m = 1:12
        sprintf('Month: %s',month(m,:))
        ncid_prec = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_prec_run1.nc')),'NOWRITE');
        prec      = netcdf.getVar(ncid_prec,3,[0 0 61],[621 435 30],'double');
        prec      = reshape(mean(shiftdim(prec,2)),621,435);
        
        map       = map + prec;

        netcdf.close(ncid_prec);
    end

figure
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lonc,latc,cgdd,[0 700 1000]);
%m_contourf(lonc,latc,cgdd,[0:100:1000]);
m_grid;
%caxis([0 4000]);
caxis([0 1000]);
colorbar
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title(['Cumulative Growing Degree Days, ',fileID,', 1961-1990'])
eval(['print -djpeg ',char(fileID),'Douglas1990_cgdd.jpg']);

figure
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lonc,latc,map,[0 250 350 400]);
%m_contourf(lonc,latc,map,[0:100:400]);
m_grid;
%caxis([0 8500]);
caxis([0 400]);
colorbar
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title(['Mean Annual Precip, ',fileID,', 1961-1990'])
eval(['print -djpeg ',char(fileID),'Douglas1990_map.jpg']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads in water holding capacity data.
sprintf('Estimating Soil Depth from Available Water Holding Capacity...')
load /Users/vonw/Work/Projects/downscaling/agroclimateZones/soil_AWHC.mat
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
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lons,lats,soilDepth);
m_grid;
colormap([ [1 1 1]; [0 0 0] ])
colorbar
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
title('AWC as a proxy for Soil Depth > 1 meter (AWC > 6.5 cm)')
eval(['print -djpeg ',char(fileID),'Douglas1990_soil.jpg']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Determine Agro-Climate Zones based on classification by Douglas et al,
% 1990: Agronomic Zones for the Dryland Pacific Northwest, Pacific Northwest
% Extension Publication 354, September 1990, 3-8.
sprintf('Calculating Agroclimatic Zones from Douglas et al (1990)...')

agz  = zeros(621,435);
agz( find(map>400             &                  cgdd<700             ) ) = 1;
agz( find(map>400             &                 (cgdd>700 & cgdd<1000)) ) = 2;
agz( find((map>350 & map<400) & soilDepth ==1 & (cgdd>700 & cgdd<1000)) ) = 3;
agz( find((map>250 & map<400) & soilDepth ==0 & cgdd<1000             ) ) = 4;
agz( find((map>250 & map<350) & soilDepth ==1 & cgdd<1000             ) ) = 5;
agz( find(map<250                             & cgdd>1000             ) ) = 6;

figure
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lonc,latc,agz,[0 1 2 3 4 5 6]);
m_grid;
caxis([0 6]);
colormap([[1 1 1]; [0 1 (204/255)]; [1 0 0]; [0 (153/255) (204/255)]; [(102/255) (204/255) 1]; [(102/255) (204/255) (153/255)]; [1 (204/255) (204/255)]]);
h    = colorbar;
cint = 6/7;
set(h,'YTick',[0 1 2 3 4 5 6]*cint);
set(h,'YTickLabel',{'0 - None','1 - Cold-Moist','2 - Cool-Moist','3 - Cool-Deep-ModDry','4 - Cool-Shallow-Dry','5 - Cool-Deep-Dry','6 - Hot-Very Dry'})
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
title(['Agro-climate Zones by Douglas et al (1990) for:',fileID,': 1961-1990'])
eval(['print -djpeg ',char(fileID),'Douglas1990_agz.jpg']);

return
