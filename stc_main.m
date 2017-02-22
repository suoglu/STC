% Begum, FM, Yarkin, Yigit
% This file models a STC system for sea clutter
waveSpeed = 299792.458; % speed of wave (km/s)
sampleNumber = 100000; % number of samples to applied to 
max_see = 146.38303661; % (2/4096)*waveSpeed; % range of radar (km)
increment = 0.001463830361; % max_see / sampleNumber; % list of sample kms
% sz = 100001; %  (max_see * increment + 1);
sea_ground = 5; % ensure entance of while
while(sea_ground ~= 0 && sea_ground ~= 1) % input check (1 or 0)
    sea_ground = input('1 for ground 0 for sea: ');
end
att_zero = 5; % ensure entance of while
while(att_zero > 1 || att_zero < 0) % input check, attenuation must be between (0-1) 
    att_zero = input('Attenuation at zero point: ');
end
max_dis = -5; % ensure entance of while
while(max_dis < 0) % input check,distance must be positive
    max_dis = input('Maximum distance (in km): ');
end
  
pwr = 2*(sea_ground + 1); % set power 4 for ground, 2 for sea
coef = ((1 - att_zero) / (max_dis.^pwr)); % coefficent of gain
dis = 0:increment:max_see; % store sample distances

filtered =  stc(pwr, coef, max_dis, dis); % apply each element in to filter

eNMax = uint64(max_dis / increment);

for i = eNMax:100001
   filtered(1,i) = 1;
end

plot(dis, filtered);