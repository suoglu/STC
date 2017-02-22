% Begum, FM, Yarkin, Yigit
% This file models a STC algoritm for sea clutter
function out = stc(power, coef, max_dis, dis)
        out = 1 - (coef * (max_dis - dis).^power);
end