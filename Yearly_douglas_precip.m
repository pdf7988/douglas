NLAT = length(lat);
NLON = length(lon);
DAYS=365;
YEARS=56;

%truncate your data to your lat/lon region

%data = truncatedstuff....

data=precip;  %precipitation_flux (lon,lat,time)
data = permute(data,[2 1 3]);
DaysInMonths = [31 28 31 30 31 30 31 31 30 31 30 31];

    %converts precip_flux to precipitation (in mm)
    data=data*3600*24;

%reshapes data from lat,lon,time to lat,lon,days,year
data = reshape(data,NLAT,NLON,DAYS,YEARS);

%take sum of daily precip over 365 days
annualprecip = squeeze(nansum(data,3));

%avg annual precip over years
meanannualprecip = nanmean(annualprecip,3);


%for m=1:12;
    
%    
%    %gets the window of days in each month
%    if m==1
%     days = [1:31];    
%    else
%        days = sum(DaysInMonths(1:m-1))+1:sum(DaysInMonths(1:m));
%    end
%     
%    %extra daily data for that month
%    temp = data(:,:,days,:);
    
    
%    %make monthly sums of precip from daily precip
%    monthlydata(:,:,:,m) = squeeze(nansum(temp,3));
    
    
       
%end

%change order so it is lat,lon,month,years
%monthlydata = permute(monthlydata,[1 2 4 3]);


  