%Filename:douglaszones
%Author:
%Date:
%Purpose:To calculate douglas zones using  (1) growing degree days which
%are calculated from daily temperature, (2) mean annual precip, and (3) soil depth (or available water holding capacity)


target_lat =[42]; %n lats
target_lon =[-111+360]; %W lons
%===============================
%   water holding capacity
%===============================


load('soil250.mat','soil','lat','lon'); lat =lat(:,1); lon=-lon(1,:);
contourf(soil);%this is available water holding capacity
colorbar;
watercap=10*soil;%units in mm
clear soil;


f_lat=find(lat>=min(target_lat)&lat<=max(target_lat));

f_lon=find(lon>=min(target_lon)&lon<=max(target_lon));

watercap=watercap(f_lat,f_lon);

watercap=flipdim(watercap,1);

contourf(watercap)


%===============================
%   growing degree days
%===============================

%===============================
%    Mean annual precip
%===============================

%===============================
%   Dougals Zones
%===============================

douglaszones=get_douglaszones(watercap,gdd,prec);