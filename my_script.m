	myFile='/cyclone/CMIP5/DAILY/DOWNSCALED_DATA/maca_1var_100pat_WUSA_CSIRO-Mk3-6-0_historical_pr.mat'

matobj =matfile(myFile);



	daysInMonths=[31 28 31 30 31 30 31 31 30 31 30 31];

	lat_target = [42 49];
lon_target = 360-[100 125];

lat = matobj.lat;
lon = matobj.lon;


%==================================
%       GET TASMIN DATA FOR EACH MODEL/SCENARIO
%==============================================================================
	for exp =1 
	     load(['allmodels_tasmin',char(EXP_NAME(exp))],'lat','lon','models_tasmin','models_tasmin_hist');
	end

	%take average over all 14 GCMs
	avgtasminhist=nanmin(models_tasmin_hist,[],4)-273.15;
	avgtasmin=nanmin(models_tasmin,[],4)-273.15;

  	 %=======================================
        %Make plot of the ann avg tasmin for the 3 year ranges
        %=======================================
        cmin = min(min(avgtasmin(:)),min( avgtasminhist(:)));
        cmax = max(max(avgtasmin(:)),max(avgtasminhist(:)));
        subplot(4,1,1)
        [x,y]=meshgrid(lon-360,lat);
        temp = nanmean(avgtasminhist,3);
        makemap(x,y,temp,[cmin cmax]);
        t=colorbar;
        set(get(t,'xlabel'),'string','deg C','Fontsize',10) % sets the ylabel property of the handle t.
        title(['Years ', num2str(1950),'-',num2str(2005)],'FontSize',14);

        for year_i=1:3
                subplot(4,1,year_i+1)
                YEAR_RANGE = [2010+30*(year_i-1):2010+30*year_i-1]-2006+1;
                [x,y]=meshgrid(lon-360,lat);
                temp = nanmean(avgtasmin(:,:,YEAR_RANGE),3);
                makemap(x,y,temp,[cmin cmax]);
                t=colorbar;
                set(get(t,'xlabel'),'string','deg C','Fontsize',10) % sets the ylabel property of the handle t.
                title(['Years ', num2str(min(YEAR_RANGE+2006-1)),'-',num2str(max(YEAR_RANGE+2006-1))],'FontSize',14);
        end

%================================================================================
%      CALCULATE ZONES
%================================================================================

	%assign a zone to each  (go with integers or integer + .5 for the mapping)
        [zonenum,zonealpha,zonelabel,Tmin,Tmax]=get_newzones();
	%get historical zones
	 for i=1:length(lat)
                for j=1:length(lon)
                        if(~isnan(avgtasmin(i,j,:)))
				temp = nanmean(avgtasminhist(i,j,:),3);
                                f = find(temp>=Tmin & temp <Tmax);
                                zone_hist(i,j)=zonenum(f);
                        else
                                zone_hist(i,j) = NaN;
                        end
                end
     end

        for year_i=1:3
                YEAR_RANGE = [2010+30*(year_i-1):2010+30*year_i-1]-2006+1;
          for i=1:length(lat)
                for j=1:length(lon)
                        if(~isnan(avgtasmin(i,j,YEAR_RANGE)))
				temp = nanmean(avgtasmin(i,j,YEAR_RANGE),3);
                                f = find(temp>=Tmin & temp <Tmax);
                                zone(i,j,year_i)=zonenum(f);
                        else
                                zone(i,j,year_i) = NaN;
                        end
                end
          end %i
        end %year
	%=======================================
	%make a plot of zones for the 3 years ranges
	%=======================================
        cmin = min(min(zone(:)),min( zone_hist(:)));
        cmax = max(max(zone(:)),max(zone_hist(:)));
	fmin =(cmin-min(zonenum))/.5+1;fmax = (cmax-min(zonenum))/.5+1;

        subplot(4,1,1)
        [x,y]=meshgrid(lon-360,lat);
        temp = zone_hist;
        makemap(x,y,temp,[cmin cmax]);
        h=colorbar;

        title(['Years ', num2str(1950),'-',num2str(2005)],'FontSize',14);
        colormap(jet(length(fmin:fmax)));
        set(h,'YTick',zonenum(fmin:fmax));
        set(h,'YTickLabel',zonelabel(fmin:fmax));
	set(h,'fontsize',7)
        set(get(h,'xlabel'),'string','zone','Fontsize',10) % sets the ylabel property of the handle t.

          for year_i=1:3
                subplot(4,1,year_i+1)
                YEAR_RANGE = [2010+30*(year_i-1):2010+30*year_i-1]-2006+1;
                [x,y]=meshgrid(lon-360,lat);
                temp = zone(:,:,year_i);
                makemap(x,y,temp,[cmin cmax]);
                h=colorbar;
                set(get(h,'xlabel'),'string','zone','Fontsize',10) % sets the ylabel property of the handle t.
                title(['Years ', num2str(min(YEAR_RANGE+2006-1)),'-',num2str(max(YEAR_RANGE+2006-1))],'FontSize',14);

                colormap(jet(length(fmin:fmax)));
                set(h,'YTick',zonenum(fmin:fmax));
                set(h,'YTickLabel',zonelabel(fmin:fmax));
		set(h,'fontsize',7)
		set(get(h,'xlabel'),'string','zone','Fontsize',10) % sets the ylabel property of the handle t.
        end
	for i = 1:4
	subplot(4,1,i);
		set(h,'fontsize',7)
	end
	%=======================================
	%make a plot of changes in zones for the 3 years ranges
	%=======================================
        for year_i=1:3
		zone_changes(:,:,year_i) = zone(:,:,year_i) - zone_hist;
	end
   	cmin =min(zone_changes(:));
        cmax =max(zone_changes(:));
	fmax = (cmax-cmin)/.5;fmin = 1;
        h=colorbar;
        colormap(jet(length(fmin:fmax)));
        set(h,'YTick',[cmin:.5: cmax]);
          for year_i=1:3
                subplot(3,1,year_i)
                YEAR_RANGE = [2010+30*(year_i-1):2010+30*year_i-1]-2006+1;
                [x,y]=meshgrid(lon-360,lat);
                temp = zone(:,:,year_i)-zone_hist;
                makemap(x,y,temp,[cmin cmax]);
                h=colorbar;
                set(get(h,'xlabel'),'string','\Delta zone','Fontsize',10) % sets the ylabel property of the handle t.
                title(['Years ', num2str(min(YEAR_RANGE+2006-1)),'-',num2str(max(YEAR_RANGE+2006-1))],'FontSize',14);

                %colormap(jet(length(fmin:fmax)));
                %set(h,'YTick',zonenum(fmin:fmax));
                %set(h,'YTickLabel',zonelabel(fmin:fmax));
                %set(h,'fontsize',7)
                %set(get(h,'xlabel'),'string','zone','Fontsize',10) % sets the ylabel property of the handle t.
        end

	%=======================================
	%get percent of PNW that has certain zones by different time periods
	%=======================================
        [zonenum,zonealpha,zonelabel,Tmin,Tmax]=get_newzones();

    	%assign a zone to each decade  
	data = avgtasmin;  
        for year_i=1: floor(size(data,3)/10);
                YEAR_RANGE = [2010+10*(year_i-1):2010+10*year_i-1]-2006+1;
         for i=1:length(lat)
                for j=1:length(lon)
                        if(~isnan(data(i,j,:)))
                                temp = nanmean(data(i,j,YEAR_RANGE),3);
                                f = find(temp>=Tmin & temp <Tmax);
                                zonedecade(i,j,year_i)=zonenum(f);
                        else
                                zonedecade(i,j,year_i) = NaN;
                        end
                end
           end
	end



save('percents_rcp45', '-v7.3','zonedecade','zone_hist','avgtasmin');
save('percents_rcp85', '-v7.3','zonedecade','zone_hist','avgtasmin');

%=================

load('percents_rcp85', 'zonedecade','zone_hist','avgtasmin');
zonedecade_85 = zonedecade;
zone_hist_85 = zone_hist;
avgtasmin_85 = avgtasmin;
load('percents_rcp45', 'zonedecade','zone_hist','avgtasmin');
zonedecade_45 = zonedecade;
zone_hist_45 = zone_hist;
avgtasmin_45 = avgtasmin;





	%get percent for historical
	for i=1:length(zonenum)
		f=find(zone_hist==zonenum(i));
		f2 =find(~isnan(zone_hist));
		percent_hist(i) = length(f)/length(f2);
	end
	%get percent for future 
	zonedecade = zonedecade_85;
	for year_i = 1: floor(size(data,3)/10);
		for i=1:length(zonenum)
			f=find(zonedecade(:,:,year_i)==zonenum(i));
			f2 =find(~isnan(zonedecade(:,:,year_i)));
			percent_85(i,year_i) = length(f)/length(f2);
		end
	end
	zonedecade = zonedecade_45;
	for year_i = 1: floor(size(data,3)/10);
		for i=1:length(zonenum)
			f=find(zonedecade(:,:,year_i)==zonenum(i));
			f2 =find(~isnan(zonedecade(:,:,year_i)));
			percent_45(i,year_i) = length(f)/length(f2);
		end
	end


	%plot percents... for historical and the decades under scenario
	cmin = min([min(zonedecade_85(:)) min(zone_hist(:)) min(zonedecade_45(:))]);
	cmax = max([max(zonedecade_85(:)) max(zone_hist(:)) max(zonedecade_45(:))]);
 	fmin =(cmin-min(zonenum))/.5+1;fmax = (cmax-min(zonenum))/.5+1;


	fs=18;lw = 2;
	 subplot( 1+floor(size(data,3)/10), 1,1);
         plot(zonenum(fmin:fmax),percent_hist(fmin:fmax),'LineWidth',lw,'Color','k')
          set(gca,'FontSize',fs);
		set(gca,'XTickLabel','');
		set(gca,'YTick',[0;.4;])
		set(gca,'YTickLabel',[0;.4;]);

	for year_i = 1: floor(size(data,3)/10);
		subplot( 1+floor(size(data,3)/10), 1,year_i+1);
		plot(zonenum(fmin:fmax),percent_45(fmin:fmax,year_i),'LineWidth',lw);
		hold on;
		plot(zonenum(fmin:fmax),percent_85(fmin:fmax,year_i),'color','r','LineWidth',lw);
		hold on;
		set(gca,'FontSize',fs);
		if(year_i~=floor(size(data,3)/10))
		set(gca,'XTickLabel','');
		else
		set(gca,'XTickLabel',zonenum(fmin:fmax));
		xlabel('Zone','FontSize',fs);
		end
		set(gca,'YTick',[0;.4;])
		set(gca,'YTickLabel',[0;.4;]);
		if(year_i==floor(floor(size(data,3)/10)/2))
		ylabel('Percent of PNW Area','FontSize',fs);
		end
	end
set(gca,'XTick',zonenum(fmin:fmax))
set(gca,['x' 'TickLabel'], zonelabel(fmin:fmax));	

xlim([min(zonenum(fmin:fmax)) max(zonenum(fmin:fmax))]);


a=plot([1 1],'color','k','LineWidth',lw);hold on
a=plot([1 1],'color','b','LineWidth',lw);hold on
a=plot([1 1],'color','r','LineWidth',lw);
legend({'Historical','rcp 45','rcp85'},'Location','BestOutside')
