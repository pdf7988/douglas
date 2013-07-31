function [lonc,latc,agz] = agrozones(PathName,fileID)

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
surf(lonc,latc,cgdd)
view(2)
axis([-125 -107 30 50])
shading flat
caxis([0 4000]);
colorbar
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title(['Cumulative Growing Degree Days, ',fileID,', 1961-1990'])
print -djpeg results/IPSL_CM4_A2_1961-1990_CGDD.jpg

figure
surf(lonc,latc,map)
view(2)
axis([-125 -107 30 50])
shading flat
caxis([0 8500]);
colorbar
xlabel('Longitude (degrees)')
ylabel('Latitude (degrees)')
title(['Mean Annual Precip, ',fileID,', 1961-1990'])
print -djpeg results/IPSL_CM4_A2_1961-1990_MAP.jpg


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads in water holding capacity data.
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
print -djpeg results/IPSL_CM4_A2_1961-1990_SD.jpg

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Determine Agro-Climate Zones based on classification by Douglas et al,
% 1996: Agroclimatic Zones for Dryland Winter Wheat Producing Areas of
% ldaho, Washington and, Oregon, Northwest Science, 66, 26-34.

agz  = zeros(621,435);
agz( find(map>400             &                  cgdd<700             ) ) = 1;
agz( find(map>400             &                 (cgdd>700 & cgdd<1000)) ) = 2;
agz( find((map>350 & map<400) & soilDepth ==1 & (cgdd>700 & cgdd<1000)) ) = 3;
agz( find((map>250 & map<400) & soilDepth ==0 & cgdd<1000             ) ) = 4;
agz( find(map<350             & soilDepth ==1                         ) ) = 5;

figure
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lonc,latc,agz,[0 1 2 3 4 5]);
m_grid;
caxis([0 6]);
colormap([[1 1 1]; [0 0 1]; [0 1 1]; [0 1 0]; [1 1 0]; [1 0 0]]);
h = colorbar;
set(h,'YTick',[0.5 1.5 2.5 3.5 4.5 5.5]);
set(h,'YTickLabel',{'None','1 - Wet-Cold','2 - Wet-Cool','3 - Transition','4 - Dry','5 - Fallow'})
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
title(['Agro-climate Zones by Douglas et al (1992) for:',fileID,': 1961-1990'])
print -djpeg results/IPSL_CM4_A2_1961-1990_AGZ.jpg

return
