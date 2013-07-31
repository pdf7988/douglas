function [ douglaszone ] = get_douglaszones( prec,cgdd,watercap )
%UNTITLED2 Summary of this function goes here
%   This function calculates as a function of the water cap, cgdd, and
%   precip
%watercap should be in units of mm
%mean annual precip should be in units of mm
%cgdd is cumulative growing degree days

%===============================
%   Zone 1
%===============================

if prec >400 && cgdd <700; 
   douglaszone=1; 
end

%===============================
%   Zone 2
%===============================

if prec >400 && cgdd >700 && cgdd <1000; 
   douglaszone=2; 
end

%===============================
%   Zone 3
%===============================

if prec >350 && prec <450 && cgdd >700 && cgdd <1000 && watercap >100; 
   douglaszone=3; 
end

%===============================
%   Zone 4
%===============================

if prec >250 && prec <400 && cgdd <1000 && watercap <100; 
   douglaszone=4; 
end

%===============================
%   Zone 5
%===============================

if prec <350 && watercap >100; 
   douglaszone=5; 
end

%===============================
%   Zone 6
%===============================

%CGDD, prec, and watercap not facotrs in this zone because this zone is
%irrigated







end

