function [lonc,latc,cgdd,map,soilDepth,agz] = agrozones_Walden(PathName,fileID,byr,eyr,iprint)

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
ib   = byr-1900;                   % 0 = 1900, 1 = 1901, ... 
ie   = eyr-1900;                   % 0 = 1900, 1 = 1901, ... 

% CRUDE ESTIMATE of the Cumulative Growing Degree Days
cgdd  = zeros(621,435);
sprintf('Calculating Cumulative Growing Degree Days...')
for m = 1:5

    sprintf('Month: %s',month(m,:))
    ncid_Tmax = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_tmax_run1.nc')),'NOWRITE');
    ncid_Tmin = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_tmin_run1.nc')),'NOWRITE');
    Tmax      = netcdf.getVar(ncid_Tmax,3,[0 0 ib],[621 435 ((ie-ib)+1)],'double');
    Tmax      = reshape(mean(shiftdim(Tmax,2)),621,435);
    Tmin      = netcdf.getVar(ncid_Tmin,3,[0 0 ib],[621 435 ((ie-ib)+1)],'double');
    Tmin      = reshape(mean(shiftdim(Tmin,2)),621,435);
    Tavg      = (Tmax+Tmin)/2;
    Tavg(find(Tavg < 0)) = 0;
        
    cgdd      = cgdd + 30*Tavg;
        
    netcdf.close(ncid_Tmax); netcdf.close(ncid_Tmin); 
end

if(iprint)
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
    h=title(['Cumulative Growing Degree Days, ',char(fileID),', ',num2str(byr),'-',num2str(eyr)]);
    set(h,'Interpreter','none');
    eval(['print -djpeg ',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_cgdd.jpg']);

    eval(['arcgridwrite(''',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_cgdd.asc'',lonc,latc,flipud(cgdd));']);
end

% Determine the Mean Annual Precip (map) as 30-year normal from 1961-1990.
map   = zeros(621,435);
sprintf('Calculating Mean Annual Precipitation...')
for m = 1:12

    sprintf('Month: %s',month(m,:))
    ncid_prec = netcdf.open(char(strcat(PathName,fileID,month(m,:),'_prec_run1.nc')),'NOWRITE');
    prec      = netcdf.getVar(ncid_prec,3,[0 0 ib],[621 435 ((ie-ib)+1)],'double');
    prec      = reshape(mean(shiftdim(prec,2)),621,435);
        
    map       = map + prec;

    netcdf.close(ncid_prec);
end

if(iprint)
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
    h=title(['Mean Annual Precip, ',char(fileID),', ',num2str(byr),'-',num2str(eyr)]);
    set(h,'Interpreter','none');
    eval(['print -djpeg ',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_map.jpg']);
    
    eval(['arcgridwrite(''',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_agz.map'',lonc,latc,flipud(map));']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads in water holding capacity data.
sprintf('Estimating Soil Depth from Available Water Holding Capacity...')
load /Users/vonw/Work/Projects/downscaling/agroclimateZones/soil_AWHC.mat
lons  = double(x(:,1:435));
lats  = double(y(:,1:435));
datas = double(s1(:,1:435));

% Binary "soil depth" map (using water holding capacity as a proxy)
soilDepth = zeros(621,435);
soilDepth(find(datas > 6.5)) = 1;

if(iprint)
    figure
    m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
    m_contourf(lons,lats,soilDepth);
    m_grid;
    colormap([ [1 1 1]; [0 0 0] ])
    colorbar
    m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
    m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
    title('AWC as a proxy for Soil Depth > 1 meter (AWC > 6.5 cm)')
    eval(['print -djpeg ',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_soil.jpg']);
    
    eval(['arcgridwrite(''',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_soil.asc'',lonc,latc,flipud(soilDepth));']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Determine Agro-Climate Zones based on classification by Walden that 
% encompasses all different combinations of climate; somewhat similar to
% Douglas et al (1990), but doesn't use soil depth.
sprintf('Calculating Agroclimatic Zones from Walden...')

agz  = zeros(621,435);
agz( find( map<250             &  cgdd<700              ) ) = 1;
agz( find( map<250             & (cgdd>=700 & cgdd<1000)) ) = 2;
agz( find( map<250             &  cgdd>=1000            ) ) = 3;

agz( find((map>=250 & map<350) &  cgdd<700              ) ) = 4;
agz( find((map>=250 & map<350) & (cgdd>=700 & cgdd<1000)) ) = 5;
agz( find((map>=250 & map<350) &  cgdd>=1000            ) ) = 6;

agz( find((map>=350 & map<400) &  cgdd<700              ) ) = 4;
agz( find((map>=350 & map<400) & (cgdd>=700 & cgdd<1000)) ) = 5;
agz( find((map>=350 & map<400) &  cgdd>=1000            ) ) = 6;

agz( find( map>=400            &  cgdd<700              ) ) = 10;
agz( find( map>=400            & (cgdd>=700 & cgdd<1000)) ) = 11;
agz( find( map>=400            &  cgdd>=1000            ) ) = 12;

figure
m_proj('Mercator','lon',[-122 -111],'lat',[42 49]);
m_contourf(lonc,latc,agz,[0 1 2 3 4 5 6 7 8 9 10 11 12]);
m_grid;
caxis([0 12]);
colormap([ [0 0 0]; [0.8 1 1]; [0.6 1 0.6]; [1 0 0]; [0.4 0.8 1]; [0.6 0.8 0.4]; [1 0.4 0.4]; [0.4 0.4 1]; [0 1 0]; [1 0.6 0.6]; [0 0 1]; [0 0.8 0]; [1 0.8 0.8] ])
h    = colorbar;
cint = 12/13;
set(h,'YTick',[0 1 2 3 4 5 6 7 8 9 10 11 12]*cint);
set(h,'YTickLabel',{'0 - None','1 - Cold-VeryDry','2 - Cool-VeryDry','3 - Hot-VeryDry','4 - Cold-Dry','5 - Cool-Dry','6 - Hot-Dry','7 - Cold-Moist','8 - Cool-Moist','9 - Hot-Moist','10 - Cold-Wet','11 - Cool-Wet','12 - Hot-Wet'})
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/idaho','color','k','linewidth',2);
m_plotbndry('/Applications/MATLAB_R2010a.app/toolbox/m_map/private/politicalbounds/oregon','color','k','linewidth',2);
h=title(['Agro-climate Zones by Douglas et al (1990) for:',char(fileID),', ',num2str(byr),'-',num2str(eyr)]);
set(h,'Interpreter','none');

if(iprint)
    eval(['print -djpeg ',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_agz.jpg']);

    % Convert the agz array to an Arc ASCII grid using arcgridwrite.m from Andrew Stephens (http://www.mathworks.com/matlabcentral/fileexchange/16176-arcgridwrite)
    eval(['arcgridwrite(''',char(fileID),num2str(byr),'-',num2str(eyr),'_Walden_agz.asc'',lonc,latc,flipud(agz));']);
end

return
