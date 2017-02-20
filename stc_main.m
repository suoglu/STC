% Begum, FM, Yarkin, Yigit
% This file models a STC for sea clutter
sea_ground = 5;
while(sea_ground ~= 0 && sea_ground ~= 1) % input check (1 or 0)
    sea_ground = input('1 for ground 0 for sea: ');
end
att_zero = 5;
while(att_zero > 1 || att_zero < 0) % input check, attenuation must be between (0-1) 
    att_zero = input('Attenuation at zero point: ');
end
max_dis = -5;
while(max_dis < 0) % input check,distance must be positive
    max_dis = input('Maximum distance: ');
end
  
power = 2*(sea_ground + 1); % set power 4 for ground, 2 for sea
coef = ((1 - att_zero) / (max_dis.^power)); % coefficent of gain

stc(power, coef, max_dis, 0);