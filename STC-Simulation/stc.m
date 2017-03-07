% Begum, FM, Yarkin, Yigit
% This file models a STC algoritm for sea clutter
function out = stc(pwr, coef, max_dis, dis)
        out = 1 - (coef * (max_dis - dis).^pwr);
end